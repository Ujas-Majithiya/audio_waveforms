import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final List<double> waveData;
  final Color waveColor;
  final bool showMiddleLine;
  final double spacing;
  final double initialPosition;
  final bool showTop;
  final bool showBottom;
  final double scaleFactor;
  final double bottomPadding;
  final StrokeCap waveCap;
  final Color middleLineColor;
  final double middleLineThickness;
  final Offset totalBackDistance;
  final Offset dragOffset;
  final double waveThickness;
  final VoidCallback pushBack;
  final bool callPushback;
  final bool extendWaveform;

  final Paint _wavePaint;
  final Paint _linePaint;

  WavePainter({
    required this.waveData,
    required this.waveColor,
    required this.showMiddleLine,
    required this.spacing,
    required this.initialPosition,
    required this.showTop,
    required this.showBottom,
    required this.scaleFactor,
    required this.bottomPadding,
    required this.waveCap,
    required this.middleLineColor,
    required this.middleLineThickness,
    required this.totalBackDistance,
    required this.dragOffset,
    required this.waveThickness,
    required this.pushBack,
    required this.callPushback,
    required this.extendWaveform,
  })  : _wavePaint = Paint()
          ..color = waveColor
          ..strokeWidth = waveThickness
          ..strokeCap = waveCap,
        _linePaint = Paint()
          ..color = middleLineColor
          ..strokeWidth = middleLineThickness;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < waveData.length; i++) {
      if (((spacing * i) + dragOffset.dx >
              size.width / (extendWaveform ? 1 : 2) + totalBackDistance.dx) &&
          callPushback) {
        pushBack();
      }

      ///upper graph
      if (showTop) {
        canvas.drawLine(
            Offset(
                -totalBackDistance.dx +
                    dragOffset.dx +
                    (spacing * i) -
                    spacing -
                    initialPosition,
                size.height - bottomPadding),
            Offset(
                -totalBackDistance.dx +
                    dragOffset.dx +
                    (spacing * i) -
                    spacing -
                    initialPosition,
                -waveData[i] * scaleFactor + size.height - bottomPadding),
            _wavePaint);
      }

      ///lower graph
      if (showBottom) {
        canvas.drawLine(
            Offset(
                -totalBackDistance.dx +
                    dragOffset.dx +
                    (spacing * i) -
                    spacing -
                    initialPosition,
                size.height - bottomPadding),
            Offset(
                -totalBackDistance.dx +
                    dragOffset.dx +
                    (spacing * i) -
                    spacing -
                    initialPosition,
                waveData[i] * scaleFactor + size.height - bottomPadding),
            _wavePaint);
      }
    }
    if (showMiddleLine) {
      canvas.drawLine(Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height), _linePaint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return true;
  }
}

///Addtion Information to get first and last wave location
///-totalBackDistance.dx + dragOffset.dx + (spacing * i) - spacing
///this gives location of first wave from right to left
///-totalBackDistance.dx + dragOffset.dx
///this gives location of first wave from left to right
