package com.alqurankareem.al_quran_kareem

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import java.util.TimeZone

class AdhanBootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != Intent.ACTION_MY_PACKAGE_REPLACED &&
            intent.action != "android.intent.action.QUICKBOOT_POWERON" &&
            intent.action != "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            return
        }

        val preferences = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE,
        )
        val settingsJson = preferences.getString("flutter.prayer_settings", null) ?: return
        val settings = JSONObject(settingsJson)
        val city = settings.optString("city")
        val country = settings.optString("country")
        if (city.isEmpty() || country.isEmpty()) return

        val timeZone = TimeZone.getTimeZone("Africa/Cairo")
        val now = Calendar.getInstance(timeZone)
        val dateFormat = SimpleDateFormat("dd-MM-yyyy", Locale.US).apply {
            this.timeZone = timeZone
        }
        val prayerNames = arrayOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha")
        val enabledKeys = arrayOf(
            "fajr_enabled",
            "dhuhr_enabled",
            "asr_enabled",
            "maghrib_enabled",
            "isha_enabled",
        )
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE)
            as? AlarmManager ?: return

        for (dayOffset in 0 until 7) {
            val date = (now.clone() as Calendar).apply {
                add(Calendar.DAY_OF_YEAR, dayOffset)
            }
            val cacheKey = "flutter.prayer_times_${city}_${country}_${dateFormat.format(date.time)}"
            val timingsJson = preferences.getString(cacheKey, null) ?: continue
            val timings = JSONObject(timingsJson)
            val dayOfYear = date.get(Calendar.DAY_OF_YEAR) - 1

            for (index in prayerNames.indices) {
                if (!settings.optBoolean(enabledKeys[index], true)) continue
                val timeParts = timings.optString(prayerNames[index]).split(":")
                if (timeParts.size < 2) continue
                val hour = timeParts[0].toIntOrNull() ?: continue
                val minute = timeParts[1].toIntOrNull() ?: continue
                val trigger = (date.clone() as Calendar).apply {
                    set(Calendar.HOUR_OF_DAY, hour)
                    set(Calendar.MINUTE, minute)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }
                if (trigger.timeInMillis <= System.currentTimeMillis()) continue

                val id = 1000 + (dayOfYear * 10) + index
                val alarmIntent = Intent(context, AdhanAlarmReceiver::class.java).apply {
                    action = "com.alqurankareem.ACTION_ADHAN_ALARM"
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    id,
                    alarmIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )

                // Use setAlarmClock - strongest alarm, 100% Doze exempt
                val showIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                    ?: Intent(context, AdhanAlarmReceiver::class.java)
                val showPendingIntent = PendingIntent.getActivity(
                    context,
                    id + 5000,
                    showIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                try {
                    val alarmClockInfo = AlarmManager.AlarmClockInfo(trigger.timeInMillis, showPendingIntent)
                    alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
                } catch (e: Exception) {
                    // Fallback
                    try {
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                            alarmManager.setExactAndAllowWhileIdle(
                                AlarmManager.RTC_WAKEUP,
                                trigger.timeInMillis,
                                pendingIntent,
                            )
                        } else {
                            alarmManager.setExact(
                                AlarmManager.RTC_WAKEUP,
                                trigger.timeInMillis,
                                pendingIntent,
                            )
                        }
                    } catch (_: Exception) {}
                }
            }
        }
    }
}
