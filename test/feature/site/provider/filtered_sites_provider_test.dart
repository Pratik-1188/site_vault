import 'package:flutter_test/flutter_test.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import '../../../helpers/provider_container.dart';
import '../../../helpers/site_test_helpers.dart';

void main() {
  group('FilteredSitesProvider', () {
    late List<Site> testSites;

    setUp(() {
      testSites = [
        makeSite(
          id: '1',
          name: 'Apex Construction',
          firmId: 'firm-a',
          status: 'active',
          startedOn: DateTime(2026, 5, 10, 14, 30), // May 10, 2026
        ),
        makeSite(
          id: '2',
          name: 'Apex Residential',
          firmId: 'firm-a',
          status: 'completed',
          startedOn: DateTime(2026, 5, 20), // May 20, 2026
        ),
        makeSite(
          id: '3',
          name: 'Bravo Office Park',
          firmId: 'firm-b',
          status: 'active',
          startedOn: DateTime(2026, 6, 1), // June 1, 2026
        ),
        makeSite(
          id: '4',
          name: 'Charlie Highway',
          firmId: 'firm-c',
          status: 'active',
          startedOn: null, // No started date
        ),
      ];
    });

    test('no filters set should return all sites', () async {
      final container = makeContainer(
        overrides: [
          sitesProvider.overrideWith((ref) => testSites),
        ],
      );

      final result = await container.read(filteredSitesProvider.future);
      expect(result.length, equals(4));
      expect(result, equals(testSites));
    });

    group('Firm Filter', () {
      test('should filter sites by selected firm', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        container.read(selectedFirmProvider.notifier).update('firm-a');

        final result = await container.read(filteredSitesProvider.future);
        expect(result.length, equals(2));
        expect(result.every((site) => site.firmId == 'firm-a'), isTrue);
      });

      test('should return empty list if selected firm matches nothing', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        container.read(selectedFirmProvider.notifier).update('firm-nonexistent');

        final result = await container.read(filteredSitesProvider.future);
        expect(result, isEmpty);
      });

      test('null firm filter should show all firms', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        container.read(selectedFirmProvider.notifier).update(null);

        final result = await container.read(filteredSitesProvider.future);
        expect(result.length, equals(4));
      });
    });

    group('Status Filter', () {
      test('should filter sites by selected status', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        container.read(selectedStatusProvider.notifier).update('completed');

        final result = await container.read(filteredSitesProvider.future);
        expect(result.length, equals(1));
        expect(result.first.id, equals('2'));
      });

      test('should return empty list if selected status matches nothing', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        container.read(selectedStatusProvider.notifier).update('inactive');

        final result = await container.read(filteredSitesProvider.future);
        expect(result, isEmpty);
      });

      test('null status filter should show all statuses', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        container.read(selectedStatusProvider.notifier).update(null);

        final result = await container.read(filteredSitesProvider.future);
        expect(result.length, equals(4));
      });
    });

    group('Combined Firm & Status Filter', () {
      test('should filter sites by both firm and status simultaneously', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        container.read(selectedFirmProvider.notifier).update('firm-a');
        container.read(selectedStatusProvider.notifier).update('active');

        final result = await container.read(filteredSitesProvider.future);
        expect(result.length, equals(1));
        expect(result.first.id, equals('1'));
      });
    });

    group('Search Query Filter', () {
      test('should filter sites by name case-insensitively', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        container.read(searchQueryProvider.notifier).update('APEX');

        final result = await container.read(filteredSitesProvider.future);
        expect(result.length, equals(2));
        expect(result.every((site) => site.name.startsWith('Apex')), isTrue);
      });

      test('should trim leading and trailing whitespaces from the search query', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        container.read(searchQueryProvider.notifier).update('  bravo  ');

        final result = await container.read(filteredSitesProvider.future);
        expect(result.length, equals(1));
        expect(result.first.id, equals('3'));
      });

      test('empty search query should not filter out any sites', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        container.read(searchQueryProvider.notifier).update('');

        final result = await container.read(filteredSitesProvider.future);
        expect(result.length, equals(4));
      });
    });

    group('Date Range Filter', () {
      test('should exclude sites without a startedOn date if any date filter is set', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        container.read(startedDateRangeProvider.notifier).update(
              DateRange(from: DateTime(2026, 1, 1)),
            );

        final result = await container.read(filteredSitesProvider.future);
        // Excludes 'Charlie Highway' which has null startedOn
        expect(result.any((s) => s.id == '4'), isFalse);
      });

      test('should include sites without a startedOn date if date range filter is empty', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        final result = await container.read(filteredSitesProvider.future);
        expect(result.any((s) => s.id == '4'), isTrue);
      });

      test('should filter by from date (day-level comparison)', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        // Site 1 started on May 10 14:30. Let's filter from May 10 (day level inclusive)
        container.read(startedDateRangeProvider.notifier).update(
              DateRange(from: DateTime(2026, 5, 10, 23, 59)),
            );

        final result = await container.read(filteredSitesProvider.future);
        // Should include Site 1 (May 10), Site 2 (May 20), Site 3 (June 1)
        expect(result.length, equals(3));
        expect(result.any((s) => s.id == '1'), isTrue);
        expect(result.any((s) => s.id == '2'), isTrue);
        expect(result.any((s) => s.id == '3'), isTrue);
      });

      test('should exclude sites before from date', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        // Filter from May 11
        container.read(startedDateRangeProvider.notifier).update(
              DateRange(from: DateTime(2026, 5, 11)),
            );

        final result = await container.read(filteredSitesProvider.future);
        // Excludes May 10, includes May 20 & June 1
        expect(result.length, equals(2));
        expect(result.any((s) => s.id == '1'), isFalse);
      });

      test('should filter by to date (day-level comparison)', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        // Filter up to May 20
        container.read(startedDateRangeProvider.notifier).update(
              DateRange(to: DateTime(2026, 5, 20, 0, 1)),
            );

        final result = await container.read(filteredSitesProvider.future);
        // Includes May 10 & May 20, excludes June 1
        expect(result.length, equals(2));
        expect(result.any((s) => s.id == '1'), isTrue);
        expect(result.any((s) => s.id == '2'), isTrue);
        expect(result.any((s) => s.id == '3'), isFalse);
      });

      test('should filter by both from and to date range', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        // Range: May 11 to May 25
        container.read(startedDateRangeProvider.notifier).update(
              DateRange(from: DateTime(2026, 5, 11), to: DateTime(2026, 5, 25)),
            );

        final result = await container.read(filteredSitesProvider.future);
        // Only Site 2 (May 20) fits
        expect(result.length, equals(1));
        expect(result.first.id, equals('2'));
      });
    });

    group('Pagination Reset Listeners', () {
      test('updating search query should reset visible count to 10', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        // Read filteredSites first to make sure listeners are active
        await container.read(filteredSitesProvider.future);

        // Set visible count to 30
        container.read(visibleCountProvider.notifier).update(30);
        expect(container.read(visibleCountProvider), equals(30));

        // Change filter
        container.read(searchQueryProvider.notifier).update('Apex');
        await pumpEventQueue();

        // Verify auto-reset to 10
        expect(container.read(visibleCountProvider), equals(10));
      });

      test('updating selected firm should reset visible count to 10', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        await container.read(filteredSitesProvider.future);
        container.read(visibleCountProvider.notifier).update(30);

        container.read(selectedFirmProvider.notifier).update('firm-b');
        await pumpEventQueue();

        expect(container.read(visibleCountProvider), equals(10));
      });

      test('updating selected status should reset visible count to 10', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        await container.read(filteredSitesProvider.future);
        container.read(visibleCountProvider.notifier).update(30);

        container.read(selectedStatusProvider.notifier).update('completed');
        await pumpEventQueue();

        expect(container.read(visibleCountProvider), equals(10));
      });

      test('updating date range should reset visible count to 10', () async {
        final container = makeContainer(
          overrides: [
            sitesProvider.overrideWith((ref) => testSites),
          ],
        );

        await container.read(filteredSitesProvider.future);
        container.read(visibleCountProvider.notifier).update(30);

        container.read(startedDateRangeProvider.notifier).update(
              DateRange(from: DateTime(2026, 1, 1)),
            );
        await pumpEventQueue();

        expect(container.read(visibleCountProvider), equals(10));
      });
    });
  });
}
