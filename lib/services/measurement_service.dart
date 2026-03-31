import 'dart:math';
import 'package:flutter/material.dart';

class MeasurementService {
  static double pixelDistance(Offset a, Offset b) {
    final dx = a.dx - b.dx;
    final dy = a.dy - b.dy;
    return sqrt(dx * dx + dy * dy);
  }

  static double pixelsToMm({
    required double pointDistancePx,
    required double markerWidthPx,
    required double markerWidthMm,
  }) {
    if (markerWidthPx <= 0) {
      throw ArgumentError('markerWidthPx must be > 0');
    }

    return pointDistancePx * (markerWidthMm / markerWidthPx);
  }
}