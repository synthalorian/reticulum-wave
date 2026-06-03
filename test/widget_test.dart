import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reticulum_wave/app.dart';

void main() {
  testWidgets('App renders with bottom nav tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ReticulumWaveApp()),
    );

    // NavigationBar labels are rendered as text
    expect(find.text('Messages'), findsWidgets);
    expect(find.text('Network'), findsWidgets);
    expect(find.text('Map'), findsWidgets);
    expect(find.text('RNode'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
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
}
