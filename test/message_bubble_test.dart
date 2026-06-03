import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reticulum_wave/models/models.dart';
import 'package:reticulum_wave/widgets/message_bubble.dart';

void main() {
  group('MessageBubble', () {
    final sentMessage = LxmfMessage(
      id: '1',
      senderHash: 'me',
      recipientHash: 'you',
      content: 'Hello there',
      timestamp: DateTime(2026, 6, 3, 14, 30),
      status: MessageStatus.sent,
      isOutgoing: true,
    );

    final receivedMessage = LxmfMessage(
      id: '2',
      senderHash: 'you',
      recipientHash: 'me',
      content: 'General Kenobi',
      timestamp: DateTime(2026, 6, 3, 14, 31),
      status: MessageStatus.delivered,
      isOutgoing: false,
    );

    testWidgets('renders outgoing message with check icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: sentMessage),
          ),
        ),
      );

      expect(find.text('Hello there'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('renders incoming message without status icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: receivedMessage),
          ),
        ),
      );

      expect(find.text('General Kenobi'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('long press opens reply/forward actions', (tester) async {
      bool replied = false;
      bool forwarded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: sentMessage,
              onReply: () => replied = true,
              onForward: () => forwarded = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Hello there'));
      await tester.pumpAndSettle();

      expect(find.text('Reply'), findsOneWidget);
      expect(find.text('Forward'), findsOneWidget);

      await tester.tap(find.text('Reply'));
      await tester.pumpAndSettle();

      expect(replied, isTrue);
      expect(forwarded, isFalse);
    });

    testWidgets('shows reply preview when replyToId is set', (tester) async {
      final replyMessage = sentMessage.copyWith(replyToId: 'parent');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: replyMessage),
          ),
        ),
      );

      expect(find.text('Replying to message'), findsOneWidget);
    });
  });
}
