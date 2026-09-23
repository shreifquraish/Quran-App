package com.alqurankareem.al_quran_kareem

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class AdhanAlarmReceiver : BroadcastReceiver() {

    companion object {
        /** Returns true if Adhan audio is currently playing */
        fun isPlaying(): Boolean = AdhanService.isRunning

        fun stopPlayback(context: Context) {
            AdhanService.stop(context)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (isAnotherAudioActive(context)) return
        // Stop any salawat that might be playing to avoid audio overlap
        SalawatAlarmReceiver.stopPlayback(context)
        // Start the foreground service which handles audio independently
        AdhanService.start(context)
    }

    private fun isAnotherAudioActive(context: Context): Boolean {
        return try {
            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as android.media.AudioManager
            audioManager.isMusicActive ||
                audioManager.mode == android.media.AudioManager.MODE_IN_CALL ||
                audioManager.mode == android.media.AudioManager.MODE_IN_COMMUNICATION
        } catch (_: Exception) {
            false
        }
    }

    private val alarmAction = "com.alqurankareem.ACTION_ADHAN_ALARM"

    fun schedule(context: Context, id: Int, timestamp: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AdhanAlarmReceiver::class.java).apply {
            action = alarmAction
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val showIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)
        val showPendingIntent = PendingIntent.getActivity(
            context,
            id + 5000,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        try {
            val alarmClockInfo = AlarmManager.AlarmClockInfo(timestamp, showPendingIntent)
            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
        } catch (e: Exception) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        timestamp,
                        pendingIntent,
                    )
                } else {
                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, timestamp, pendingIntent)
                }
            } catch (_: Exception) {}
        }
    }

    fun cancelAll(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (id in 1000 until 2000) {
            val intent = Intent(context, AdhanAlarmReceiver::class.java).apply {
                action = alarmAction
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            alarmManager.cancel(pendingIntent)
        }
    }
}
