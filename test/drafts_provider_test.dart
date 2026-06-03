import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reticulum_wave/providers/providers.dart';

void main() {
  group('DraftsNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('saves and retrieves draft per conversation', () async {
      final notifier = container.read(draftsProvider.notifier);

      notifier.setDraft('conv1', 'Hello');
      await Future.delayed(const Duration(milliseconds: 400));

      expect(container.read(draftsProvider)['conv1'], 'Hello');
      expect(container.read(draftsProvider)['conv2'], isNull);
    });

    test('clears draft', () async {
      final notifier = container.read(draftsProvider.notifier);

      notifier.setDraft('conv1', 'Hello');
      await Future.delayed(const Duration(milliseconds: 400));
      notifier.clearDraft('conv1');

      expect(container.read(draftsProvider)['conv1'], isNull);
    });

    test('debounces rapid updates', () async {
      final notifier = container.read(draftsProvider.notifier);

      notifier.setDraft('conv1', 'a');
      notifier.setDraft('conv1', 'ab');
      notifier.setDraft('conv1', 'abc');

      // Before debounce
      expect(container.read(draftsProvider)['conv1'], isNull);

      await Future.delayed(const Duration(milliseconds: 400));
      expect(container.read(draftsProvider)['conv1'], 'abc');
    });
  });
}
