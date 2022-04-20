package com.simform.audio_waveforms

enum class DurationType { Current, Max }

object Constants {
    const val initRecorder = "initRecorder"
    const val startRecording = "startRecording"
    const val stopRecording = "stopRecording"
    const val pauseRecording = "pauseRecording"
    const val resumeRecording = "resumeRecording"
    const val getDecibel = "getDecibel"
    const val checkPermission = "checkPermission"
    const val path = "path"
    const val LOG_TAG = "AudioWaveforms"
    const val methodChannelName = "simform_audio_waveforms_plugin/methods"
    const val enCoder = "enCoder"
    const val sampleRate = "sampleRate"
    const val fileNameFormat = "dd-MM-yy-hh-mm-ss"
    const val preparePlayer = "preparePlayer"
    const val startPlayer = "startPlayer"
    const val stopPlayer = "stopPlayer"
    const val pausePlayer = "pausePlayer"
    const val seekTo = "seekTo"
    const val progress = "progress"
    const val setVolume = "setVolume"
    const val volume = "volume"
    const val getDuration = "getDuration"
    const val durationType = "durationType"
    const val seekToStart = "seekToStart"
    const val playerKey = "playerKey"
    const val current = "current"
}