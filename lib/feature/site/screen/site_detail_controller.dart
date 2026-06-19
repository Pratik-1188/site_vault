import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:site_vault/feature/auth/provider/auth_provider.dart';
import 'package:site_vault/feature/document/model/document.dart';
import 'package:site_vault/feature/document/provider/document_provider.dart';
import 'package:site_vault/feature/expense/model/expense.dart';
import 'package:site_vault/feature/expense/provider/expense_provider.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import 'package:site_vault/shared/model/firm.dart';
import 'package:site_vault/shared/provider/firm_provider.dart';
import 'package:site_vault/shared/utils/error_interceptor.dart';

import 'site_detail_dialogs.dart';

@immutable
class SiteDetailContextParams {
  final String siteId;
  final Site? initialSite;

  const SiteDetailContextParams({
    required this.siteId,
    this.initialSite,
  });

  @override
  bool operator ==(Object other) {
    return other is SiteDetailContextParams &&
        other.siteId == siteId &&
        other.initialSite?.id == initialSite?.id;
  }

  @override
  int get hashCode => Object.hash(siteId, initialSite?.id);
}

@immutable
class SiteDetailContext {
  final AsyncValue<Site> siteAsync;
  final Site? site;
  final String? firmName;
  final bool isEditable;

  const SiteDetailContext({
    required this.siteAsync,
    required this.site,
    required this.firmName,
    required this.isEditable,
  });
}

final siteDetailContextProvider =
    Provider.family<SiteDetailContext, SiteDetailContextParams>((ref, params) {
  final siteAsync = ref.watch(siteDetailsProvider(params.siteId));
  final firmsAsync = ref.watch(firmsProvider);

  final site = siteAsync.maybeWhen(
    data: (data) => data,
    orElse: () => params.initialSite,
  );
  final firms = firmsAsync.maybeWhen(
    data: (data) => data,
    orElse: () => const <Firm>[],
  );
  String? firmName;

  if (site != null) {
    for (final firm in firms) {
      if (firm.id == site.firmId) {
        firmName = firm.name;
        break;
      }
    }
  }

  return SiteDetailContext(
    siteAsync: siteAsync,
    site: site,
    firmName: firmName,
    isEditable: (site?.status ?? 'active') == 'active',
  );
});

@immutable
class SiteDetailState {
  final int currentTabIndex;
  final bool isSaving;

  const SiteDetailState({
    this.currentTabIndex = 0,
    this.isSaving = false,
  });

  SiteDetailState copyWith({
    int? currentTabIndex,
    bool? isSaving,
  }) {
    return SiteDetailState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class SiteDetailController extends ChangeNotifier {
  SiteDetailController(this.ref, this.siteId);

  final Ref ref;
  final String siteId;
  SiteDetailState _state = const SiteDetailState();

  SiteDetailState get state => _state;

  void setTabIndex(int index) {
    if (_state.currentTabIndex == index) return;
    _state = _state.copyWith(currentTabIndex: index);
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    final confirmed = await SiteDetailDialogs.confirmSignOut(context);
    if (confirmed != true) return;

    try {
      await ref.read(authActionsProvider).signOut();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> saveSiteSettings(
    BuildContext context, {
    required String name,
    required String description,
    required DateTime startedOn,
    String? status,
    Site? currentSite,
  }) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a site name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _state = _state.copyWith(isSaving: true);
    notifyListeners();
    try {
      final previousStatus = currentSite?.status ?? 'active';
      final targetStatus = status ?? previousStatus;

      if (targetStatus != previousStatus) {
        final confirmed = await SiteDetailDialogs.confirmStatusChange(
          context,
          fromStatus: previousStatus,
          toStatus: targetStatus,
          siteName: currentSite?.name ?? name,
        );
        if (confirmed != true) {
          return;
        }
      }

      final completedOn = targetStatus == 'completed' ? DateTime.now() : null;

      await ref.read(siteActionsProvider).updateSite(
            siteId: siteId,
            name: name.trim(),
            description: description.trim().isEmpty ? null : description.trim(),
            startedOn: startedOn,
            status: targetStatus,
            completedOn: completedOn,
          );

      ref.invalidate(siteDetailsProvider(siteId));
      ref.invalidate(sitesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site settings updated successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      _state = _state.copyWith(isSaving: false);
      notifyListeners();
    }
  }

  Future<void> deleteExpense(
    BuildContext context, {
    required Expense expense,
  }) async {
    final confirmed = await SiteDetailDialogs.confirmDeleteExpense(
      context,
      expense: expense,
    );
    if (confirmed != true) return;

    try {
      await ref.read(siteExpensesProvider(siteId).notifier).deleteExpense(
            expense.id,
          );
      ref.invalidate(siteTotalExpensesProvider(siteId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> deleteDocument(
    BuildContext context, {
    required SiteDocument document,
  }) async {
    final confirmed = await SiteDetailDialogs.confirmDeleteDocument(
      context,
      document: document,
    );
    if (confirmed != true) return;

    try {
      await ref.read(siteDocumentsProvider(siteId).notifier).deleteDocument(
            document.id,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> refresh() async {
    ref.invalidate(siteDetailsProvider(siteId));
    ref.invalidate(sitesProvider);
    ref.invalidate(siteExpensesProvider(siteId));
    ref.invalidate(siteTotalExpensesProvider(siteId));
    ref.invalidate(siteDocumentsProvider(siteId));
    ref.invalidate(filteredSiteExpensesProvider(siteId));
    ref.invalidate(filteredSiteDocumentsProvider(siteId));
  }
}

final siteDetailControllerProvider = Provider.family<SiteDetailController, String>(
  (ref, siteId) {
    final controller = SiteDetailController(ref, siteId);
    ref.onDispose(controller.dispose);
    return controller;
  },
);
