import 'package:flutter/services.dart';

class MeasurementChannelService {
  static const MethodChannel _channel =
  MethodChannel('head_measurement_channel');

  static Future<Map<dynamic, dynamic>?> detectMarker() async {
    final result = await _channel.invokeMethod('detectMarker');
    return result as Map<dynamic, dynamic>?;
  }
}