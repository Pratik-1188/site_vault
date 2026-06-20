import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_vault/shared/provider/firm_provider.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';

/// A mixin that encapsulates the state and UI selection logic for 
/// the cascading Firm + Site selection.
mixin SiteScopeSelectorMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  String? selectedFirmId;
  String? selectedSiteId;
  List<Site>? activeSites;
  bool isLoadingSites = false;
  bool isContextLocked = false;

  /// Initializes the scope selector parameters.
  void initSiteScope({
    required String? initialFirmId,
    required String? initialSiteId,
    required bool isLocked,
  }) {
    selectedFirmId = initialFirmId;
    selectedSiteId = initialSiteId;
    isContextLocked = isLocked;

    if (selectedFirmId != null) {
      loadSitesForFirm(selectedFirmId!);
    }
  }

  /// Fetches active sites dynamically under the selected firm.
  Future<void> loadSitesForFirm(String firmId) async {
    if (!mounted) return;
    setState(() {
      isLoadingSites = true;
      activeSites = null;
    });

    try {
      final sitesList = await ref.read(activeSitesByFirmProvider(firmId).future);

      if (!mounted) return;
      setState(() {
        activeSites = sitesList;
        isLoadingSites = false;

        // Reset selected site if it is not in the newly loaded active sites list
        if (selectedSiteId != null &&
            !activeSites!.any((s) => s.id == selectedSiteId)) {
          selectedSiteId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        activeSites = [];
        isLoadingSites = false;
        selectedSiteId = null;
      });
    }
  }

  /// Builds the cascading Firm + Site scope selector UI.
  Widget buildScopeSelector(BuildContext context) {
    if (isContextLocked) return const SizedBox.shrink();

    final firmsAsync = ref.watch(firmsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Scope',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        firmsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (err, _) => Text('Error loading firms: $err'),
          data: (firms) {
            return DropdownButtonFormField<String>(
              initialValue: selectedFirmId,
              decoration: const InputDecoration(
                labelText: 'Firm',
                prefixIcon: Icon(Icons.business_rounded),
              ),
              items: firms.map((firm) {
                return DropdownMenuItem<String>(
                  value: firm.id,
                  child: Text(firm.name),
                );
              }).toList(),
              onChanged: isLoadingSites
                  ? null
                  : (val) {
                      if (val != null) {
                        setState(() {
                          selectedFirmId = val;
                          selectedSiteId = null;
                        });
                        loadSitesForFirm(val);
                      }
                    },
              validator: (val) => val == null ? 'Firm is required' : null,
            );
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedSiteId,
          decoration: InputDecoration(
            labelText: 'Site',
            prefixIcon: const Icon(Icons.location_on_rounded),
            suffixIcon: isLoadingSites
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          items: activeSites?.map((site) {
                return DropdownMenuItem<String>(
                  value: site.id,
                  child: Text(site.name),
                );
              }).toList() ??
              [],
          onChanged: (selectedFirmId == null || isLoadingSites)
              ? null
              : (val) {
                  setState(() {
                    selectedSiteId = val;
                  });
                },
          validator: (val) => val == null ? 'Site is required' : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
