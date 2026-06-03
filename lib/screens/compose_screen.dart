import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';

/// Compose screen for starting a new conversation.
/// Select a peer or enter a hash manually, then send the first message.
class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _hashController = TextEditingController();
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _hashController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final hash = _hashController.text.trim();
    final content = _messageController.text.trim();

    if (hash.isEmpty || content.isEmpty) return;

    setState(() => _sending = true);

    final lxmf = ref.read(lxmfServiceProvider);
    final id = await lxmf.sendMessage(
      recipientHash: hash,
      content: content,
    );

    // Create conversation locally
    final message = LxmfMessage(
      id: id,
      senderHash: 'local_identity',
      recipientHash: hash,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      isOutgoing: true,
    );

    ref.read(conversationsProvider.notifier).addMessage(hash, message);

    if (mounted) {
      context.go('/chat/$hash');
    }
  }

  @override
  Widget build(BuildContext context) {
    final peers = ref.watch(peersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Message'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Recipient input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _hashController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Recipient Hash',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintText: 'Enter destination hash...',
                hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.darkBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
              ),
            ),
          ),

          // Peer suggestions
          if (peers.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Known Peers',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: peers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final peer = peers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.electricPurple.withValues(alpha: 0.3),
                            child: Text(
                              (peer.name?.isNotEmpty ?? false) ? peer.name![0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                          title: Text(
                            (peer.name?.isNotEmpty ?? false) ? peer.name! : 'Unknown',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            '${peer.hash.substring(0, 16)}...',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          onTap: () {
                            _hashController.text = peer.hash;
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.deepPurple,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                        filled: true,
                        fillColor: AppColors.darkBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 4,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sending
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : GestureDetector(
                          onTap: _send,
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
          ),
        ],
      ),
    );
  }
}
