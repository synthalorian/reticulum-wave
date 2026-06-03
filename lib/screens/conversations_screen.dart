import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/conversation_tile.dart';

/// Messages tab — lists all conversations with mock data pre-loaded.
/// Listens to incoming messages and peer discovery to auto-update.
class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load mock conversations on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(conversationsProvider.notifier);
      for (final c in MockData.conversations) {
        notifier.addConversation(c);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(conversationsProvider.notifier);
      if (notifier.hasMore) {
        final all = ref.read(sortedConversationsProvider);
        notifier.loadPage(all);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(sortedConversationsProvider);

    // Listen for incoming messages
    ref.listen<AsyncValue<LxmfMessage>>(incomingMessagesProvider, (_, asyncMessage) {
      asyncMessage.whenData((message) {
        _handleIncomingMessage(message);
      });
    });

    // Listen for peer discovery to auto-create conversations
    ref.listen<AsyncValue<Peer>>(peerDiscoveryProvider, (_, asyncPeer) {
      asyncPeer.whenData((peer) {
        _ensureConversationForPeer(peer);
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            onPressed: () {
              context.push('/search');
            },
          ),
        ],
      ),
      body: conversations.isEmpty
          ? const Center(
              child: Text(
                'No conversations yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              controller: _scrollController,
              itemCount: conversations.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 72,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return ConversationTile(
                  conversation: conv,
                  onTap: () {
                    context.push('/chat/${conv.id}');
                  },
                  onPinToggle: () {
                    ref.read(conversationsProvider.notifier).togglePin(conv.id);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/compose');
        },
        tooltip: 'New message',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleIncomingMessage(LxmfMessage message) {
    final notifier = ref.read(conversationsProvider.notifier);
    final conversations = ref.read(conversationsProvider);

    // Find conversation by sender hash
    final conversationId = message.senderHash;
    final existing = conversations.where((c) => c.id == conversationId).firstOrNull;

    if (existing != null) {
      notifier.addMessage(conversationId, message);
    } else {
      // Create new conversation for this peer
      final peer = ref.read(peersProvider).where((p) => p.hash == message.senderHash).firstOrNull;
      final newConv = Conversation(
        id: conversationId,
        name: peer?.name ?? 'Unknown Node',
        peerHash: conversationId,
        messages: [message],
        unreadCount: 1,
        createdAt: DateTime.now(),
        lastActivityAt: message.timestamp,
      );
      notifier.addConversation(newConv);
    }
  }

  void _ensureConversationForPeer(Peer peer) {
    final conversations = ref.read(conversationsProvider);
    final exists = conversations.any((c) => c.peerHash == peer.hash);
    if (exists) return;

    final notifier = ref.read(conversationsProvider.notifier);
    final newConv = Conversation(
      id: peer.hash,
      name: peer.name ?? 'Unknown Node',
      peerHash: peer.hash,
      createdAt: DateTime.now(),
    );
    notifier.addConversation(newConv);
  }
}
