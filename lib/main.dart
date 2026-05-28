import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: ReticulumWaveApp()));
}

class ReticulumWaveApp extends StatelessWidget {
  const ReticulumWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reticulum Wave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00BCD4),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const Placeholder(child: Center(child: Text('Reticulum Wave'))),
    );
  }
}
