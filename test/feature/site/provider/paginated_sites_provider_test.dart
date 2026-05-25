import 'package:flutter_test/flutter_test.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import '../../../helpers/provider_container.dart';
import '../../../helpers/site_test_helpers.dart';

void main() {
  group('PaginatedSitesProvider', () {
    test(
      'should return first 10 sites by default if there are more than 10 sites',
      () async {
        final list = List.generate(
          15,
          (index) => makeSite(id: 'site-$index', name: 'Site $index'),
        );

        final container = makeContainer(
          overrides: [filteredSitesProvider.overrideWith((ref) => list)],
        );

        final result = await container.read(paginatedSitesProvider.future);

        expect(result.length, equals(10));
        expect(result.first.id, equals('site-0'));
        expect(result.last.id, equals('site-9'));
      },
    );

    test(
      'should return all sites if total filtered sites is less than 10',
      () async {
        final list = List.generate(
          5,
          (index) => makeSite(id: 'site-$index', name: 'Site $index'),
        );

        final container = makeContainer(
          overrides: [filteredSitesProvider.overrideWith((ref) => list)],
        );

        final result = await container.read(paginatedSitesProvider.future);

        expect(result.length, equals(5));
        expect(result.first.id, equals('site-0'));
        expect(result.last.id, equals('site-4'));
      },
    );

    test(
      'should dynamically update slices when visibleCountProvider is updated',
      () async {
        final list = List.generate(
          15,
          (index) => makeSite(id: 'site-$index', name: 'Site $index'),
        );

        final container = makeContainer(
          overrides: [filteredSitesProvider.overrideWith((ref) => list)],
        );

        // Initial read (should be default 10)
        var result = await container.read(paginatedSitesProvider.future);
        expect(result.length, equals(10));

        // Update visible count to 12
        container.read(visibleCountProvider.notifier).update(12);

        // Re-read
        result = await container.read(paginatedSitesProvider.future);
        expect(result.length, equals(12));
        expect(result.last.id, equals('site-11'));
      },
    );

    test(
      'should return all sites if visibleCount is larger than list length',
      () async {
        final list = List.generate(
          5,
          (index) => makeSite(id: 'site-$index', name: 'Site $index'),
        );

        final container = makeContainer(
          overrides: [filteredSitesProvider.overrideWith((ref) => list)],
        );

        // Set visible count explicitly via its notifier
        container.read(visibleCountProvider.notifier).update(20);

        final result = await container.read(paginatedSitesProvider.future);

        expect(result.length, equals(5));
      },
    );

    test('should return empty list if visibleCount is 0', () async {
      final list = List.generate(
        5,
        (index) => makeSite(id: 'site-$index', name: 'Site $index'),
      );

      final container = makeContainer(
        overrides: [filteredSitesProvider.overrideWith((ref) => list)],
      );

      // Set visible count explicitly via its notifier
      container.read(visibleCountProvider.notifier).update(0);

      final result = await container.read(paginatedSitesProvider.future);

      expect(result, isEmpty);
    });
  });
}
