package com.alqurankareem.al_quran_kareem

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class SalawatBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == "android.intent.action.MY_PACKAGE_REPLACED" ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            SalawatAlarmReceiver.scheduleNextAlarm(context)
        }
    }
}
