import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage before the app builds.
  await storageService.initialize();
  LoggerService.info('Reticulum Wave starting up...');

  runApp(
    const ProviderScope(
      child: ReticulumWaveApp(),
    ),
  );
}
