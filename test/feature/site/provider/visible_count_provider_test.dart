import 'package:flutter_test/flutter_test.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import '../../../helpers/provider_container.dart';

void main() {
  group('VisibleCountProvider', () {
    test('default state should be 10', () {
      final container = makeContainer();

      final initialVal = container.read(visibleCountProvider);
      expect(initialVal, equals(10));
    });

    test('update should set the state to the explicit value', () {
      final container = makeContainer();

      container.read(visibleCountProvider.notifier).update(25);
      expect(container.read(visibleCountProvider), equals(25));
    });

    test('increment should add the given amount to the current state', () {
      final container = makeContainer();

      container.read(visibleCountProvider.notifier).increment(5);
      expect(container.read(visibleCountProvider), equals(15));

      container.read(visibleCountProvider.notifier).increment(10);
      expect(container.read(visibleCountProvider), equals(25));
    });

    test('increment with 0 should keep the state unchanged', () {
      final container = makeContainer();

      container.read(visibleCountProvider.notifier).increment(0);
      expect(container.read(visibleCountProvider), equals(10));
    });
  });
}
