import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/reticulum_service.dart';
import '../theme.dart';
import '../widgets/peer_tile.dart';

/// Network Explorer tab — discover and browse Reticulum peers.
/// Listens to service streams for live updates.
class NetworkScreen extends ConsumerStatefulWidget {
  const NetworkScreen({super.key});

  @override
  ConsumerState<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends ConsumerState<NetworkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(peersProvider.notifier);
      notifier.setPeers(MockData.peers);
    });
  }

  @override
  Widget build(BuildContext context) {
    final peers = ref.watch(peersProvider);
    final onlineCount = peers.where((p) => p.isOnline).length;

    // Listen for peer discovery
    ref.listen<AsyncValue<Peer>>(peerDiscoveryProvider, (_, asyncPeer) {
      asyncPeer.whenData((peer) {
        ref.read(peersProvider.notifier).addPeer(peer);
      });
    });

    // Listen for peer updates
    ref.listen<AsyncValue<Peer>>(peerUpdatesProvider, (_, asyncPeer) {
      asyncPeer.whenData((peer) {
        ref.read(peersProvider.notifier).addPeer(peer);
      });
    });

    // Listen for link quality changes
    ref.listen<AsyncValue<PeerLinkUpdate>>(linkQualityProvider, (_, asyncUpdate) {
      asyncUpdate.whenData((update) {
        ref.read(peersProvider.notifier).updateLinkQuality(
          update.peerHash,
          update.linkQuality,
        );
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () async {
              final service = ref.read(reticulumServiceProvider);
              await service.announce();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.deepPurple.withValues(alpha: 0.5),
            child: Row(
              children: [
                _StatChip(
                  label: 'Online',
                  value: '$onlineCount',
                  color: AppColors.online,
                ),
                const SizedBox(width: 16),
                _StatChip(
                  label: 'Total',
                  value: '${peers.length}',
                  color: AppColors.electricPurple,
                ),
                const SizedBox(width: 16),
                _StatChip(
                  label: 'Favorites',
                  value: '${peers.where((p) => p.isFavorite).length}',
                  color: AppColors.neonYellow,
                ),
              ],
            ),
          ),
          Expanded(
            child: peers.isEmpty
                ? const Center(
                    child: Text(
                      'No peers discovered yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: peers.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final peer = peers[index];
                      return PeerTile(
                        peer: peer,
                        onTap: () {
                          // TODO: peer detail screen
                        },
                        onFavoriteToggle: () {
                          ref.read(peersProvider.notifier).toggleFavorite(peer.hash);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
