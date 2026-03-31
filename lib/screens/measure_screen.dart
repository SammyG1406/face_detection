import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class MeasureScreen extends StatefulWidget {
  const MeasureScreen({super.key});

  @override
  State<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends State<MeasureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  Offset? p1;
  Offset? p2;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    final front = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      front,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();
    setState(() {});
  }

  void _handleTap(TapDownDetails details) {
    setState(() {
      if (p1 == null) {
        p1 = details.localPosition;
      } else if (p2 == null) {
        p2 = details.localPosition;
      } else {
        p1 = details.localPosition;
        p2 = null;
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Measure')),
      body: GestureDetector(
        onTapDown: _handleTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(_controller!),
            if (p1 != null)
              Positioned(
                left: p1!.dx - 8,
                top: p1!.dy - 8,
                child: _dot('1'),
              ),
            if (p2 != null)
              Positioned(
                left: p2!.dx - 8,
                top: p2!.dy - 8,
                child: _dot('2'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dot(String label) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }
}