import 'dart:async';

import '../../models/models.dart';
import '../reticulum_service.dart';
import 'api_client.dart';

/// Real implementation of [ReticulumService] backed by Reticulum Link's REST API.
///
/// Polls /api/status and /api/peers to simulate discovery events.
/// Falls back to mock behavior if the API is unreachable.
class ApiReticulumService implements ReticulumService {
  final ApiClient _client;
  final _peerDiscoveredController = StreamController<Peer>.broadcast();
  final _peerUpdatedController = StreamController<Peer>.broadcast();
  final _linkQualityController = StreamController<PeerLinkUpdate>.broadcast();

  Timer? _pollTimer;
  bool _running = false;
  final _knownPeers = <String, Peer>{};

  ApiReticulumService({ApiClient? client}) : _client = client ?? ApiClient();

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

    // Initial fetch
    await _pollPeers();

    // Poll every 5 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_running) return;
      _pollPeers();
    });
  }

  @override
  Future<void> stop() async {
    _running = false;
    _pollTimer?.cancel();
  }

  @override
  Future<void> announce() async {
    // No-op for API mode — announce is handled by the node
  }

  @override
  Future<String?> getLocalHash() async {
    try {
      final status = await _client.status();
      return status.node;
    } catch (e) {
      return null;
    }
  }

  Future<void> _pollPeers() async {
    try {
      final peers = await _client.peers();
      for (final peer in peers) {
        final existing = _knownPeers[peer.hash];
        if (existing == null) {
          _knownPeers[peer.hash] = peer;
          _peerDiscoveredController.add(peer);
        } else if (existing.hops != peer.hops) {
          _knownPeers[peer.hash] = peer;
          _peerUpdatedController.add(peer);
          _linkQualityController.add(PeerLinkUpdate(
            peerHash: peer.hash,
            linkQuality: peer.linkQuality,
            hops: peer.hops,
          ));
        }
      }
    } catch (e) {
      // Silently fail — node may be offline
    }
  }

  @override
  void dispose() {
    stop();
    _peerDiscoveredController.close();
    _peerUpdatedController.close();
    _linkQualityController.close();
    _client.dispose();
  }
}
