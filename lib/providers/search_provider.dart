import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// Search query string.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Whether search is active.
final searchActiveProvider = StateProvider<bool>((ref) => false);

/// Search results: messages matching query across all conversations.
final messageSearchProvider = Provider<List<SearchResult>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final conversations = ref.watch(conversationsProvider);

  if (query.isEmpty) return [];

  final results = <SearchResult>[];
  for (final conv in conversations) {
    for (final msg in conv.messages) {
      if (msg.content.toLowerCase().contains(query)) {
        results.add(SearchResult(
          message: msg,
          conversation: conv,
        ));
      }
    }
  }

  // Sort by timestamp descending
  results.sort((a, b) => b.message.timestamp.compareTo(a.message.timestamp));
  return results;
});

/// A single search result linking a message to its conversation.
class SearchResult {
  const SearchResult({
    required this.message,
    required this.conversation,
  });

  final LxmfMessage message;
  final Conversation conversation;
}
