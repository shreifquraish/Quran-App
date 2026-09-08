package com.alqurankareem.al_quran_kareem

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import android.os.PowerManager
import androidx.core.app.NotificationCompat

class AdhanAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        val channelId = "adhan_audio_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager.createNotificationChannel(
                android.app.NotificationChannel(
                    channelId,
                    "الأذان",
                    android.app.NotificationManager.IMPORTANCE_LOW,
                ),
            )
        }
        val notificationId = 9000
        notificationManager.notify(
            notificationId,
            NotificationCompat.Builder(context, channelId)
                .setSmallIcon(R.mipmap.launcher_icon)
                .setContentTitle("الأذان")
                .setContentText("يُشغّل الآن")
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setOngoing(true)
                .setAutoCancel(false)
                .setSilent(true)
                .build(),
        )

        val wakeLock = (context.getSystemService(Context.POWER_SERVICE) as? PowerManager)
            ?.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "AlQuranKareem::AdhanWakeLock")
        wakeLock?.acquire(10 * 60 * 1000L)
        val player = MediaPlayer.create(context, R.raw.adhan) ?: run {
            notificationManager.cancel(notificationId)
            wakeLock?.release()
            return
        }
        player.setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build()
        )
        player.setOnCompletionListener {
            it.release()
            notificationManager.cancel(notificationId)
            if (wakeLock?.isHeld == true) wakeLock.release()
        }
        player.setOnErrorListener { mediaPlayer, _, _ ->
            mediaPlayer.release()
            notificationManager.cancel(notificationId)
            if (wakeLock?.isHeld == true) wakeLock.release()
            true
        }
        player.start()
    }

    companion object {
        private const val ACTION = "com.alqurankareem.ACTION_ADHAN_ALARM"

        fun schedule(context: Context, id: Int, timestamp: Long) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, AdhanAlarmReceiver::class.java).apply {
                action = ACTION
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    timestamp,
                    pendingIntent,
                )
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, timestamp, pendingIntent)
            }
        }

        fun cancelAll(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            for (id in 1000 until 2000) {
                val intent = Intent(context, AdhanAlarmReceiver::class.java).apply {
                    action = ACTION
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
}