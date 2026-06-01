import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

/// A single message bubble in the chat screen.
/// Sent messages align right (purple), received align left (surface).
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    super.key,
  });

  final LxmfMessage message;

  IconData get _statusIcon {
    switch (message.status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
      case MessageStatus.draft:
        return Icons.edit;
    }
  }

  Color get _statusColor {
    switch (message.status) {
      case MessageStatus.read:
        return AppColors.cyan;
      case MessageStatus.failed:
        return AppColors.offline;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _time {
    final hour = message.timestamp.hour.toString().padLeft(2, '0');
    final minute = message.timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isOutgoing = message.isOutgoing;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isOutgoing ? 64 : 12,
          right: isOutgoing ? 12 : 64,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isOutgoing
              ? AppColors.electricPurple.withValues(alpha: 0.25)
              : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isOutgoing ? 16 : 4),
            bottomRight: Radius.circular(isOutgoing ? 4 : 16),
          ),
          border: Border.all(
            color: isOutgoing
                ? AppColors.electricPurple.withValues(alpha: 0.4)
                : AppColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _time,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
                if (isOutgoing) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _statusIcon,
                    size: 14,
                    color: _statusColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
