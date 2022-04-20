extension DurationExtension on Duration {
  ///converts duration to HH:MM:SS format
  String toHHMMSS() => toString().split('.').first.padLeft(8, "0");
}

extension IntExtension on int {
  ///converts total seconds to MM:SS format
  String toMMSS() =>
      '${(this ~/ 60).toString().padLeft(2, '0')}:${(this % 60).toString().padLeft(2, '0')}';
}

///state of recorer
enum RecorderState { initialized, recording, paused, stopped }

///Audio codec
enum Encoder {
  ///Default
  aac,
  aac_ld,
  aac_he,
  amr_nb,
  amr_wb,

  ///requires android Q or ios 11.
  ///For android < 11 Encoder.aac will be used
  opus
}

///Not using
///
///TODO:check how to do it on ios same as android
enum AudioOutputFormat {
  ///Default
  mpeg4,
  aac_adts,
  amr_nb,
  amr_wb,

  ///if android version is not greater or equal to [O], mpeg4 will be set
  mpeg_2_ts,

  ///if android version is not greater or equal to [Q], mpeg4 will be set
  ogg,
  three_gpp,

  ///if android version is not greater or equal to [Q], mpeg4 will be set
  webm
}

///States of audio player
enum PlayerState {
  ///When reading of audio file is completed
  readingComplete,

  ///When player is [initialised]
  initialized,

  ///When player is playing the audio file
  playing,

  ///When player is resumed. This state is only on [flutter] side.
  resumed,

  ///When player is paused.
  paused,

  ///when player is stopped. Default state of any player ([uninitialised]).
  stopped
}

///There are two type duration which we can get.
///
/// 1. Max duration is [full] duration of audio file
///
/// 2. Current duration is how much audio has been played
enum DurationType {
  current,

  ///Default
  max
}
