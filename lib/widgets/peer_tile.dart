import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

/// A tile representing a discovered peer in the network explorer.
/// Shows name, signal quality, hops, services, online status.
class PeerTile extends StatelessWidget {
  const PeerTile({
    required this.peer,
    required this.onTap,
    required this.onFavoriteToggle,
    super.key,
  });

  final Peer peer;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  String get _lastSeen {
    final diff = DateTime.now().difference(peer.lastSeen);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Color get _signalColor {
    if (peer.linkQuality >= 0.7) return AppColors.online;
    if (peer.linkQuality >= 0.4) return AppColors.warning;
    return AppColors.offline;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: peer.isOnline
                ? AppColors.electricPurple.withValues(alpha: 0.2)
                : AppColors.divider.withValues(alpha: 0.3),
            child: Icon(
              Icons.router,
              color: peer.isOnline ? AppColors.electricPurple : AppColors.textSecondary,
              size: 22,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: peer.isOnline ? AppColors.online : AppColors.offline,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkBackground, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              peer.name ?? 'Unknown Node',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: peer.isOnline ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (peer.isFavorite)
            const Icon(Icons.star, color: AppColors.neonYellow, size: 18),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Row(
            children: [
              // Signal bars
              Row(
                children: List.generate(4, (i) {
                  final threshold = (i + 1) * 0.25;
                  final active = peer.linkQuality >= threshold;
                  return Container(
                    margin: const EdgeInsets.only(right: 2),
                    width: 4,
                    height: 6 + (i * 3),
                    decoration: BoxDecoration(
                      color: active ? _signalColor : AppColors.divider,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                '${(peer.linkQuality * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: _signalColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${peer.hops} hop${peer.hops == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _lastSeen,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (peer.services.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: peer.services.map((service) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    service,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          peer.isFavorite ? Icons.star : Icons.star_border,
          color: peer.isFavorite ? AppColors.neonYellow : AppColors.textSecondary,
        ),
        onPressed: onFavoriteToggle,
      ),
    );
  }
}
