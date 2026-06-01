import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// Holds the list of discovered peers on the mesh network.
class PeersNotifier extends StateNotifier<List<Peer>> {
  PeersNotifier() : super([]);

  void setPeers(List<Peer> peers) {
    state = peers;
  }

  void addPeer(Peer peer) {
    // Replace if exists, otherwise append
    final exists = state.any((p) => p.hash == peer.hash);
    if (exists) {
      state = state.map((p) => p.hash == peer.hash ? peer : p).toList();
    } else {
      state = [...state, peer];
    }
  }

  void removePeer(String hash) {
    state = state.where((p) => p.hash != hash).toList();
  }

  void toggleFavorite(String hash) {
    state = state.map((p) {
      if (p.hash == hash) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();
  }

  void updateLinkQuality(String hash, double quality) {
    state = state.map((p) {
      if (p.hash == hash) {
        return p.copyWith(linkQuality: quality);
      }
      return p;
    }).toList();
  }
  void clearAll() {
    state = [];
  }
}

/// Provider for the peers list.
final peersProvider = StateNotifierProvider<PeersNotifier, List<Peer>>((ref) {
  return PeersNotifier();
});

/// Online peers only.
final onlinePeersProvider = Provider<List<Peer>>((ref) {
  final peers = ref.watch(peersProvider);
  return peers.where((p) => p.isOnline).toList();
});

/// Favorite peers.
final favoritePeersProvider = Provider<List<Peer>>((ref) {
  final peers = ref.watch(peersProvider);
  return peers.where((p) => p.isFavorite).toList();
});
