import 'package:audio_waveforms/src/base/wave_clipper.dart';
import 'package:audio_waveforms/src/painters/player_wave_painter.dart';
import 'package:flutter/material.dart';

import '../audio_waveforms.dart';

class AudioFileWaveforms extends StatefulWidget {
  /// A size to define height and width of waveform.
  final Size size;

  /// A PlayerController having different controls for audio player.
  final PlayerController playerController;

  /// Directly draws waveforms from this data. Extracted waveform data
  /// is ignored if waveform data is provided from this parameter.
  final List<double> waveformData;

  /// When this flag is set to true, new waves are drawn as soon as new
  /// waveform data is available from [onCurrentExtractedWaveformData].
  /// If this flag is set to false then waveforms will be drawn after waveform
  /// extraction is fully completed.
  ///
  /// This flag is ignored if waveformData is directly provided.
  ///
  /// See documentation of extractWaveformData in [PlayerController] to
  /// determine which value to choose.
  ///
  /// Defaults to true.
  final bool continousWaveform;

  /// A PlayerWaveStyle instance controls how waveforms should look.
  final PlayerWaveStyle playerWaveStyle;

  /// Provides padding around waveform.
  final EdgeInsets? padding;

  /// Provides margin around waveform.
  final EdgeInsets? margin;

  /// Provides box decoration to the container having waveforms.
  final BoxDecoration? decoration;

  /// Color which is applied in to background of the waveform.
  /// If decoration is used then use color in it.
  final Color? backgroundColor;

  /// Duration for animation. Defaults to 500 milliseconds.
  final Duration animationDuration;

  /// Curve for animation. Defaults to Curves.ease
  final Curve animationCurve;

  /// A clipping behaviour which is applied to container having waveforms.
  final Clip clipBehavior;

  final SeekGestureType seekGestureType;

  /// Generate waveforms from audio file. You play those audio file using
  /// [PlayerController].
  ///
  /// When you play the audio file, another waveform
  /// will drawn on top of it to show
  /// how much audio has been played and how much is left.
  ///
  /// With seeking gesture enabled, playing audio can be seeked to
  /// any position using gestures.
  const AudioFileWaveforms({
    Key? key,
    required this.size,
    required this.playerController,
    this.waveformData = const [],
    this.continousWaveform = true,
    this.playerWaveStyle = const PlayerWaveStyle(),
    this.padding,
    this.margin,
    this.decoration,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.ease,
    this.clipBehavior = Clip.none,
    this.seekGestureType = SeekGestureType.scrollAndTap,
  }) : super(key: key);

  @override
  State<AudioFileWaveforms> createState() => _AudioFileWaveformsState();
}

class _AudioFileWaveformsState extends State<AudioFileWaveforms>
    with SingleTickerProviderStateMixin {
  late AnimationController _growingWaveController;
  late Animation<double> _growAnimation;

  double _growAnimationProgress = 0.0;
  final ValueNotifier<int> _seekProgress = ValueNotifier(0);
  bool showSeekLine = false;

  late EdgeInsets? margin;
  late EdgeInsets? padding;
  late BoxDecoration? decoration;
  late Color? backgroundColor;
  late Duration? animationDuration;
  late Curve? animationCurve;
  late Clip? clipBehavior;
  late PlayerWaveStyle? playerWaveStyle;

  @override
  void initState() {
    super.initState();
    _initialiseVariables();
    _growingWaveController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _growAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _growingWaveController,
      curve: widget.animationCurve,
    ));

    _growingWaveController.forward();
    _growAnimation.addListener(() {
      if (mounted) {
        setState(() {
          _growAnimationProgress = _growAnimation.value;
        });
      }
    });
    widget.playerController.onCurrentDurationChanged.listen((event) {
      _seekProgress.value = event;
      _updatePlayerPercent(widget.size);
    });

    if (widget.waveformData.isNotEmpty) {
      _addWaveformData(widget.waveformData);
    } else {
      if (widget.playerController.waveformData.isNotEmpty) {
        _addWaveformData(widget.playerController.waveformData);
      }
      //TODO: dispose this
      if (!widget.continousWaveform) {
        widget.playerController.addListener(() {
          _addWaveformData(widget.playerController.waveformData);
        });
      } else {
        widget.playerController.onCurrentExtractedWaveformData
            .listen(_addWaveformData);
      }
    }
  }

  @override
  void dispose() {
    widget.playerController.removeListener(() {});
    _growAnimation.removeListener(() {});
    _growingWaveController.dispose();
    super.dispose();
  }

  double _audioProgress = 0.0;

  Offset _totalBackDistance = Offset.zero;
  Offset _dragOffset = Offset.zero;

  double _initialDragPosition = 0.0;
  double _scrollDirection = 0.0;

  bool _isScrolled = false;

  final List<double> _waveformData = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      decoration: widget.decoration,
      clipBehavior: widget.clipBehavior,
      child: GestureDetector(
        onHorizontalDragUpdate: widget.seekGestureType != SeekGestureType.none
            ? _handleDragGestures
            : null,
        onHorizontalDragStart: widget.seekGestureType != SeekGestureType.none
            ? _handTapGestures
            : null,
        onHorizontalDragEnd: (_) {
          if (_scrollDirection < 0) {
            _isScrolled = false;
          }
        },
        onTapUp: widget.seekGestureType == SeekGestureType.scrollAndTap
            ? _handleTap
            : null,
        child: ClipPath(
          // TODO: Remove static clipper when duration labels are added
          clipper: WaveClipper(0),
          child: RepaintBoundary(
            child: ValueListenableBuilder<int>(
              builder: (context, _, __) {
                return CustomPaint(
                  isComplex: true,
                  painter: PlayerWavePainter(
                    waveformData: _waveformData,
                    spacing: widget.playerWaveStyle.spacing,
                    waveColor: widget.playerWaveStyle.fixedWaveColor,
                    fixedWaveGradient: widget.playerWaveStyle.fixedWavegradient,
                    scaleFactor: widget.playerWaveStyle.scaleFactor,
                    waveCap: widget.playerWaveStyle.waveCap,
                    showBottom: widget.playerWaveStyle.showBottom,
                    showTop: widget.playerWaveStyle.showTop,
                    waveThickness: widget.playerWaveStyle.waveThickness,
                    animValue: _growAnimationProgress,
                    totalBackDistance: _totalBackDistance,
                    dragOffset: _dragOffset,
                    audioProgress: _audioProgress,
                    liveWaveColor: widget.playerWaveStyle.liveWaveColor,
                    liveWaveGradient: widget.playerWaveStyle.liveWaveGradient,
                    callPushback: !_isScrolled,
                    pushBack: _pushBackWave,
                  ),
                  size: widget.size,
                );
              },
              valueListenable: _seekProgress,
            ),
          ),
        ),
      ),
    );
  }

  void _addWaveformData(List<double> data) {
    setState(() {
      _waveformData
        ..clear()
        ..addAll(data);
    });
  }

  void _handleDragGestures(DragUpdateDetails details) {
    switch (widget.seekGestureType) {
      case SeekGestureType.seekAndTap:
        _handleScrubberSeekUpdate(details);
        break;
      case SeekGestureType.scrollAndTap:
        _handleScrollUpdate(details);
        break;
      case SeekGestureType.none:
        //This will never be reached
        break;
    }
  }

  void _handTapGestures(DragStartDetails details) {
    switch (widget.seekGestureType) {
      case SeekGestureType.seekAndTap:
        _handleScrubberSeekStart(details);
        break;
      case SeekGestureType.scrollAndTap:
        _handleHorizontalDragStart(details);
        break;
      case SeekGestureType.none:
        //This will never be reached
        break;
    }
  }

  /// This method handles continues seek gesture
  void _handleScrubberSeekUpdate(DragUpdateDetails details) {
    var proportion = details.localPosition.dx / widget.size.width;
    var seekPosition = widget.playerController.maxDuration * proportion;

    widget.playerController.seekTo(seekPosition.toInt());
    setState(() {});
  }

  /// This method handles tap seek gesture
  void _handleScrubberSeekStart(DragStartDetails details) {
    var proportion = details.localPosition.dx / widget.size.width;
    var seekPosition = widget.playerController.maxDuration * proportion;

    widget.playerController.seekTo(seekPosition.toInt());
    setState(() {});
  }

  /// This method handles tap seek gesture for scrollAndTap
  void _handleTap(TapUpDetails details) {
    /// Idicates percentage of duration with respect to max duration.
    var proportion = 0.0;

    ///This varialble indicates location of first wave
    var start = -_totalBackDistance.dx +
        _dragOffset.dx -
        widget.playerWaveStyle.spacing;

    /// Less than 0 means scrolled ahead and greater 0 means scrolled back.
    /// localPosition indicates where pointer has been tapped in the tapple
    /// area. Which we can use to calculate proportion relatuve to max
    /// audio duration.
    if (start < 0) {
      proportion = (start.abs() + details.localPosition.dx) /
          (_waveformData.length * widget.playerWaveStyle.spacing);
    } else {
      proportion = (details.localPosition.dx - start) /
          (_waveformData.length * widget.playerWaveStyle.spacing);
    }

    /// Percentage can't be less than 0 and greater than 1.
    if (proportion < 0 || proportion > 1) return;

    var seekPosition = widget.playerController.maxDuration * proportion;
    widget.playerController.seekTo(seekPosition.toInt());

    setState(() {});
  }

  ///This method handles horizontal scrolling of the wave
  void _handleScrollUpdate(DragUpdateDetails details) {
    /// Direction of the scroll. Negative value indicates scroll left to right
    /// and positive value indicates scroll right to left
    _scrollDirection = details.localPosition.dx - _initialDragPosition;
    widget.playerController.setRefresh(false);
    _isScrolled = true;

    ///left to right
    if (-_totalBackDistance.dx + _dragOffset.dx + details.delta.dx <
            (widget.size.width / 2) &&
        _scrollDirection > 0) {
      setState(() => _dragOffset += details.delta);
    }

    ///right to left
    else if (-_totalBackDistance.dx +
                _dragOffset.dx +
                (widget.playerWaveStyle.spacing * _waveformData.length) +
                details.delta.dx >
            (widget.size.width / 2) &&
        _scrollDirection < 0) {
      setState(() => _dragOffset += details.delta);
    }
  }

  ///This will help-out to determine direction of the scroll
  void _handleHorizontalDragStart(DragStartDetails details) {
    _initialDragPosition = details.localPosition.dx;
  }

  /// This initialises variable in [initState] so that everytime current duration
  /// gets updated it doesn't re assign them to same values.
  void _initialiseVariables() {
    if (widget.playerController.waveformData.isEmpty) {
      widget.playerController.waveformData.addAll(widget.waveformData);
    }
    showSeekLine = false;
    margin = widget.margin;
    padding = widget.padding;
    decoration = widget.decoration;
    backgroundColor = widget.backgroundColor;
    animationDuration = widget.animationDuration;
    animationCurve = widget.animationCurve;
    clipBehavior = widget.clipBehavior;
    playerWaveStyle = widget.playerWaveStyle;
  }

  /// calculates seek progress
  void _updatePlayerPercent(Size size) {
    if (widget.playerController.maxDuration == 0) return;
    _audioProgress = _seekProgress.value / widget.playerController.maxDuration;
  }

  ///This will handle pushing back the wave when it reaches to middle/end of the
  ///given size.width.
  ///
  ///This will also handle refreshing the wave after scrolled
  void _pushBackWave() {
    if (!_isScrolled) {
      _totalBackDistance =
          _totalBackDistance + Offset(widget.playerWaveStyle.spacing, 0.0);
    }
    if (widget.playerController.shouldClearLabels) {
      _initialDragPosition = 0.0;
      _totalBackDistance = Offset.zero;
      _dragOffset = Offset.zero;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }
}
