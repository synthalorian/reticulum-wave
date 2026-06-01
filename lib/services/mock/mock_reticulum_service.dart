import 'dart:async';
import 'dart:math';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../reticulum_service.dart';

/// Mock implementation of [ReticulumService] for development and testing.
///
/// Simulates peer discovery, link quality fluctuations, and network status.
class MockReticulumService implements ReticulumService {
  final _peerDiscoveredController = StreamController<Peer>.broadcast();
  final _peerUpdatedController = StreamController<Peer>.broadcast();
  final _linkQualityController = StreamController<PeerLinkUpdate>.broadcast();

  Timer? _discoveryTimer;
  Timer? _qualityTimer;
  bool _running = false;
  final _rng = Random();

  @override
  bool get isRunning => _running;

  @override
  Stream<Peer> get peerDiscovered => _peerDiscoveredController.stream;

  @override
  Stream<Peer> get peerUpdated => _peerUpdatedController.stream;

  @override
  Stream<PeerLinkUpdate> get linkQualityChanged => _linkQualityController.stream;

  @override
  Future<void> start({String? configPath}) async {
    if (_running) return;
    _running = true;

    // Simulate initial peer discovery burst
    for (final peer in MockData.peers) {
      await Future.delayed(Duration(milliseconds: 200 + _rng.nextInt(300)));
      _peerDiscoveredController.add(peer);
    }

    // Periodic "new peer" discovery
    _discoveryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_running) return;
      _simulateNewPeer();
    });

    // Periodic link quality fluctuations
    _qualityTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_running) return;
      _simulateQualityChange();
    });
  }

  @override
  Future<void> stop() async {
    _running = false;
    _discoveryTimer?.cancel();
    _qualityTimer?.cancel();
  }

  @override
  Future<void> announce() async {
    // Simulate announce propagation delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<String?> getLocalHash() async {
    return MockData.identities.first.hash;
  }

  void _simulateNewPeer() {
    final names = [
      'Field Relay 9',
      'Mobile Node Alpha',
      'Emergency Beacon 3',
      'Drone Link 7',
      'Portable Station B',
    ];
    final services = [
      ['lxmf.delivery'],
      ['lxmf.delivery', 'propagation'],
      ['nomadnetwork'],
      ['lxmf.delivery', 'nomadnetwork', 'propagation'],
    ];

    final name = names[_rng.nextInt(names.length)];
    final hash = 'peer_${_rng.nextInt(99999).toString().padLeft(5, '0')}';

    final peer = Peer(
      hash: hash,
      name: name,
      lastSeen: DateTime.now(),
      linkQuality: 0.3 + _rng.nextDouble() * 0.6,
      hops: 1 + _rng.nextInt(4),
      services: services[_rng.nextInt(services.length)],
      isOnline: true,
      isFavorite: false,
    );

    _peerDiscoveredController.add(peer);
  }

  void _simulateQualityChange() {
    final peers = MockData.peers;
    if (peers.isEmpty) return;

    final peer = peers[_rng.nextInt(peers.length)];
    final variation = (_rng.nextDouble() - 0.5) * 0.1; // ±5%
    var newQuality = peer.linkQuality + variation;
    newQuality = newQuality.clamp(0.0, 1.0);

    _linkQualityController.add(PeerLinkUpdate(
      peerHash: peer.hash,
      linkQuality: newQuality,
      hops: peer.hops,
    ));

    // Occasionally toggle online status
    if (_rng.nextDouble() < 0.05) {
      final updated = peer.copyWith(
        isOnline: !peer.isOnline,
        lastSeen: DateTime.now(),
      );
      _peerUpdatedController.add(updated);
    }
  }

  @override
  void dispose() {
    stop();
    _peerDiscoveredController.close();
    _peerUpdatedController.close();
    _linkQualityController.close();
  }
}
