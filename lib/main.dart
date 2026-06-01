import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/services.dart';
import 'services/mock/mock_reticulum_service.dart';
import 'services/mock/mock_lxmf_service.dart';
import 'services/mock/mock_rnode_service.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage before the app builds.
  await storageService.initialize();
  LoggerService.info('Reticulum Wave starting up...');

  runApp(
    ProviderScope(
      overrides: [
        // Pre-start services so they're ready when UI builds
        reticulumServiceProvider.overrideWith((ref) {
          final service = MockReticulumService();
          service.start();
          ref.onDispose(() => service.dispose());
          return service;
        }),
        lxmfServiceProvider.overrideWith((ref) {
          final service = MockLxmfService();
          service.startIncomingSimulation();
          ref.onDispose(() => service.dispose());
          return service;
        }),
        rnodeServiceProvider.overrideWith((ref) {
          final service = MockRNodeService();
          ref.onDispose(() => service.dispose());
          return service;
        }),
      ],
      child: const ReticulumWaveApp(),
    ),
  );
}
