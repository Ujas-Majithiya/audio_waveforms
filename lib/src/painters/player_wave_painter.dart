import 'package:flutter/material.dart';

class PlayerWavePainter extends CustomPainter {
  final List<double> waveformData;
  final bool showTop;
  final bool showBottom;
  final double animValue;
  final double scaleFactor;
  final Color waveColor;
  final StrokeCap waveCap;
  final double waveThickness;
  final Shader? fixedWaveGradient;
  final Shader? liveWaveGradient;
  final double spacing;
  final Offset totalBackDistance;
  final Offset dragOffset;
  final double audioProgress;
  final Color liveWaveColor;
  final VoidCallback pushBack;
  final bool callPushback;
  final double emptySpace;

  PlayerWavePainter({
    required this.waveformData,
    required this.showTop,
    required this.showBottom,
    required this.animValue,
    required this.scaleFactor,
    required this.waveColor,
    required this.waveCap,
    required this.waveThickness,
    required this.dragOffset,
    required this.totalBackDistance,
    required this.spacing,
    required this.audioProgress,
    required this.liveWaveColor,
    required this.pushBack,
    required this.callPushback,
    this.liveWaveGradient,
    this.fixedWaveGradient,
  })  : fixedWavePaint = Paint()
          ..color = waveColor
          ..strokeWidth = waveThickness
          ..strokeCap = waveCap
          ..shader = fixedWaveGradient,
        liveWavePaint = Paint()
          ..color = liveWaveColor
          ..strokeWidth = waveThickness
          ..strokeCap = waveCap
          ..shader = liveWaveGradient,
        emptySpace = spacing / 2;

  Paint fixedWavePaint;
  Paint liveWavePaint;

  @override
  void paint(Canvas canvas, Size size) {
    _drawFixedWave(size, canvas);
  }

  @override
  bool shouldRepaint(PlayerWavePainter oldDelegate) => true;

  void _drawFixedWave(Size size, Canvas canvas) {
    final lenth = waveformData.length;
    if (lenth * audioProgress * spacing >
        size.width + totalBackDistance.dx - dragOffset.dx && callPushback) {
      pushBack();
    }
    for (int i = 0; i < lenth; i++) {
      canvas.drawLine(
        Offset(
          i * spacing + dragOffset.dx - totalBackDistance.dx + emptySpace,
          size.height / 2 +
              (showBottom ? ((waveformData[i] * animValue)) * scaleFactor : 0),
        ),
        Offset(
          i * spacing + dragOffset.dx - totalBackDistance.dx + emptySpace,
          size.height / 2 +
              (showTop ? -((waveformData[i] * animValue)) * scaleFactor : 0),
        ),
        i < audioProgress * lenth ? liveWavePaint : fixedWavePaint,
      );
    }
  }
}
