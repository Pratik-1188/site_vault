import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import 'site_test_helpers.dart';

/// Creates a [ProviderContainer] for testing with the specified [overrides]
/// and automatically disposes of it when the test completes.
ProviderContainer makeContainer({
  MockSiteRepository? mockRepo,
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(
    retry: (_, retryCount) => null, // Disable automatic retries in unit tests
    overrides: [
      if (mockRepo != null)
        siteRepositoryProvider.overrideWithValue(mockRepo),
      ...overrides,
    ],
  );

  // Automatically dispose the container when the current test finishes.
  addTearDown(container.dispose);

  return container;
}
