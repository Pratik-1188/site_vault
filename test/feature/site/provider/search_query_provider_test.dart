import 'package:flutter_test/flutter_test.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import '../../../helpers/provider_container.dart';

void main() {
  group('SearchQueryProvider', () {
    test('default state should be an empty string', () {
      final container = makeContainer();

      final initialVal = container.read(searchQueryProvider);
      expect(initialVal, equals(''));
    });

    test('update should change the state to the query string', () {
      final container = makeContainer();

      container.read(searchQueryProvider.notifier).update('Construction');
      expect(container.read(searchQueryProvider), equals('Construction'));
    });

    test('update should keep whitespace as-is (query trimming handled by downstream filters)', () {
      final container = makeContainer();

      container.read(searchQueryProvider.notifier).update('  spaces  ');
      expect(container.read(searchQueryProvider), equals('  spaces  '));
    });

    test('update("") should clear the query', () {
      final container = makeContainer();

      container.read(searchQueryProvider.notifier).update('temp');
      expect(container.read(searchQueryProvider), equals('temp'));

      container.read(searchQueryProvider.notifier).update('');
      expect(container.read(searchQueryProvider), equals(''));
    });
  });
}
