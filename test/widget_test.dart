import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reticulum_wave/app.dart';

void main() {
  testWidgets('App renders with bottom nav and all tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ReticulumWaveApp()),
    );

    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Network'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('RNode'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Conversations screen loads mock data', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ReticulumWaveApp()),
    );

    // Wait for mock data to load
    await tester.pumpAndSettle();

    // Should find at least one conversation from mock data
    expect(find.text('Nomad Node 7'), findsOneWidget);
  });

  testWidgets('Settings screen shows version', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ReticulumWaveApp()),
    );

    // Tap Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('0.1.0 (alpha)'), findsOneWidget);
  });
}
