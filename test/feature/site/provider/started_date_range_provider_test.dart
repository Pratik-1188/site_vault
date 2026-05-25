import 'package:flutter_test/flutter_test.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import '../../../helpers/provider_container.dart';

void main() {
  group('StartedDateRangeProvider', () {
    test('default state should be an empty DateRange (from and to are null)', () {
      final container = makeContainer();

      final initialVal = container.read(startedDateRangeProvider);
      expect(initialVal.from, isNull);
      expect(initialVal.to, isNull);
    });

    test('update with from date should set from date only', () {
      final container = makeContainer();
      final fromDate = DateTime(2026, 1, 1);

      container.read(startedDateRangeProvider.notifier).update(
            DateRange(from: fromDate),
          );

      final val = container.read(startedDateRangeProvider);
      expect(val.from, equals(fromDate));
      expect(val.to, isNull);
    });

    test('update with to date should set to date only', () {
      final container = makeContainer();
      final toDate = DateTime(2026, 12, 31);

      container.read(startedDateRangeProvider.notifier).update(
            DateRange(to: toDate),
          );

      final val = container.read(startedDateRangeProvider);
      expect(val.from, isNull);
      expect(val.to, equals(toDate));
    });

    test('update with both from and to dates should set both', () {
      final container = makeContainer();
      final fromDate = DateTime(2026, 1, 1);
      final toDate = DateTime(2026, 12, 31);

      container.read(startedDateRangeProvider.notifier).update(
            DateRange(from: fromDate, to: toDate),
          );

      final val = container.read(startedDateRangeProvider);
      expect(val.from, equals(fromDate));
      expect(val.to, equals(toDate));
    });

    test('updating to a new DateRange should override the old values', () {
      final container = makeContainer();
      final fromDate = DateTime(2026, 1, 1);
      final toDate = DateTime(2026, 12, 31);

      container.read(startedDateRangeProvider.notifier).update(
            DateRange(from: fromDate, to: toDate),
          );

      final newFromDate = DateTime(2026, 6, 1);
      container.read(startedDateRangeProvider.notifier).update(
            DateRange(from: newFromDate),
          );

      final val = container.read(startedDateRangeProvider);
      expect(val.from, equals(newFromDate));
      expect(val.to, isNull);
    });
  });
}
