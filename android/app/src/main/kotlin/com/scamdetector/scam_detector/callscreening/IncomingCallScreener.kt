package com.scamdetector.scam_detector.callscreening

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import androidx.core.app.NotificationCompat
import com.scamdetector.scam_detector.MainActivity
import org.json.JSONArray
import org.json.JSONObject

/**
 * Receives metadata for every incoming call once the user grants this app
 * the call screening role. Looks up the number against the locally synced
 * scam list and:
 *   - rejects + notifies for known scam numbers
 *   - allows + notifies for suspicious numbers
 *   - allows silently for unknown numbers
 *
 * The blocklist is synced from Flutter via [CallScreeningBridge] and stored
 * in SharedPreferences for fast offline access.
 */
class IncomingCallScreener : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val rawNumber = callDetails.handle?.schemeSpecificPart
        if (rawNumber.isNullOrBlank()) {
            respondAllow(callDetails)
            return
        }
        val normalized = rawNumber.replace(Regex("[\\s\\-()+]"), "")
        val prefs = getSharedPreferences(PREFS, MODE_PRIVATE)
        val scamSet = prefs.getStringSet(KEY_SCAM, emptySet()) ?: emptySet()
        val suspiciousSet = prefs.getStringSet(KEY_SUSPICIOUS, emptySet()) ?: emptySet()

        when {
            scamSet.contains(normalized) -> {
                rejectCall(callDetails)
                recordEvent(rawNumber, "Lừa đảo", true)
                notifyUser(rawNumber, "Lừa đảo", true)
            }
            suspiciousSet.contains(normalized) -> {
                respondAllow(callDetails)
                recordEvent(rawNumber, "Nghi ngờ", false)
                notifyUser(rawNumber, "Nghi ngờ", false)
            }
            else -> respondAllow(callDetails)
        }
    }

    /**
     * Append a screened-call event to the SharedPreferences queue so the Dart
     * side can drain it into the history feed. Capped at [MAX_EVENTS] — oldest
     * entries are dropped so the queue can't grow unbounded.
     */
    private fun recordEvent(number: String, label: String, blocked: Boolean) {
        val prefs = getSharedPreferences(PREFS, MODE_PRIVATE)
        val raw = prefs.getString(KEY_EVENTS, "[]") ?: "[]"
        val arr = try { JSONArray(raw) } catch (_: Exception) { JSONArray() }
        val obj = JSONObject().apply {
            put("number", number)
            put("label", label)
            put("blocked", blocked)
            put("timestamp", System.currentTimeMillis())
        }
        arr.put(obj)
        while (arr.length() > MAX_EVENTS) arr.remove(0)
        prefs.edit().putString(KEY_EVENTS, arr.toString()).apply()
    }

    private fun rejectCall(callDetails: Call.Details) {
        val response = CallResponse.Builder()
            .setDisallowCall(true)
            .setRejectCall(true)
            .setSkipCallLog(false)
            .setSkipNotification(false)
            .build()
        respondToCall(callDetails, response)
    }

    private fun respondAllow(callDetails: Call.Details) {
        val response = CallResponse.Builder().build()
        respondToCall(callDetails, response)
    }

    private fun notifyUser(number: String, label: String, blocked: Boolean) {
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Cảnh báo cuộc gọi",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Cảnh báo khi có cuộc gọi nghi ngờ lừa đảo."
            }
            nm.createNotificationChannel(channel)
        }

        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(EXTRA_INCOMING_NUMBER, number)
            putExtra(EXTRA_INCOMING_LABEL, label)
            putExtra(EXTRA_INCOMING_BLOCKED, blocked)
        }
        val pi = PendingIntent.getActivity(
            this,
            number.hashCode(),
            openAppIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        val title = if (blocked) "Đã chặn cuộc gọi $label" else "Cuộc gọi $label"
        val body = "$number — $label theo dữ liệu Scam Detector."

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_notify_error)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setContentIntent(pi)
            // Pop the in-app warning overlay automatically (over lock screen).
            // Requires USE_FULL_SCREEN_INTENT permission (declared in manifest).
            .setFullScreenIntent(pi, true)
            .build()

        nm.notify(number.hashCode(), notification)
    }

    companion object {
        const val PREFS = "scam_detector_prefs"
        const val KEY_SCAM = "scam_numbers"
        const val KEY_SUSPICIOUS = "suspicious_numbers"
        const val KEY_EVENTS = "screening_events"
        const val EXTRA_INCOMING_NUMBER = "incoming_call_number"
        const val EXTRA_INCOMING_LABEL = "incoming_call_label"
        const val EXTRA_INCOMING_BLOCKED = "incoming_call_blocked"
        private const val CHANNEL_ID = "scam_call_warnings"
        private const val MAX_EVENTS = 100
    }
}
