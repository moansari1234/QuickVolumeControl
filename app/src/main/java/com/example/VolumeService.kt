package com.example

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class VolumeService : Service() {

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = createNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(1, notification, android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(1, notification)
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Volume Control",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Quick volume control actions"
                setShowBadge(false)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val volDownIntent = Intent(this, VolumeReceiver::class.java).apply { action = VolumeReceiver.ACTION_VOL_DOWN }
        val volDownPendingIntent = PendingIntent.getBroadcast(this, 1, volDownIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        val volUpIntent = Intent(this, VolumeReceiver::class.java).apply { action = VolumeReceiver.ACTION_VOL_UP }
        val volUpPendingIntent = PendingIntent.getBroadcast(this, 2, volUpIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        val muteIntent = Intent(this, VolumeReceiver::class.java).apply { action = VolumeReceiver.ACTION_MUTE }
        val mutePendingIntent = PendingIntent.getBroadcast(this, 3, muteIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        val expandIntent = Intent(this, VolumePanelActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val expandPendingIntent = PendingIntent.getActivity(this, 4, expandIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_volume_up)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(R.drawable.ic_volume_down, "Down", volDownPendingIntent)
            .addAction(R.drawable.ic_volume_off, "Mute", mutePendingIntent)
            .addAction(R.drawable.ic_volume_up, "Up", volUpPendingIntent)
            .addAction(R.drawable.ic_expand, "Expand", expandPendingIntent)
            .setStyle(androidx.media.app.NotificationCompat.MediaStyle().setShowActionsInCompactView(0, 1, 2))
            .build()
    }

    companion object {
        const val CHANNEL_ID = "volume_control_channel"
    }
}
