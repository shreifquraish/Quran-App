package com.alqurankareem.al_quran_kareem

import android.content.Intent
import android.content.Context
import android.media.AudioManager
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val SALAWAT_CHANNEL = "com.alqurankareem/salawat"
    private var salawatChannel: MethodChannel? = null

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val isVolumeKey = event.keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
            event.keyCode == KeyEvent.KEYCODE_VOLUME_DOWN ||
            event.keyCode == KeyEvent.KEYCODE_VOLUME_MUTE
        if (isVolumeKey && event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
            // Stop only the audio that is currently playing
            if (SalawatAlarmReceiver.isPlaying()) {
                SalawatAlarmReceiver.stopPlayback(applicationContext)
            }
            if (AdhanAlarmReceiver.isPlaying()) {
                AdhanAlarmReceiver.stopPlayback(applicationContext)
            }
            salawatChannel?.invokeMethod("volumeKeyPressed", null)
        }
        return super.dispatchKeyEvent(event)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Salawat Native Channel
        salawatChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SALAWAT_CHANNEL)
        salawatChannel?.setMethodCallHandler { call, result ->
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
                "canPlayAudio" -> {
                    result.success(!SalawatAlarmReceiver.isAnotherAudioActive(applicationContext))
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
                    AdhanAlarmReceiver().schedule(applicationContext, id, timestamp)
                    result.success(true)
                }
                "cancelAdhan" -> {
                    AdhanAlarmReceiver().cancelAll(applicationContext)
                    result.success(true)
                }
                "testAdhan" -> {
                    if (isAnotherAudioActive()) {
                        return@setMethodCallHandler result.success(false)
                    }
                    AdhanAlarmReceiver().onReceive(
                        applicationContext,
                        Intent("com.alqurankareem.ACTION_ADHAN_TEST"),
                    )
                    result.success(true)
                }
                "canPlayAudio" -> {
                    result.success(!isAnotherAudioActive())
                }
                "stopAdhan" -> {
                    AdhanAlarmReceiver.stopPlayback(applicationContext)
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

    private fun isAnotherAudioActive(): Boolean {
        return try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            audioManager.isMusicActive ||
                audioManager.mode == AudioManager.MODE_IN_CALL ||
                audioManager.mode == AudioManager.MODE_IN_COMMUNICATION
        } catch (_: Exception) {
            false
        }
    }

}

