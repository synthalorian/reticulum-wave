import 'dart:async';

import '../../models/models.dart';
import '../lxmf_service.dart';
import 'api_client.dart';

/// Real implementation of [LxmfService] backed by Reticulum Link's REST API.
///
/// Polls /api/messages for incoming messages and POSTs to send.
class ApiLxmfService implements LxmfService {
  final ApiClient _client;
  final _messageReceivedController = StreamController<LxmfMessage>.broadcast();
  final _statusController = StreamController<MessageStatusUpdate>.broadcast();

  Timer? _pollTimer;
  final _knownMessages = <String>{};
  final String? _localHash;

  ApiLxmfService({ApiClient? client, String? localHash})
      : _client = client ?? ApiClient(),
        _localHash = localHash;

  @override
  Stream<LxmfMessage> get messageReceived => _messageReceivedController.stream;

  @override
  Stream<MessageStatusUpdate> get messageStatusChanged => _statusController.stream;

  @override
  Future<String> sendMessage({
    required String recipientHash,
    required String content,
    List<String>? attachments,
    String? replyToId,
  }) async {
    final hash = await _client.sendMessage(
      destination: recipientHash,
      source: _localHash ?? 'local_identity',
      content: content,
    );

    _statusController.add(MessageStatusUpdate(
      messageId: hash,
      status: MessageStatus.sent,
    ));

    return hash;
  }

  @override
  Future<String> sendVoiceMessage({
    required String recipientHash,
    required String voicePath,
  }) async {
    return sendMessage(
      recipientHash: recipientHash,
      content: '[Voice message]',
      attachments: [voicePath],
    );
  }

  @override
  Future<MessageStatus> getStatus(String messageId) async {
    return MessageStatus.sent;
  }

  @override
  Future<void> markAsRead(String messageId) async {
    // No-op for API mode — read receipts not yet implemented server-side
  }

  /// Start polling for incoming messages.
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollMessages();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
  }

  Future<void> _pollMessages() async {
    try {
      final messages = await _client.messages();
      for (final msg in messages) {
        if (!_knownMessages.contains(msg.id)) {
          _knownMessages.add(msg.id);
          if (!msg.isOutgoing) {
            _messageReceivedController.add(msg);
          }
        }
      }
    } catch (e) {
      // Silently fail — node may be offline
    }
  }

  @override
  void dispose() {
    stopPolling();
    _messageReceivedController.close();
    _statusController.close();
    _client.dispose();
  }
}
