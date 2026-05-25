import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import '../../../helpers/provider_container.dart';
import '../../../helpers/site_test_helpers.dart';

void main() {
  late MockSiteRepository mockRepo;

  setUp(() {
    mockRepo = MockSiteRepository();
  });

  group('SitesProvider', () {
    test('should fetch and return list of sites from repository successfully', () async {
      final site1 = makeSite(id: '1', name: 'Site One');
      final site2 = makeSite(id: '2', name: 'Site Two');
      final expectedSites = [site1, site2];

      when(() => mockRepo.fetchSites()).thenAnswer((_) async => expectedSites);

      final container = makeContainer(mockRepo: mockRepo);

      final states = <AsyncValue<List<Site>>>[];
      container.listen(
        sitesProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      final result = await container.read(sitesProvider.future);

      expect(result, equals(expectedSites));
      expect(states.first, isA<AsyncLoading<List<Site>>>());
      expect(states.last, isA<AsyncData<List<Site>>>());
      expect(states.last.value, equals(expectedSites));
      verify(() => mockRepo.fetchSites()).called(1);
    });

    test('should propagate error state when repository throws exception', () async {
      final exception = Exception('Database connection failed');
      when(() => mockRepo.fetchSites()).thenThrow(exception);

      final container = makeContainer(mockRepo: mockRepo);

      final states = <AsyncValue<List<Site>>>[];
      container.listen(
        sitesProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      // Verify that the future throws
      expect(container.read(sitesProvider.future), throwsA(equals(exception)));

      // Give event loop a microsecond to propagate state to notifier
      await pumpEventQueue();

      expect(states.first, isA<AsyncLoading<List<Site>>>());
      expect(states.last, isA<AsyncError<List<Site>>>());
      expect(states.last.error, equals(exception));
      verify(() => mockRepo.fetchSites()).called(1);
    });

    test('should return empty list when repository returns empty', () async {
      when(() => mockRepo.fetchSites()).thenAnswer((_) async => []);

      final container = makeContainer(mockRepo: mockRepo);

      final result = await container.read(sitesProvider.future);

      expect(result, isEmpty);
      verify(() => mockRepo.fetchSites()).called(1);
    });
  });
}
