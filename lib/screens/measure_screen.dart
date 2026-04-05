import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/calibration_data.dart';
import '../models/measurement_result.dart';
import '../painters/measurement_painter_overlay.dart';
import '../services/measurement_service.dart';
import 'result_screen.dart';

class MeasureScreen extends StatefulWidget {
  final CalibrationData calibration;

  const MeasureScreen({super.key, required this.calibration});

  @override
  State<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends State<MeasureScreen> {
  CameraController? _controller;
  bool _isLoading = true;

  Offset? _p1;
  Offset? _p2;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _controller = CameraController(
      front,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _controller!.initialize();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details) {
    setState(() {
      if (_p1 == null) {
        _p1 = details.localPosition;
      } else if (_p2 == null) {
        _p2 = details.localPosition;
      } else {
        _p1 = details.localPosition;
        _p2 = null;
      }
    });
  }

  double? get _distanceMm {
    if (_p1 == null || _p2 == null) return null;
    final px = MeasurementService.pixelDistance(_p1!, _p2!);
    return px * widget.calibration.mmPerPixel;
  }

  void _saveResult() {
    final mm = _distanceMm;
    if (mm == null) return;
    final result = MeasurementResult(
      valueMm: mm,
      markerWidthMm: widget.calibration.referenceDistanceMm,
      markerWidthPx: widget.calibration.referenceDistancePx,
      createdAt: DateTime.now(),
      confidence: 'medium',
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !(_controller?.value.isInitialized ?? false)) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final mm = _distanceMm;
    final label = mm != null ? '${mm.toStringAsFixed(1)} mm' : null;
    final bothSet = _p1 != null && _p2 != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Measure'),
        actions: [
          if (bothSet)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset points',
              onPressed: () => setState(() {
                _p1 = null;
                _p2 = null;
              }),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTapDown: _handleTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_controller!),
                  CustomPaint(
                    painter: MeasurementPainterOverlay(
                      point1: _p1,
                      point2: _p2,
                      distanceLabel: label,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: const Color(0xFF111111),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Calibration info chip
                Row(
                  children: [
                    const Icon(Icons.tune, color: Colors.white38, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Scale: ${(1 / widget.calibration.mmPerPixel).toStringAsFixed(2)} px/mm'
                      '  ·  ref ${widget.calibration.referenceDistanceMm.toStringAsFixed(1)} mm',
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Distance readout
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _p1 == null
                        ? 'Tap the first point'
                        : _p2 == null
                            ? 'Tap the second point'
                            : '${mm!.toStringAsFixed(2)} mm',
                    key: ValueKey(bothSet),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bothSet ? Colors.greenAccent : Colors.white60,
                      fontSize: bothSet ? 26 : 16,
                      fontWeight:
                          bothSet ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (bothSet)
                  ElevatedButton(
                    onPressed: _saveResult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Save Result'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
