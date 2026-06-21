import 'package:flutter_test/flutter_test.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import 'package:site_vault/feature/site/model/site_status.dart';
import '../../../helpers/provider_container.dart';

void main() {
  group('SelectedStatusProvider', () {
    test("default state should be 'active'", () {
      final container = makeContainer();

      final initialVal = container.read(selectedStatusProvider);
      expect(initialVal, equals(SiteStatus.active));
    });

    test('update should change the state to the new status', () {
      final container = makeContainer();

      container.read(selectedStatusProvider.notifier).update(SiteStatus.active);
      expect(container.read(selectedStatusProvider), equals(SiteStatus.active));
    });

    test('update(null) should reset the state to null', () {
      final container = makeContainer();

      container.read(selectedStatusProvider.notifier).update(SiteStatus.completed);
      expect(container.read(selectedStatusProvider), equals(SiteStatus.completed));

      container.read(selectedStatusProvider.notifier).update(null);
      expect(container.read(selectedStatusProvider), isNull);
    });

    test('multiple updates should successfully overwrite previous status', () {
      final container = makeContainer();

      container.read(selectedStatusProvider.notifier).update(SiteStatus.active);
      expect(container.read(selectedStatusProvider), equals(SiteStatus.active));

      container.read(selectedStatusProvider.notifier).update(SiteStatus.completed);
      expect(container.read(selectedStatusProvider), equals(SiteStatus.completed));
    });
  });
}
