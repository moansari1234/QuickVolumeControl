package com.example

import android.content.Context
import android.media.AudioManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.example.ui.theme.MyApplicationTheme

class VolumePanelActivity : ComponentActivity() {

    private lateinit var audioManager: AudioManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        setContent {
            MyApplicationTheme {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .clickable { finish() }, // Close when clicking outside
                    contentAlignment = Alignment.Center
                ) {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth(0.9f)
                            .clickable(enabled = false) {}, // Prevent closing when clicking inside card
                        shape = RoundedCornerShape(16.dp),
                        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                    ) {
                        Column(
                            modifier = Modifier.padding(24.dp),
                            verticalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            Text(
                                "Volume Controls",
                                style = MaterialTheme.typography.titleLarge,
                                modifier = Modifier.padding(bottom = 8.dp)
                            )

                            VolumeSliderRow(
                                icon = Icons.Default.PlayArrow,
                                title = "Media",
                                streamType = AudioManager.STREAM_MUSIC,
                                audioManager = audioManager
                            )
                            VolumeSliderRow(
                                icon = Icons.Default.Phone,
                                title = "Ring",
                                streamType = AudioManager.STREAM_RING,
                                audioManager = audioManager
                            )
                            VolumeSliderRow(
                                icon = Icons.Default.Notifications,
                                title = "Notification",
                                streamType = AudioManager.STREAM_NOTIFICATION,
                                audioManager = audioManager
                            )
                            VolumeSliderRow(
                                icon = Icons.Default.DateRange,
                                title = "Alarm",
                                streamType = AudioManager.STREAM_ALARM,
                                audioManager = audioManager
                            )
                            
                            Spacer(modifier = Modifier.height(8.dp))
                            
                            TextButton(
                                onClick = { finish() },
                                modifier = Modifier.align(Alignment.End)
                            ) {
                                Text("Close")
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun VolumeSliderRow(
    icon: ImageVector,
    title: String,
    streamType: Int,
    audioManager: AudioManager
) {
    val maxVolume = audioManager.getStreamMaxVolume(streamType)
    var currentVolume by remember { mutableStateOf(audioManager.getStreamVolume(streamType).toFloat()) }

    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.fillMaxWidth()
    ) {
        Icon(
            imageVector = icon,
            contentDescription = title,
            modifier = Modifier.size(24.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.width(16.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(text = title, style = MaterialTheme.typography.bodyMedium)
            Slider(
                value = currentVolume,
                onValueChange = { newValue ->
                    currentVolume = newValue
                    try {
                        audioManager.setStreamVolume(streamType, newValue.toInt(), 0)
                    } catch (e: SecurityException) {
                        // User needs to grant Do Not Disturb permission
                    }
                },
                valueRange = 0f..maxVolume.toFloat(),
                steps = if (maxVolume > 0) maxVolume - 1 else 0
            )
        }
    }
}
