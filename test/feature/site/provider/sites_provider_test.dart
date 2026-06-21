import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/site/model/site_status.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import 'package:site_vault/shared/utils/financial_year.dart';
import '../../../helpers/provider_container.dart';
import '../../../helpers/site_test_helpers.dart';

void main() {
  late MockSiteRepository mockRepo;

  setUp(() {
    mockRepo = MockSiteRepository();
  });

  group('SitesProvider', () {
    test('should fetch and return list of sites from repository successfully', () async {
      final site1 = makeSite(id: '1', name: 'Site One', firmId: 'firm-a');
      final site2 = makeSite(id: '2', name: 'Site Two', firmId: 'firm-a');
      final expectedSites = [site1, site2];
      final fy = FinancialYear.current();

      when(() => mockRepo.fetchSites(
            firmId: 'firm-a',
            fromDate: fy.startDate,
            toDate: fy.endDate,
            status: SiteStatus.active,
          )).thenAnswer((_) async => expectedSites);

      final container = makeContainer(mockRepo: mockRepo);

      // Set the required firm
      container.read(selectedFirmProvider.notifier).update('firm-a');

      final states = <AsyncValue<List<Site>>>[];
      container.listen(
        sitesProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      final result = await container.read(sitesProvider.future);

      expect(result, equals(expectedSites));
      expect(states.any((s) => s is AsyncLoading), isTrue);
      expect(states.last, isA<AsyncData<List<Site>>>());
      expect(states.last.value, equals(expectedSites));
      verify(() => mockRepo.fetchSites(
            firmId: 'firm-a',
            fromDate: fy.startDate,
            toDate: fy.endDate,
            status: SiteStatus.active,
          )).called(1);
    });

    test('should propagate error state when repository throws exception', () async {
      final exception = Exception('Database connection failed');
      final fy = FinancialYear.current();

      when(() => mockRepo.fetchSites(
            firmId: 'firm-a',
            fromDate: fy.startDate,
            toDate: fy.endDate,
            status: SiteStatus.active,
          )).thenThrow(exception);

      final container = makeContainer(mockRepo: mockRepo);
      container.read(selectedFirmProvider.notifier).update('firm-a');

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

      expect(states.any((s) => s is AsyncLoading), isTrue);
      expect(states.last, isA<AsyncError<List<Site>>>());
      expect(states.last.error, equals(exception));
    });

    test('should return empty list when repository returns empty', () async {
      final fy = FinancialYear.current();
      when(() => mockRepo.fetchSites(
            firmId: 'firm-a',
            fromDate: fy.startDate,
            toDate: fy.endDate,
            status: SiteStatus.active,
          )).thenAnswer((_) async => []);

      final container = makeContainer(mockRepo: mockRepo);
      container.read(selectedFirmProvider.notifier).update('firm-a');

      final result = await container.read(sitesProvider.future);

      expect(result, isEmpty);
      verify(() => mockRepo.fetchSites(
            firmId: 'firm-a',
            fromDate: fy.startDate,
            toDate: fy.endDate,
            status: SiteStatus.active,
          )).called(1);
    });

    test('should return empty list immediately and not call repository if no firm selected', () async {
      final container = makeContainer(mockRepo: mockRepo);

      final result = await container.read(sitesProvider.future);

      expect(result, isEmpty);
      verifyNever(() => mockRepo.fetchSites(
            firmId: any(named: 'firmId'),
            fromDate: any(named: 'fromDate'),
            toDate: any(named: 'toDate'),
            status: any(named: 'status'),
            searchQuery: any(named: 'searchQuery'),
          ));
    });
  });
}
