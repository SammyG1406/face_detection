class MeasurementResult {
  final double valueMm;
  final double markerWidthMm;
  final double markerWidthPx;
  final DateTime createdAt;
  final String confidence;

  MeasurementResult({
    required this.valueMm,
    required this.markerWidthMm,
    required this.markerWidthPx,
    required this.createdAt,
    required this.confidence,
  });
}