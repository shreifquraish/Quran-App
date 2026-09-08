package com.alqurankareem.al_quran_kareem

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val SALAWAT_CHANNEL = "com.alqurankareem/salawat"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Salawat Native Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SALAWAT_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleSalawat" -> {
                    SalawatAlarmReceiver.scheduleNextAlarm(applicationContext)
                    result.success(true)
                }
                "cancelSalawat" -> {
                    SalawatAlarmReceiver.cancelAlarms(applicationContext)
                    result.success(true)
                }
                "testSalawat" -> {
                    val receiver = SalawatAlarmReceiver()
                    receiver.playSalawatVoice(applicationContext, null, "salawat")
                    result.success(true)
                }
                "setMaxVolume" -> {
                    SalawatAlarmReceiver.setMaxVolume(applicationContext)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.alqurankareem/adhan").setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAdhan" -> {
                    val id = call.argument<Int>("id") ?: return@setMethodCallHandler result.error("INVALID_ID", "Missing alarm id", null)
                    val timestamp = call.argument<Number>("timestamp")?.toLong()
                        ?: return@setMethodCallHandler result.error("INVALID_TIME", "Missing alarm timestamp", null)
                    AdhanAlarmReceiver.schedule(applicationContext, id, timestamp)
                    result.success(true)
                }
                "cancelAdhan" -> {
                    AdhanAlarmReceiver.cancelAll(applicationContext)
                    result.success(true)
                }
                "testAdhan" -> {
                    AdhanAlarmReceiver().onReceive(
                        applicationContext,
                        Intent("com.alqurankareem.ACTION_ADHAN_TEST"),
                    )
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Tasmee native channel removed (feature deleted)
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
