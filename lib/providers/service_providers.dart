import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reticulum_service.dart';
import '../services/lxmf_service.dart';
import '../services/rnode_service.dart';
import '../services/mock/mock_reticulum_service.dart';
import '../services/mock/mock_lxmf_service.dart';
import '../services/mock/mock_rnode_service.dart';
import '../services/api/api_reticulum_service.dart';
import '../services/api/api_lxmf_service.dart';
import '../models/models.dart';

/// Whether to use the real API backend or mocks.
const bool _useRealApi = true;

/// Provider for the Reticulum network service.
final reticulumServiceProvider = Provider<ReticulumService>((ref) {
  if (_useRealApi) {
    final service = ApiReticulumService();
    service.start();
    ref.onDispose(() => service.dispose());
    return service;
  }

  final service = MockReticulumService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the LXMF messaging service.
final lxmfServiceProvider = Provider<LxmfService>((ref) {
  if (_useRealApi) {
    final service = ApiLxmfService();
    service.startPolling();
    ref.onDispose(() => service.dispose());
    return service;
  }

  final service = MockLxmfService();
  service.startIncomingSimulation();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the RNode hardware service.
final rnodeServiceProvider = Provider<RNodeService>((ref) {
  final service = MockRNodeService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream provider for incoming LXMF messages.
final incomingMessagesProvider = StreamProvider<LxmfMessage>((ref) {
  final service = ref.watch(lxmfServiceProvider);
  return service.messageReceived;
});

/// Stream provider for message status updates.
final messageStatusProvider = StreamProvider<MessageStatusUpdate>((ref) {
  final service = ref.watch(lxmfServiceProvider);
  return service.messageStatusChanged;
});

/// Stream provider for peer discovery.
final peerDiscoveryProvider = StreamProvider<Peer>((ref) {
  final service = ref.watch(reticulumServiceProvider);
  return service.peerDiscovered;
});

/// Stream provider for peer status updates.
final peerUpdatesProvider = StreamProvider<Peer>((ref) {
  final service = ref.watch(reticulumServiceProvider);
  return service.peerUpdated;
});

/// Stream provider for link quality changes.
final linkQualityProvider = StreamProvider<PeerLinkUpdate>((ref) {
  final service = ref.watch(reticulumServiceProvider);
  return service.linkQualityChanged;
});

/// Stream provider for RNode connection state.
final rnodeConnectionProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(rnodeServiceProvider);
  return service.connectionChanged;
});

/// Stream provider for RNode signal metrics.
final rnodeSignalProvider = StreamProvider<RNodeSignalMetrics>((ref) {
  final service = ref.watch(rnodeServiceProvider);
  return service.signalMetrics;
});
