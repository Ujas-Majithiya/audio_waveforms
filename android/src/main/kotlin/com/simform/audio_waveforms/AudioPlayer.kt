package com.simform.audio_waveforms

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.MediaPlayer.SEEK_PREVIOUS_SYNC
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodChannel
import java.lang.Exception


class AudioPlayer(channel: MethodChannel) {
    private val LOG_TAG = "AudioWaveforms"
    private var handler: Handler = Handler(Looper.getMainLooper())
    private var mediaPlayers = mutableMapOf<String, MediaPlayer?>()
    private var runnable = mutableMapOf<String, Runnable?>()
    private var methodChannel = channel


    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun preparePlayer(
        result: MethodChannel.Result,
        path: String?,
        volume: Float?,
        key: String?
    ) {
        //TODO: meta data of song
        if (key != null && path != null) {
            mediaPlayers[key] = MediaPlayer()
            mediaPlayers[key]?.setDataSource(path)
            mediaPlayers[key]?.setAudioAttributes(
                AudioAttributes
                    .Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            mediaPlayers[key]?.prepare()
            mediaPlayers[key]?.setVolume(volume ?: 1F, volume ?: 1F)
            result.success(true)
        } else {
            result.success(false)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun seekToPosition(result: MethodChannel.Result, progress: Long?, key: String?) {
        if (progress != null && key != null) {
            mediaPlayers[key]?.seekTo(progress, SEEK_PREVIOUS_SYNC)
            result.success(true)
        } else {
            result.success(false)
        }
    }

    fun start(result: MethodChannel.Result, seekToStart: Boolean, key: String?) {

        try {
            mediaPlayers[key]?.start()
            result.success(true)
            startListening(result, key)
        } catch (e: Exception) {
            result.error(LOG_TAG, "Can not start the player", e.toString())
        }
    }

    fun getDuration(result: MethodChannel.Result, durationType: DurationType, key: String?) {
        try {
            if (durationType == DurationType.Current) {
                result.success(mediaPlayers[key]?.currentPosition)
            } else {
                result.success(mediaPlayers[key]?.duration)
            }

        } catch (e: Exception) {
            result.error(LOG_TAG, "Can not get duration", e.toString())
        }
    }

    fun stop(result: MethodChannel.Result, key: String?) {
        if (key != null) {
            try {
                stopListening(result,key)
                mediaPlayers[key]?.stop()
                mediaPlayers[key]?.reset()
                mediaPlayers[key]?.release()
                result.success(true)
            } catch (e: Exception) {
                result.error(LOG_TAG, "Failed to stop the player", e.toString())
            }
        }

    }


    fun pause(result: MethodChannel.Result, key: String?) {
        if (key != null) {
            try {
                stopListening(result,key)
                mediaPlayers[key]?.pause()
                result.success(true)
            } catch (e: Exception) {
                result.error(LOG_TAG, "Failed to pause the player", e.toString())
            }
        }

    }

    fun setVolume(volume: Float?, result: MethodChannel.Result, key: String?) {
        try {
            if (volume != null && key != null) {
                mediaPlayers[key]?.setVolume(volume, volume)
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun startListening(result: MethodChannel.Result, key: String?) {
        if (key != null) {
            runnable[key] = object : Runnable {
                override fun run() {
                    if (mediaPlayers[key]?.currentPosition != null) {
                        val args: MutableMap<String, Any?> = HashMap()
                        args[Constants.current] =
                            mediaPlayers[key]?.currentPosition
                        args[Constants.playerKey] = key
                        methodChannel.invokeMethod("onCurrentDuration", args)
                        handler.postDelayed(this, 200)
                    } else {
                        result.error("", "Can't get current Position of player", "")
                    }
                }
            }
            handler.post(runnable[key]!!)
        }

    }

    private fun continueListening(result: MethodChannel.Result, key: String?){

    }
    fun stopListening(result: MethodChannel.Result, key: String?) {
        runnable[key]?.let { handler.removeCallbacks(it) }
    }
}
