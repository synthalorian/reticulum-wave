import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';

/// Map View tab — visualize mesh network topology with GPS-enabled nodes.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(peersProvider.notifier).setPeers(MockData.peers);
    });
  }

  Color _nodeColor(Peer peer) {
    if (!peer.isOnline) return AppColors.offline.withValues(alpha: 0.7);
    if (peer.linkQuality >= 0.7) return AppColors.online;
    if (peer.linkQuality >= 0.4) return AppColors.warning;
    return AppColors.offline;
  }

  @override
  Widget build(BuildContext context) {
    final peers = ref.watch(peersProvider);
    final gpsPeers = peers.where((p) => p.latitude != null && p.longitude != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers, color: AppColors.textSecondary),
            onPressed: () {
              // TODO: layer toggle
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(40.7128, -74.0060),
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.synthalorian.reticulum_wave',
          ),
          MarkerLayer(
            markers: gpsPeers.map((peer) {
              return Marker(
                point: LatLng(peer.latitude!, peer.longitude!),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _showNodeSheet(context, peer),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _nodeColor(peer),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _nodeColor(peer).withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (peer.name ?? '?').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          // Link lines between nodes
          PolylineLayer(
            polylines: _buildLinks(gpsPeers),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          // TODO: center on user location
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  List<Polyline> _buildLinks(List<Peer> peers) {
    final lines = <Polyline>[];
    for (var i = 0; i < peers.length; i++) {
      for (var j = i + 1; j < peers.length; j++) {
        final a = peers[i];
        final b = peers[j];
        final quality = (a.linkQuality + b.linkQuality) / 2;
        lines.add(Polyline(
          points: [
            LatLng(a.latitude!, a.longitude!),
            LatLng(b.latitude!, b.longitude!),
          ],
          color: quality >= 0.7
              ? AppColors.online.withValues(alpha: 0.5)
              : quality >= 0.4
                  ? AppColors.warning.withValues(alpha: 0.4)
                  : AppColors.offline.withValues(alpha: 0.3),
          strokeWidth: 2,
        ));
      }
    }
    return lines;
  }

  void _showNodeSheet(BuildContext context, Peer peer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: peer.isOnline ? AppColors.online : AppColors.offline,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  peer.name ?? 'Unknown',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Hash', value: '${peer.hash.substring(0, 20)}...'),
            _DetailRow(label: 'Link Quality', value: '${(peer.linkQuality * 100).toInt()}%'),
            _DetailRow(label: 'Hops', value: '${peer.hops}'),
            _DetailRow(label: 'Last Seen', value: _formatLastSeen(peer)),
            if (peer.services.isNotEmpty)
              _DetailRow(label: 'Services', value: peer.services.join(', ')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: navigate to chat
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(peersProvider.notifier).toggleFavorite(peer.hash);
                      Navigator.pop(context);
                    },
                    icon: Icon(peer.isFavorite ? Icons.star : Icons.star_border),
                    label: Text(peer.isFavorite ? 'Unfavorite' : 'Favorite'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(Peer peer) {
    final diff = DateTime.now().difference(peer.lastSeen);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
