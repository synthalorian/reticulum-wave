import 'dart:async';

import '../models/models.dart';

/// Abstract interface for LXMF messaging.
///
/// Handles sending, receiving, and tracking delivery status of messages.
abstract class LxmfService {
  /// Stream of incoming messages.
  Stream<LxmfMessage> get messageReceived;

  /// Stream of message status updates.
  Stream<MessageStatusUpdate> get messageStatusChanged;

  /// Send a text message to a recipient.
  Future<String> sendMessage({
    required String recipientHash,
    required String content,
    List<String>? attachments,
    String? replyToId,
  });

  /// Send a voice message.
  Future<String> sendVoiceMessage({
    required String recipientHash,
    required String voicePath,
  });

  /// Request delivery status for a message.
  Future<MessageStatus> getStatus(String messageId);

  /// Mark a message as read (sends read receipt).
  Future<void> markAsRead(String messageId);

  /// Dispose of resources.
  void dispose();
}

/// Message status update event.
class MessageStatusUpdate {
  final String messageId;
  final MessageStatus status;

  MessageStatusUpdate({
    required this.messageId,
    required this.status,
  });
}
