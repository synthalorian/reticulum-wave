import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds draft messages per conversation ID.
class DraftsNotifier extends StateNotifier<Map<String, String>> {
  DraftsNotifier() : super({});

  Timer? _debounce;

  void setDraft(String conversationId, String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      state = {...state, conversationId: text};
    });
  }

  String getDraft(String conversationId) {
    return state[conversationId] ?? '';
  }

  void clearDraft(String conversationId) {
    final copy = Map<String, String>.from(state);
    copy.remove(conversationId);
    state = copy;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

/// Provider for per-conversation draft messages.
final draftsProvider =
    StateNotifierProvider<DraftsNotifier, Map<String, String>>(
  (ref) => DraftsNotifier(),
);
