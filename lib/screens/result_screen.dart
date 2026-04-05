import 'package:flutter/material.dart';
import '../models/measurement_result.dart';

class ResultScreen extends StatelessWidget {
  final MeasurementResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cm = result.valueMm / 10;
    final inch = result.valueMm / 25.4;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Measurement Result'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 72),
              const SizedBox(height: 12),
              const Text(
                'Measurement Complete',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              _ResultCard(
                label: 'Distance',
                value: '${result.valueMm.toStringAsFixed(2)} mm',
                highlight: true,
              ),
              const SizedBox(height: 12),
              _ResultCard(
                label: 'In centimetres',
                value: '${cm.toStringAsFixed(2)} cm',
              ),
              const SizedBox(height: 12),
              _ResultCard(
                label: 'In inches',
                value: '${inch.toStringAsFixed(3)}"',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calibration reference',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result.markerWidthMm.toStringAsFixed(1)} mm'
                      ' = ${result.markerWidthPx.toStringAsFixed(1)} px'
                      '  (${(result.markerWidthPx / result.markerWidthMm).toStringAsFixed(2)} px/mm)',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Taken: ${_formatDate(result.createdAt)}',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Text('Measure Again'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Back to Home',
                    style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ResultCard({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlight ? Colors.blue.withValues(alpha: 0.15) : Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        border: highlight
            ? Border.all(color: Colors.blue.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: highlight ? Colors.white70 : Colors.white54,
                  fontSize: 15)),
          Text(value,
              style: TextStyle(
                color: highlight ? Colors.white : Colors.white,
                fontSize: highlight ? 22 : 16,
                fontWeight:
                    highlight ? FontWeight.bold : FontWeight.w500,
              )),
        ],
      ),
    );
  }
}
