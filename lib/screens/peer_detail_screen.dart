import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

/// Detail screen for a Reticulum peer.
/// Shows identity, services, link quality, path info, and quick actions.
class PeerDetailScreen extends StatelessWidget {
  const PeerDetailScreen({required this.peer, super.key});

  final Peer peer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(peer.name ?? 'Unknown Node'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Identity card
          _InfoCard(
            title: 'Identity',
            children: [
              _InfoRow(label: 'Hash', value: peer.hash),
              _InfoRow(label: 'Name', value: peer.name ?? 'Unknown'),
              _InfoRow(
                label: 'Last Seen',
                value: _formatTime(peer.lastSeen),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Network card
          _InfoCard(
            title: 'Network',
            children: [
              _InfoRow(label: 'Hops', value: '${peer.hops}'),
              _InfoRow(
                label: 'Link Quality',
                value: '${(peer.linkQuality * 100).toStringAsFixed(0)}%',
              ),
              _InfoRow(
                label: 'Status',
                value: peer.isOnline ? 'Online' : 'Offline',
                valueColor: peer.isOnline ? AppColors.online : AppColors.offline,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Services card
          _InfoCard(
            title: 'Services',
            children: peer.services.isEmpty
                ? [const _InfoRow(label: '', value: 'No services announced')]
                : peer.services
                    .map((s) => _InfoRow(label: '', value: s))
                    .toList(),
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to chat — handled by caller or router
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Message'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: ping
                  },
                  icon: const Icon(Icons.network_ping),
                  label: const Text('Ping'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
