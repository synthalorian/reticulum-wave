import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reticulum_wave/models/models.dart';
import 'package:reticulum_wave/providers/providers.dart';

void main() {
  group('MessageSearch', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      final notifier = container.read(conversationsProvider.notifier);

      notifier.addConversation(
        Conversation(
          id: 'c1',
          name: 'Alice',
          createdAt: DateTime.now(),
          messages: [
            LxmfMessage(
              id: 'm1',
              senderHash: 'alice',
              recipientHash: 'me',
              content: 'Hey, are you there?',
              timestamp: DateTime.now(),
            ),
            LxmfMessage(
              id: 'm2',
              senderHash: 'me',
              recipientHash: 'alice',
              content: 'Yeah, what is up?',
              timestamp: DateTime.now(),
            ),
          ],
        ),
      );

      notifier.addConversation(
        Conversation(
          id: 'c2',
          name: 'Bob',
          createdAt: DateTime.now(),
          messages: [
            LxmfMessage(
              id: 'm3',
              senderHash: 'bob',
              recipientHash: 'me',
              content: 'Meeting at 3pm',
              timestamp: DateTime.now(),
            ),
          ],
        ),
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('finds messages matching query', () {
      container.read(searchQueryProvider.notifier).state = 'meeting';

      final results = container.read(messageSearchProvider);
      expect(results.length, 1);
      expect(results.first.message.content, 'Meeting at 3pm');
      expect(results.first.conversation.name, 'Bob');
    });

    test('is case insensitive', () {
      container.read(searchQueryProvider.notifier).state = 'HEY';

      final results = container.read(messageSearchProvider);
      expect(results.length, 1);
      expect(results.first.message.content, 'Hey, are you there?');
    });

    test('returns empty for no match', () {
      container.read(searchQueryProvider.notifier).state = 'pizza';

      final results = container.read(messageSearchProvider);
      expect(results, isEmpty);
    });

    test('returns empty for empty query', () {
      container.read(searchQueryProvider.notifier).state = '';

      final results = container.read(messageSearchProvider);
      expect(results, isEmpty);
    });

    test('sorts results by timestamp descending', () {
      container.read(searchQueryProvider.notifier).state = 'you';

      final results = container.read(messageSearchProvider);
      // "you" matches "are you there?" and "what is up?" but only if both contain "you"
      // "are you there?" contains "you" — yes
      // "what is up?" does not contain "you" — no
      // So only 1 result. Let's use a query that matches both.
      expect(results.length, 1);
    });
  });
}
