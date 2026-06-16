// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides DocumentRepository singleton

@ProviderFor(documentRepository)
final documentRepositoryProvider = DocumentRepositoryProvider._();

/// Provides DocumentRepository singleton

final class DocumentRepositoryProvider
    extends
        $FunctionalProvider<
          DocumentRepository,
          DocumentRepository,
          DocumentRepository
        >
    with $Provider<DocumentRepository> {
  /// Provides DocumentRepository singleton
  DocumentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentRepositoryHash();

  @$internal
  @override
  $ProviderElement<DocumentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentRepository create(Ref ref) {
    return documentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentRepository>(value),
    );
  }
}

String _$documentRepositoryHash() =>
    r'ec311dfe105cb72f52c24d857c2136842c9c6872';

/// Active text search query for filtering documents

@ProviderFor(DocumentSearchQuery)
final documentSearchQueryProvider = DocumentSearchQueryProvider._();

/// Active text search query for filtering documents
final class DocumentSearchQueryProvider
    extends $NotifierProvider<DocumentSearchQuery, String> {
  /// Active text search query for filtering documents
  DocumentSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentSearchQueryHash();

  @$internal
  @override
  DocumentSearchQuery create() => DocumentSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$documentSearchQueryHash() =>
    r'15be17abdcc47f4e693f12328075bbf4d7cf58ee';

/// Active text search query for filtering documents

abstract class _$DocumentSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Async controller for managing all active site-specific document records.
///
/// Implements database read, write, and soft-delete operations
/// while reactively notifying dependent widgets.

@ProviderFor(SiteDocuments)
final siteDocumentsProvider = SiteDocumentsFamily._();

/// Async controller for managing all active site-specific document records.
///
/// Implements database read, write, and soft-delete operations
/// while reactively notifying dependent widgets.
final class SiteDocumentsProvider
    extends $AsyncNotifierProvider<SiteDocuments, List<SiteDocument>> {
  /// Async controller for managing all active site-specific document records.
  ///
  /// Implements database read, write, and soft-delete operations
  /// while reactively notifying dependent widgets.
  SiteDocumentsProvider._({
    required SiteDocumentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siteDocumentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteDocumentsHash();

  @override
  String toString() {
    return r'siteDocumentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SiteDocuments create() => SiteDocuments();

  @override
  bool operator ==(Object other) {
    return other is SiteDocumentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteDocumentsHash() => r'99daf4af69d0fc48596f29ac15fa245773f0f4f7';

/// Async controller for managing all active site-specific document records.
///
/// Implements database read, write, and soft-delete operations
/// while reactively notifying dependent widgets.

final class SiteDocumentsFamily extends $Family
    with
        $ClassFamilyOverride<
          SiteDocuments,
          AsyncValue<List<SiteDocument>>,
          List<SiteDocument>,
          FutureOr<List<SiteDocument>>,
          String
        > {
  SiteDocumentsFamily._()
    : super(
        retry: null,
        name: r'siteDocumentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Async controller for managing all active site-specific document records.
  ///
  /// Implements database read, write, and soft-delete operations
  /// while reactively notifying dependent widgets.

  SiteDocumentsProvider call(String siteId) =>
      SiteDocumentsProvider._(argument: siteId, from: this);

  @override
  String toString() => r'siteDocumentsProvider';
}

/// Async controller for managing all active site-specific document records.
///
/// Implements database read, write, and soft-delete operations
/// while reactively notifying dependent widgets.

abstract class _$SiteDocuments extends $AsyncNotifier<List<SiteDocument>> {
  late final _$args = ref.$arg as String;
  String get siteId => _$args;

  FutureOr<List<SiteDocument>> build(String siteId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SiteDocument>>, List<SiteDocument>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SiteDocument>>, List<SiteDocument>>,
              AsyncValue<List<SiteDocument>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Filtered site documents selector combining raw list with active filename searches

@ProviderFor(filteredSiteDocuments)
final filteredSiteDocumentsProvider = FilteredSiteDocumentsFamily._();

/// Filtered site documents selector combining raw list with active filename searches

final class FilteredSiteDocumentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SiteDocument>>,
          List<SiteDocument>,
          FutureOr<List<SiteDocument>>
        >
    with
        $FutureModifier<List<SiteDocument>>,
        $FutureProvider<List<SiteDocument>> {
  /// Filtered site documents selector combining raw list with active filename searches
  FilteredSiteDocumentsProvider._({
    required FilteredSiteDocumentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'filteredSiteDocumentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredSiteDocumentsHash();

  @override
  String toString() {
    return r'filteredSiteDocumentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SiteDocument>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SiteDocument>> create(Ref ref) {
    final argument = this.argument as String;
    return filteredSiteDocuments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredSiteDocumentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredSiteDocumentsHash() =>
    r'2e372cc1112837d5584cdb24b1a98aae016ebb13';

/// Filtered site documents selector combining raw list with active filename searches

final class FilteredSiteDocumentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SiteDocument>>, String> {
  FilteredSiteDocumentsFamily._()
    : super(
        retry: null,
        name: r'filteredSiteDocumentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Filtered site documents selector combining raw list with active filename searches

  FilteredSiteDocumentsProvider call(String siteId) =>
      FilteredSiteDocumentsProvider._(argument: siteId, from: this);

  @override
  String toString() => r'filteredSiteDocumentsProvider';
}
