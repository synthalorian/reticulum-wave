import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// Holds the list of conversations and handles CRUD operations.
/// Supports pagination for large conversation lists.
class ConversationsNotifier extends StateNotifier<List<Conversation>> {
  ConversationsNotifier() : super([]);

  static const int pageSize = 20;
  int _loadedCount = 0;

  /// Load the next page of conversations from a full list.
  void loadPage(List<Conversation> all, {bool refresh = false}) {
    if (refresh) _loadedCount = 0;
    final end = (_loadedCount + pageSize).clamp(0, all.length);
    final page = all.sublist(0, end);
    _loadedCount = page.length;
    state = page;
  }

  bool get hasMore => _loadedCount < state.length;

  void addConversation(Conversation conversation) {
    state = [...state, conversation];
  }

  void removeConversation(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  void addMessage(String conversationId, LxmfMessage message) {
    state = state.map((c) {
      if (c.id == conversationId) {
        final updatedMessages = [...c.messages, message];
        return c.copyWith(
          messages: updatedMessages,
          lastActivityAt: message.timestamp,
          unreadCount: message.isOutgoing ? c.unreadCount : c.unreadCount + 1,
        );
      }
      return c;
    }).toList();
  }

  void markAsRead(String conversationId) {
    state = state.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(unreadCount: 0);
      }
      return c;
    }).toList();
  }

  void togglePin(String conversationId) {
    state = state.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(isPinned: !c.isPinned);
      }
      return c;
    }).toList();
  }

  void updateMessageStatus(String conversationId, String messageId, MessageStatus status) {
    state = state.map((c) {
      if (c.id == conversationId) {
        final updatedMessages = c.messages.map((m) {
          if (m.id == messageId) {
            return m.copyWith(status: status);
          }
          return m;
        }).toList();
        return c.copyWith(messages: updatedMessages);
      }
      return c;
    }).toList();
  }

  void clearAll() {
    state = [];
    _loadedCount = 0;
  }
}

/// Provider for the conversations list.
final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, List<Conversation>>(
  (ref) => ConversationsNotifier(),
);

/// Sorted conversations: pinned first, then by last activity.
final sortedConversationsProvider = Provider<List<Conversation>>((ref) {
  final conversations = ref.watch(conversationsProvider);
  final sorted = [...conversations];
  sorted.sort((a, b) {
    if (a.isPinned && !b.isPinned) return -1;
    if (!a.isPinned && b.isPinned) return 1;
    final aTime = a.lastActivityAt ?? a.createdAt;
    final bTime = b.lastActivityAt ?? b.createdAt;
    return bTime.compareTo(aTime);
  });
  return sorted;
});

/// Paginated conversations provider with lazy loading support.
final paginatedConversationsProvider = Provider<List<Conversation>>((ref) {
  final sorted = ref.watch(sortedConversationsProvider);
  final notifier = ref.read(conversationsProvider.notifier);
  notifier.loadPage(sorted);
  return ref.watch(conversationsProvider);
});
