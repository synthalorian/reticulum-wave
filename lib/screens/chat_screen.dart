import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/lxmf_service.dart';
import '../theme.dart';
import '../widgets/message_bubble.dart';

/// Chat screen for a specific conversation.
/// Uses LxmfService for sending and listens to status updates.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final lxmf = ref.read(lxmfServiceProvider);

    // Send via service
    lxmf.sendMessage(
      recipientHash: widget.conversationId,
      content: text,
    );

    // Optimistically add to local state
    final message = LxmfMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      senderHash: 'local_identity',
      recipientHash: widget.conversationId,
      content: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      isOutgoing: true,
    );

    ref.read(conversationsProvider.notifier).addMessage(widget.conversationId, message);
    _controller.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo, color: AppColors.electricPurple),
              title: const Text('Photo', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                // TODO: image picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: AppColors.electricPurple),
              title: const Text('File', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                // TODO: file picker
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showVoiceRecorder(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _VoiceRecorderSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);
    final conversation = conversations.firstWhere(
      (c) => c.id == widget.conversationId,
      orElse: () => Conversation(
        id: widget.conversationId,
        name: 'Unknown',
        createdAt: DateTime.now(),
      ),
    );

    // Listen for status updates
    ref.listen<AsyncValue<MessageStatusUpdate>>(messageStatusProvider, (_, asyncUpdate) {
      asyncUpdate.whenData((update) {
        ref.read(conversationsProvider.notifier).updateMessageStatus(
          widget.conversationId,
          update.messageId,
          update.status,
        );
      });
    });

    // Mark as read when opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (conversation.unreadCount > 0) {
        ref.read(conversationsProvider.notifier).markAsRead(widget.conversationId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conversation.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (conversation.isGroup)
              Text(
                '${conversation.memberHashes.length} members',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onPressed: () {
              // TODO: conversation options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: conversation.messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: conversation.messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: conversation.messages[index]);
                    },
                  ),
          ),
          _ComposeBar(
            controller: _controller,
            onSend: _sendMessage,
            onAttach: () => _showAttachmentSheet(context),
            onVoice: () => _showVoiceRecorder(context),
          ),
        ],
      ),
    );
  }
}

/// Bottom compose bar with text field, send button, and attachment options.
class _ComposeBar extends StatelessWidget {
  const _ComposeBar({
    required this.controller,
    required this.onSend,
    this.onAttach,
    this.onVoice,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttach;
  final VoidCallback? onVoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.deepPurple,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: AppColors.textSecondary),
              onPressed: onAttach,
            ),
            IconButton(
              icon: const Icon(Icons.mic, color: AppColors.textSecondary),
              onPressed: onVoice,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: AppColors.darkBackground,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.electricPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Voice recorder bottom sheet UI.
class _VoiceRecorderSheet extends StatefulWidget {
  const _VoiceRecorderSheet();

  @override
  State<_VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

class _VoiceRecorderSheetState extends State<_VoiceRecorderSheet> {
  bool _recording = false;
  int _seconds = 0;
  Timer? _timer;

  void _startRecording() {
    setState(() => _recording = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() => _recording = false);
    // TODO: send voice message via LxmfService
    Navigator.pop(context);
  }

  String get _formattedTime {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _recording ? 'Recording...' : 'Hold to Record',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _formattedTime,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTapDown: (_) => _startRecording(),
              onTapUp: (_) => _stopRecording(),
              onTapCancel: () => _stopRecording(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _recording ? 96 : 80,
                height: _recording ? 96 : 80,
                decoration: BoxDecoration(
                  color: _recording ? AppColors.offline : AppColors.electricPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_recording ? AppColors.offline : AppColors.electricPurple)
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _recording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _recording ? 'Release to send' : 'Tap and hold',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
