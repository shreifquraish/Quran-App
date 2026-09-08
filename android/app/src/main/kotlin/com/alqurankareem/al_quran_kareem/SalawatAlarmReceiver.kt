package com.alqurankareem.al_quran_kareem

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

class SalawatAlarmReceiver : BroadcastReceiver() {

    companion object {
        const val CHANNEL_ID = "salawat_alarm_native_channel_v6"
        const val CHANNEL_NAME = "الصلاة على النبي ﷺ (صوت)"
        const val NOTIFICATION_ID = 7777

        fun setMaxVolume(context: Context) {
            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
                ?: return
            val maxAlarm = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxAlarm, 0)
            val maxMusic = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, maxMusic, 0)
        }

        /**
         * Schedules the next alarm at the exact upcoming :00 or :30 on the clock.
         * Uses setAlarmClock which is 100% exempt from Android Doze mode and never delayed.
         */
        fun scheduleNextAlarm(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return

            val now = Calendar.getInstance()
            val target = Calendar.getInstance().apply {
                val currentMin = now.get(Calendar.MINUTE)
                if (currentMin < 30) {
                    set(Calendar.MINUTE, 30)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                } else {
                    add(Calendar.HOUR_OF_DAY, 1)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }
            }

            val intent = Intent(context, SalawatAlarmReceiver::class.java).apply {
                action = "com.alqurankareem.ACTION_SALAWAT_ALARM"
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                NOTIFICATION_ID,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val showIntent = context.packageManager.getLaunchIntentForPackage(context.packageName) ?: Intent(context, MainActivity::class.java)
            val showPendingIntent = PendingIntent.getActivity(
                context,
                0,
                showIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val triggerTime = target.timeInMillis
            try {
                // setAlarmClock guarantees instant wakeup even in deep Doze mode without touching the phone
                val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerTime, showPendingIntent)
                alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
            } catch (e: Exception) {
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        alarmManager.setExactAndAllowWhileIdle(
                            AlarmManager.RTC_WAKEUP,
                            triggerTime,
                            pendingIntent
                        )
                    } else {
                        alarmManager.setExact(
                            AlarmManager.RTC_WAKEUP,
                            triggerTime,
                            pendingIntent
                        )
                    }
                } catch (e2: Exception) {
                    e2.printStackTrace()
                }
            }
        }

        fun cancelAlarms(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val intent = Intent(context, SalawatAlarmReceiver::class.java).apply {
                action = "com.alqurankareem.ACTION_SALAWAT_ALARM"
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                NOTIFICATION_ID,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
        }

        fun isPrayerTimeNow(context: Context): Boolean {
            val preferences = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE,
            )
            val settingsJson = preferences.getString("flutter.prayer_settings", null)
                ?: return false
            val settings = JSONObject(settingsJson)
            val city = settings.optString("city")
            val country = settings.optString("country")
            if (city.isEmpty() || country.isEmpty()) return false

            val date = SimpleDateFormat("dd-MM-yyyy", Locale.US).format(Date())
            val cacheKey = "flutter.prayer_times_${city}_${country}_$date"
            val timingsJson = preferences.getString(cacheKey, null) ?: return false
            val timings = JSONObject(timingsJson)
            val currentTime = SimpleDateFormat("HH:mm", Locale.US).format(Date())

            val prayerNames = arrayOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha")
            return prayerNames.any { name ->
                timings.optString(name).take(5) == currentTime
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager

        // 1. Acquire partial wake lock to keep CPU awake while voice plays
        val wakeLock = powerManager?.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "AlQuranKareem::SalawatCpuWakeLock"
        )
        wakeLock?.acquire(10000) // 10 seconds max safety timeout

        try {
            if (!isPrayerTimeNow(context)) {
                val isHalfHour = Calendar.getInstance().get(Calendar.MINUTE) == 30
                val audioName = if (isHalfHour) "salawat_khatam" else "salawat"
                val phrase = if (isHalfHour) {
                    "لَا إِلَهَ إِلَّا اللَّهُ - يُشغّل الآن"
                } else {
                    "صَلِّ عَلَى مُحَمَّد ﷺ - يُشغّل الآن"
                }
                showNotification(context, phrase)
                playSalawatVoice(context, wakeLock, audioName)
            } else if (wakeLock?.isHeld == true) {
                wakeLock.release()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            if (wakeLock?.isHeld == true) wakeLock.release()
        }

        // Reschedule for next clock interval (:00 or :30)
        scheduleNextAlarm(context)
    }

    fun playSalawatVoice(context: Context, wakeLock: PowerManager.WakeLock? = null, audioResName: String = "salawat") {
        try {
            val requestedResId = context.resources.getIdentifier(audioResName, "raw", context.packageName)
            val resId = if (requestedResId != 0) {
                requestedResId
            } else {
                context.resources.getIdentifier("salawat", "raw", context.packageName)
            }
            if (resId == 0) {
                if (wakeLock?.isHeld == true) wakeLock.release()
                return
            }

            // Set phone volume to 100% MAXIMUM hardware volume as requested by user
            setMaxVolume(context)

            val mediaPlayer = MediaPlayer.create(context, resId) ?: run {
                if (wakeLock?.isHeld == true) wakeLock.release()
                return
            }

            // Bind wake lock to MediaPlayer so Android does not sleep during playback
            mediaPlayer.setWakeMode(context.applicationContext, PowerManager.PARTIAL_WAKE_LOCK)

            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            mediaPlayer.setAudioAttributes(audioAttributes)
            mediaPlayer.setVolume(1.0f, 1.0f)

            mediaPlayer.setOnCompletionListener { mp ->
                try {
                    mp.stop()
                    mp.release()
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                cancelNotification(context)
                if (wakeLock?.isHeld == true) {
                    wakeLock.release()
                }
            }

            mediaPlayer.setOnErrorListener { mp, _, _ ->
                try {
                    mp.release()
                } catch (e: Exception) {}
                cancelNotification(context)
                if (wakeLock?.isHeld == true) {
                    wakeLock.release()
                }
                true
            }

            mediaPlayer.start()
        } catch (e: Exception) {
            e.printStackTrace()
            if (wakeLock?.isHeld == true) {
                wakeLock.release()
            }
        }
    }

    fun showNotification(context: Context, text: String = "صَلِّ عَلَى مُحَمَّد") {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "تذكير دوري بالصلاة على النبي والأذكار كل نصف ساعة"
                enableVibration(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }
            notificationManager.createNotificationChannel(channel)
        }

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentTitle("الصلاة على النبي ﷺ والأذكار")
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setSilent(true)

        notificationManager.notify(NOTIFICATION_ID, builder.build())
    }

    fun cancelNotification(context: Context) {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        notificationManager?.cancel(NOTIFICATION_ID)
    }
}
