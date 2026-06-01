import 'dart:async';

import '../models/models.dart';

/// Abstract interface for the Reticulum network stack.
///
/// Implementations handle the actual transport (Python subprocess, Rust FFI,
/// or mock for testing). The UI depends only on this interface.
abstract class ReticulumService {
  /// Whether the Reticulum stack is currently running.
  bool get isRunning;

  /// Stream of peer discovery events.
  Stream<Peer> get peerDiscovered;

  /// Stream of peer status changes (online/offline/quality updates).
  Stream<Peer> get peerUpdated;

  /// Stream of link quality changes.
  Stream<PeerLinkUpdate> get linkQualityChanged;

  /// Start the Reticulum stack with optional config path.
  Future<void> start({String? configPath});

  /// Stop the Reticulum stack.
  Future<void> stop();

  /// Announce our presence on the network.
  Future<void> announce();

  /// Get the local identity's destination hash.
  Future<String?> getLocalHash();

  /// Dispose of resources.
  void dispose();
}

/// Link quality update event.
class PeerLinkUpdate {
  final String peerHash;
  final double linkQuality;
  final int hops;

  PeerLinkUpdate({
    required this.peerHash,
    required this.linkQuality,
    required this.hops,
  });
}
