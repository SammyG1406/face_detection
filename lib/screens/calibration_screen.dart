import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/calibration_data.dart';
import '../painters/measurement_painter_overlay.dart';
import '../services/measurement_service.dart';
import 'measure_screen.dart';

// Standard reference object widths in mm
class _Reference {
  final String label;
  final double mm;
  const _Reference(this.label, this.mm);
}

const _references = [
  _Reference('Credit card – width', 85.6),
  _Reference('Credit card – height', 53.98),
  _Reference('A4 paper – width', 210.0),
  _Reference('US Letter – width', 215.9),
  _Reference('Custom…', 0),
];

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  CameraController? _controller;
  bool _isLoading = true;

  Offset? _p1;
  Offset? _p2;

  _Reference _selected = _references.first;
  double _customMm = 0;

  double get _refMm =>
      _selected.mm > 0 ? _selected.mm : _customMm;

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
        // Reset and start again
        _p1 = details.localPosition;
        _p2 = null;
      }
    });
  }

  Future<void> _onReferenceChanged(_Reference ref) async {
    if (ref.mm == 0) {
      final value = await _showCustomDialog();
      if (value == null || value <= 0) return;
      setState(() {
        _selected = ref;
        _customMm = value;
      });
    } else {
      setState(() => _selected = ref);
    }
  }

  Future<double?> _showCustomDialog() {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Enter known distance',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Distance in mm',
            labelStyle: TextStyle(color: Colors.white54),
            suffixText: 'mm',
            suffixStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              Navigator.pop(ctx, v);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmCalibration() {
    if (_p1 == null || _p2 == null) return;
    if (_refMm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid reference distance')),
      );
      return;
    }

    final distancePx = MeasurementService.pixelDistance(_p1!, _p2!);
    final mmPerPixel = _refMm / distancePx;

    final calibration = CalibrationData(
      mmPerPixel: mmPerPixel,
      referenceDistanceMm: _refMm,
      referenceDistancePx: distancePx,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeasureScreen(calibration: calibration),
      ),
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

    final bothSet = _p1 != null && _p2 != null;
    final distancePx = bothSet
        ? MeasurementService.pixelDistance(_p1!, _p2!)
        : null;

    String hint;
    if (_p1 == null) {
      hint = 'Tap the first edge of your reference object';
    } else if (_p2 == null) {
      hint = 'Tap the second edge of your reference object';
    } else {
      hint =
          '${distancePx!.toStringAsFixed(1)} px  =  ${_refMm.toStringAsFixed(2)} mm';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Calibration'),
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
                // Reference object selector
                DropdownButtonFormField<_Reference>(
                  value: _selected,
                  dropdownColor: Colors.grey[850],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Reference object',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                  items: _references
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              r.mm > 0
                                  ? '${r.label}  (${r.mm} mm)'
                                  : r.label,
                            ),
                          ))
                      .toList(),
                  onChanged: (r) {
                    if (r != null) _onReferenceChanged(r);
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  hint,
                  style: TextStyle(
                    color: bothSet ? Colors.green[300] : Colors.white60,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: bothSet ? _confirmCalibration : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Confirm & Measure'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
