package com.example

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager

class VolumeReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val streamType = AudioManager.STREAM_MUSIC

        when (intent.action) {
            ACTION_VOL_UP -> {
                try {
                    audioManager.adjustStreamVolume(streamType, AudioManager.ADJUST_RAISE, AudioManager.FLAG_SHOW_UI)
                } catch (e: SecurityException) { }
            }
            ACTION_VOL_DOWN -> {
                try {
                    audioManager.adjustStreamVolume(streamType, AudioManager.ADJUST_LOWER, AudioManager.FLAG_SHOW_UI)
                } catch (e: SecurityException) { }
            }
            ACTION_MUTE -> {
                try {
                    // Let the system track mute state; a volume of 0 is not the same as muted.
                    audioManager.adjustStreamVolume(streamType, AudioManager.ADJUST_TOGGLE_MUTE, AudioManager.FLAG_SHOW_UI)
                } catch (e: SecurityException) { }
            }
        }
    }

    companion object {
        const val ACTION_VOL_UP = "com.example.VOL_UP"
        const val ACTION_VOL_DOWN = "com.example.VOL_DOWN"
        const val ACTION_MUTE = "com.example.MUTE"
    }
}
