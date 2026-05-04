package com.scamdetector.scam_detector.callscreening

import android.app.Activity
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

/**
 * MethodChannel bridge so the Flutter UI can:
 *  - sync the local scam / suspicious phone list to native SharedPreferences
 *    (used by [IncomingCallScreener])
 *  - check whether this app currently holds ROLE_CALL_SCREENING
 *  - request the role from the user (Android system dialog)
 */
object CallScreeningBridge {
    const val CHANNEL = "com.scamdetector/call_screening"
    const val REQUEST_CODE = 7392

    private var pendingResult: MethodChannel.Result? = null
    private var channel: MethodChannel? = null
    // Buffers an incoming-call event that lands before Dart has registered
    // its listener (cold launch). Drained on the first listener registration.
    private var pendingIncomingCall: Map<String, Any?>? = null
    private var dartListenerReady = false

    fun register(activity: Activity, engine: FlutterEngine) {
        val ch = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        channel = ch
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "registerIncomingCallListener" -> {
                    dartListenerReady = true
                    pendingIncomingCall?.let {
                        ch.invokeMethod("incomingCallDetected", it)
                        pendingIncomingCall = null
                    }
                    result.success(true)
                }
                "syncBlocklist" -> {
                    val scam = (call.argument<List<String>>("scam") ?: emptyList())
                        .map(::normalize)
                        .toSet()
                    val suspicious = (call.argument<List<String>>("suspicious") ?: emptyList())
                        .map(::normalize)
                        .toSet()
                    val prefs = activity.getSharedPreferences(
                        IncomingCallScreener.PREFS,
                        Context.MODE_PRIVATE,
                    )
                    prefs.edit()
                        .putStringSet(IncomingCallScreener.KEY_SCAM, scam)
                        .putStringSet(IncomingCallScreener.KEY_SUSPICIOUS, suspicious)
                        .apply()
                    result.success(mapOf("scam" to scam.size, "suspicious" to suspicious.size))
                }

                "addBlocklistNumber" -> {
                    val number = call.argument<String>("number").orEmpty()
                    val level = call.argument<String>("level") ?: "scam"
                    if (number.isBlank()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val normalized = normalize(number)
                    val prefs = activity.getSharedPreferences(
                        IncomingCallScreener.PREFS,
                        Context.MODE_PRIVATE,
                    )
                    val targetKey = if (level == "scam") {
                        IncomingCallScreener.KEY_SCAM
                    } else {
                        IncomingCallScreener.KEY_SUSPICIOUS
                    }
                    val otherKey = if (level == "scam") {
                        IncomingCallScreener.KEY_SUSPICIOUS
                    } else {
                        IncomingCallScreener.KEY_SCAM
                    }
                    val target = prefs.getStringSet(targetKey, emptySet())?.toMutableSet()
                        ?: mutableSetOf()
                    val other = prefs.getStringSet(otherKey, emptySet())?.toMutableSet()
                        ?: mutableSetOf()
                    target.add(normalized)
                    // Avoid having the same number in both sets — promotion supersedes.
                    other.remove(normalized)
                    prefs.edit()
                        .putStringSet(targetKey, target)
                        .putStringSet(otherKey, other)
                        .apply()
                    result.success(true)
                }

                "removeBlocklistNumber" -> {
                    val number = call.argument<String>("number").orEmpty()
                    if (number.isBlank()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val normalized = normalize(number)
                    val prefs = activity.getSharedPreferences(
                        IncomingCallScreener.PREFS,
                        Context.MODE_PRIVATE,
                    )
                    val scam = prefs.getStringSet(
                        IncomingCallScreener.KEY_SCAM, emptySet(),
                    )?.toMutableSet() ?: mutableSetOf()
                    val suspicious = prefs.getStringSet(
                        IncomingCallScreener.KEY_SUSPICIOUS, emptySet(),
                    )?.toMutableSet() ?: mutableSetOf()
                    val removed = scam.remove(normalized) or suspicious.remove(normalized)
                    prefs.edit()
                        .putStringSet(IncomingCallScreener.KEY_SCAM, scam)
                        .putStringSet(IncomingCallScreener.KEY_SUSPICIOUS, suspicious)
                        .apply()
                    result.success(removed)
                }

                "getBlocklist" -> {
                    val prefs = activity.getSharedPreferences(
                        IncomingCallScreener.PREFS,
                        Context.MODE_PRIVATE,
                    )
                    val scam = prefs.getStringSet(IncomingCallScreener.KEY_SCAM, emptySet())
                        ?: emptySet()
                    val suspicious = prefs.getStringSet(
                        IncomingCallScreener.KEY_SUSPICIOUS,
                        emptySet(),
                    ) ?: emptySet()
                    result.success(
                        mapOf(
                            "scam" to scam.toList(),
                            "suspicious" to suspicious.toList(),
                        ),
                    )
                }

                "clearAllNativeData" -> {
                    val prefs = activity.getSharedPreferences(
                        IncomingCallScreener.PREFS,
                        Context.MODE_PRIVATE,
                    )
                    prefs.edit().clear().apply()
                    pendingIncomingCall = null
                    result.success(true)
                }

                "drainScreeningEvents" -> {
                    val prefs = activity.getSharedPreferences(
                        IncomingCallScreener.PREFS,
                        Context.MODE_PRIVATE,
                    )
                    val raw = prefs.getString(IncomingCallScreener.KEY_EVENTS, "[]") ?: "[]"
                    prefs.edit().remove(IncomingCallScreener.KEY_EVENTS).apply()
                    val arr = try { JSONArray(raw) } catch (_: Exception) { JSONArray() }
                    val out = ArrayList<Map<String, Any?>>(arr.length())
                    for (i in 0 until arr.length()) {
                        val o = arr.optJSONObject(i) ?: continue
                        out.add(
                            mapOf(
                                "number" to o.optString("number"),
                                "label" to o.optString("label"),
                                "blocked" to o.optBoolean("blocked"),
                                "timestamp" to o.optLong("timestamp"),
                            ),
                        )
                    }
                    result.success(out)
                }

                "isCallScreeningRoleHeld" -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                        result.success(false)
                    } else {
                        val rm = activity.getSystemService(Context.ROLE_SERVICE) as RoleManager
                        result.success(rm.isRoleHeld(RoleManager.ROLE_CALL_SCREENING))
                    }
                }

                "requestCallScreeningRole" -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                        result.error(
                            "UNSUPPORTED",
                            "Yêu cầu Android 10 (API 29) trở lên.",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    val rm = activity.getSystemService(Context.ROLE_SERVICE) as RoleManager
                    if (rm.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)) {
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    pendingResult = result
                    val intent: Intent = rm.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                    activity.startActivityForResult(intent, REQUEST_CODE)
                }

                else -> result.notImplemented()
            }
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int): Boolean {
        if (requestCode != REQUEST_CODE) return false
        pendingResult?.success(resultCode == Activity.RESULT_OK)
        pendingResult = null
        return true
    }

    /**
     * Called by [com.scamdetector.scam_detector.MainActivity] when a notification
     * tap (or full-screen intent) brings the app forward with a scam-call payload.
     */
    fun notifyIncomingCall(number: String, label: String, blocked: Boolean) {
        val payload = mapOf(
            "number" to number,
            "label" to label,
            "blocked" to blocked,
        )
        if (dartListenerReady && channel != null) {
            channel!!.invokeMethod("incomingCallDetected", payload)
        } else {
            pendingIncomingCall = payload
        }
    }

    private fun normalize(value: String): String =
        value.replace(Regex("[\\s\\-()+]"), "")
}
