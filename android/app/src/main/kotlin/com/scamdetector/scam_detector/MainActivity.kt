package com.scamdetector.scam_detector

import android.content.Intent
import com.scamdetector.scam_detector.callscreening.CallScreeningBridge
import com.scamdetector.scam_detector.callscreening.IncomingCallScreener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        CallScreeningBridge.register(this, flutterEngine)
        // Cold-launch from notification: process the launch intent.
        forwardIncomingCallExtras(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // Warm-launch (app already running): forward the new intent.
        forwardIncomingCallExtras(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (!CallScreeningBridge.handleActivityResult(requestCode, resultCode)) {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    private fun forwardIncomingCallExtras(intent: Intent?) {
        val number = intent?.getStringExtra(IncomingCallScreener.EXTRA_INCOMING_NUMBER)
            ?: return
        val label = intent.getStringExtra(IncomingCallScreener.EXTRA_INCOMING_LABEL).orEmpty()
        val blocked = intent.getBooleanExtra(IncomingCallScreener.EXTRA_INCOMING_BLOCKED, false)
        CallScreeningBridge.notifyIncomingCall(number, label, blocked)
        // Consume so we don't re-fire on rotation / restart.
        intent.removeExtra(IncomingCallScreener.EXTRA_INCOMING_NUMBER)
    }
}
