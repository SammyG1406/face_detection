import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FaceMeasurementApp());
}

class FaceMeasurementApp extends StatelessWidget {
  const FaceMeasurementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Measurement',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.green,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
