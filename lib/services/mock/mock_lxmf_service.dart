import 'dart:async';
import 'dart:math';

import '../../models/models.dart';
import '../lxmf_service.dart';

/// Mock implementation of [LxmfService] for development and testing.
///
/// Simulates message sending with realistic delays and status transitions.
class MockLxmfService implements LxmfService {
  final _messageReceivedController = StreamController<LxmfMessage>.broadcast();
  final _statusController = StreamController<MessageStatusUpdate>.broadcast();

  final _rng = Random();
  final _pendingMessages = <String, LxmfMessage>{};
  Timer? _simulationTimer;

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
    final id = 'msg_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(999)}';

    final message = LxmfMessage(
      id: id,
      senderHash: 'local_identity',
      recipientHash: recipientHash,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      attachments: attachments ?? [],
      isOutgoing: true,
      replyToId: replyToId,
    );

    _pendingMessages[id] = message;

    // Simulate send lifecycle
    _simulateMessageLifecycle(id);

    return id;
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
    final message = _pendingMessages[messageId];
    return message?.status ?? MessageStatus.failed;
  }

  @override
  Future<void> markAsRead(String messageId) async {
    // Simulate read receipt being sent
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Simulate receiving an incoming message from a peer.
  void simulateIncomingMessage({
    required String senderHash,
    required String content,
    List<String>? attachments,
  }) {
    final id = 'msg_in_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(999)}';

    final message = LxmfMessage(
      id: id,
      senderHash: senderHash,
      recipientHash: 'local_identity',
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
      attachments: attachments ?? [],
      isOutgoing: false,
    );

    _messageReceivedController.add(message);
  }

  /// Start periodic simulation of incoming messages.
  void startIncomingSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      _simulateRandomIncoming();
    });
  }

  void stopIncomingSimulation() {
    _simulationTimer?.cancel();
  }

  void _simulateMessageLifecycle(String messageId) {
    // sending → sent (after 1-2s)
    Future.delayed(Duration(seconds: 1 + _rng.nextInt(2)), () {
      _updateStatus(messageId, MessageStatus.sent);

      // sent → delivered (after 2-5s)
      Future.delayed(Duration(seconds: 2 + _rng.nextInt(4)), () {
        _updateStatus(messageId, MessageStatus.delivered);

        // delivered → read (after 3-10s, simulates recipient reading)
        Future.delayed(Duration(seconds: 3 + _rng.nextInt(8)), () {
          _updateStatus(messageId, MessageStatus.read);
        });
      });
    });
  }

  void _updateStatus(String messageId, MessageStatus status) {
    final message = _pendingMessages[messageId];
    if (message == null) return;

    _pendingMessages[messageId] = message.copyWith(status: status);
    _statusController.add(MessageStatusUpdate(
      messageId: messageId,
      status: status,
    ));
  }

  void _simulateRandomIncoming() {
    final messages = [
      'Hey, are you there?',
      'Signal check. How\'s my link quality?',
      'The new firmware is flashed and ready.',
      'Moving to grid reference Alpha-7.',
      'Battery at 67%, all systems nominal.',
      'Can you relay this to Base Station?',
      'Weather update: clear skies, wind 5mph.',
      'Net check. All stations report.',
    ];

    final senders = [
      'peer_001_abcdef123456',
      'peer_002_fedcba654321',
      'peer_005_aabbccdd1122',
    ];

    simulateIncomingMessage(
      senderHash: senders[_rng.nextInt(senders.length)],
      content: messages[_rng.nextInt(messages.length)],
    );
  }

  @override
  void dispose() {
    stopIncomingSimulation();
    _messageReceivedController.close();
    _statusController.close();
  }
}
