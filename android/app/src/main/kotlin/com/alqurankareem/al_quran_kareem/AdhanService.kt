package com.alqurankareem.al_quran_kareem

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.database.ContentObserver
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationCompat

class AdhanService : Service() {

    companion object {
        const val NOTIFICATION_ID = 9001
        const val CHANNEL_ID = "adhan_service_channel"

        @Volatile
        var isRunning = false
            private set

        fun start(context: Context) {
            val intent = Intent(context, AdhanService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, AdhanService::class.java))
        }
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: android.media.AudioFocusRequest? = null
    private val audioFocusListener = AudioManager.OnAudioFocusChangeListener { change ->
        if (change == AudioManager.AUDIOFOCUS_LOSS ||
            change == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT) {
            stopSelf()
        }
    }
    // MediaSession to receive media button events (e.g., stop via headset button)
    private var mediaSession: android.media.session.MediaSession? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        playAdhan()
        return START_NOT_STICKY
    }

    private fun playAdhan() {
        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
        this.audioManager = audioManager
        if (!requestAudioFocus(audioManager)) {
            stopSelf()
            return
        }
        audioManager.setStreamVolume(AudioManager.STREAM_ALARM,        audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM),        0)
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC,        audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC),        0)
        audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, audioManager.getStreamMaxVolume(AudioManager.STREAM_NOTIFICATION), 0)
        audioManager.setStreamVolume(AudioManager.STREAM_RING,         audioManager.getStreamMaxVolume(AudioManager.STREAM_RING),         0)

        wakeLock = (getSystemService(POWER_SERVICE) as? PowerManager)
            ?.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "AlQuranKareem::AdhanServiceWakeLock")
        wakeLock?.acquire(10 * 60 * 1000L)

        val player = MediaPlayer.create(this, R.raw.adhan) ?: run {
            stopSelf()
            return
        }

        mediaPlayer = player
        player.setWakeMode(applicationContext, PowerManager.PARTIAL_WAKE_LOCK)
        player.setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build()
        )
        player.setVolume(1.0f, 1.0f)

        player.setOnCompletionListener {
            it.release()
            mediaPlayer = null
            stopSelf()
        }
        player.setOnErrorListener { mp, _, _ ->
            mp.release()
            mediaPlayer = null
            stopSelf()
            true
        }

// Removed volume observer that stopped service on any system setting change; Adhan now plays uninterrupted.
        // If you need to stop playback via volume keys, handle it in the UI layer.
        // No ContentObserver registration here.

        player.start()
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        // Release MediaSession if it was created
        mediaSession?.release()
        mediaSession = null
        mediaPlayer?.let {
            try { it.stop() } catch (_: Exception) {}
            it.release()
        }
        mediaPlayer = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { audioManager?.abandonAudioFocusRequest(it) }
            audioFocusRequest = null
        } else {
            audioManager?.abandonAudioFocus(audioFocusListener)
        }
        audioManager = null
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
        (getSystemService(NOTIFICATION_SERVICE) as? NotificationManager)?.cancel(NOTIFICATION_ID)
    }

    private fun requestAudioFocus(manager: AudioManager): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = android.media.AudioFocusRequest.Builder(
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT,
            ).setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build(),
            ).setOnAudioFocusChangeListener(audioFocusListener).build()
            audioFocusRequest = request
            return manager.requestAudioFocus(request) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
        @Suppress("DEPRECATION")
        return manager.requestAudioFocus(
            audioFocusListener,
            AudioManager.STREAM_ALARM,
            AudioManager.AUDIOFOCUS_GAIN_TRANSIENT,
        ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, "الاذان", NotificationManager.IMPORTANCE_LOW)
            (getSystemService(NotificationManager::class.java)).createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentTitle("حان وقت الصلاة")
            .setContentText("الاذان يشغل الان")
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setOngoing(true)
            .setAutoCancel(false)
            .setSilent(true)
            .build()
    }
}
