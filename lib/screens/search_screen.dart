import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme.dart';

/// Full-screen message search across all conversations.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(messageSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search messages...',
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
            border: InputBorder.none,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: query.isEmpty
          ? const Center(
              child: Text(
                'Type to search messages',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : results.isEmpty
              ? const Center(
                  child: Text(
                    'No messages found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : Semantics(
                  label: 'Search results',
                  child: ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return Semantics(
                        label: 'Message from ${result.conversation.name}',
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.electricPurple.withValues(alpha: 0.2),
                            child: Text(
                              result.conversation.name.isNotEmpty
                                  ? result.conversation.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: AppColors.electricPurple),
                            ),
                          ),
                          title: Text(
                            result.conversation.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            result.message.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: Text(
                            _formatTime(result.message.timestamp),
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            context.push('/chat/${result.conversation.id}');
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return '${dt.month}/${dt.day}';
  }
}
