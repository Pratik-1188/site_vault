import 'package:flutter_test/flutter_test.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import '../../../helpers/provider_container.dart';

void main() {
  group('SelectedFirmProvider', () {
    test('default state should be null', () {
      final container = makeContainer();

      final initialVal = container.read(selectedFirmProvider);
      expect(initialVal, isNull);
    });

    test('update should change the state to the new firm value', () {
      final container = makeContainer();

      container.read(selectedFirmProvider.notifier).update('firm-abc');
      expect(container.read(selectedFirmProvider), equals('firm-abc'));
    });

    test('update(null) should reset the state to null', () {
      final container = makeContainer();

      container.read(selectedFirmProvider.notifier).update('firm-abc');
      expect(container.read(selectedFirmProvider), equals('firm-abc'));

      container.read(selectedFirmProvider.notifier).update(null);
      expect(container.read(selectedFirmProvider), isNull);
    });

    test('multiple updates should successfully overwrite previous state', () {
      final container = makeContainer();

      container.read(selectedFirmProvider.notifier).update('firm-1');
      expect(container.read(selectedFirmProvider), equals('firm-1'));

      container.read(selectedFirmProvider.notifier).update('firm-2');
      expect(container.read(selectedFirmProvider), equals('firm-2'));
    });
  });
}
