class CalibrationData {
  final double mmPerPixel;
  final double referenceDistanceMm;
  final double referenceDistancePx;

  const CalibrationData({
    required this.mmPerPixel,
    required this.referenceDistanceMm,
    required this.referenceDistancePx,
  });
}
