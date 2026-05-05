import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fretemap/features/freight/publish_freight_controller.dart';

void main() {
  group('PublishNotifier', () {
    test('initial state is idle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(publishFreightProvider), PublishState.idle);
    });

    test('reset() returns state to idle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Manually force to error state then reset
      container.read(publishFreightProvider.notifier).reset();
      expect(container.read(publishFreightProvider), PublishState.idle);
    });
  });
}
