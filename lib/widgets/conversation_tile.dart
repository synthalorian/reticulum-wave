import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

/// A tile representing a conversation in the list.
/// Shows avatar, name, last message preview, timestamp, unread badge, pin icon.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onPinToggle,
    super.key,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onPinToggle;

  String get _lastMessagePreview {
    if (conversation.messages.isEmpty) return 'No messages yet';
    final last = conversation.messages.last;
    final prefix = last.isOutgoing ? 'You: ' : '';
    return '$prefix${last.content}';
  }

  String get _timestamp {
    final time = conversation.lastActivityAt ?? conversation.createdAt;
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: conversation.isGroup
                ? AppColors.hotPink.withValues(alpha: 0.2)
                : AppColors.electricPurple.withValues(alpha: 0.2),
            child: Icon(
              conversation.isGroup ? Icons.group : Icons.person,
              color: conversation.isGroup ? AppColors.hotPink : AppColors.electricPurple,
              size: 24,
            ),
          ),
          if (conversation.isPinned)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.neonYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.push_pin, size: 10, color: AppColors.darkBackground),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.name,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _timestamp,
            style: TextStyle(
              fontSize: 12,
              color: hasUnread ? AppColors.neonYellow : AppColors.textSecondary,
              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              _lastMessagePreview,
              style: TextStyle(
                fontSize: 14,
                color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasUnread)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.hotPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
