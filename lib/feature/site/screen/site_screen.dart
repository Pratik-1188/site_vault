import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';

class SitesScreen extends ConsumerWidget {
  const SitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitesAsync = ref.watch(sitesProvider);
    final sites = ref.watch(filteredSitesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sites')),
      body: Column(
        children: [
          const FirmFilterChips(),
          const StatusFilterChips(),

          Expanded(
            child: sitesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (_) {
                if (sites.isEmpty) {
                  return const Center(child: Text('No sites found'));
                }

                return ListView.builder(
                  itemCount: sites.length,
                  itemBuilder: (_, i) {
                    final site = sites[i];
                    return SiteCard(site: site);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SiteCard extends StatelessWidget {
  final Site site;

  const SiteCard({super.key, required this.site});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(site.name),
        subtitle: Text(site.status),
        trailing: Text(
          site.startedOn != null
              ? site.startedOn!.toLocal().toString().split(' ')[0]
              : '-',
        ),
      ),
    );
  }
}

class FirmFilterChips extends ConsumerWidget {
  const FirmFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFirmProvider);

    final firms = [
      {'id': null, 'name': 'All'},
      {'id': '0f140f6f-d994-4695-a838-bee13b3802f1', 'name': 'KK Electricals'},
      {'id': '4e01a36a-87c0-4cca-9428-a2747a130c96', 'name': 'KK Solar'},
      {'id': '169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'name': 'KK Associates'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: firms.map((f) {
          final isSelected = selected == f['id'];

          return Padding(
            padding: const EdgeInsets.all(8),
            child: ChoiceChip(
              label: Text(f['name']!),
              selected: isSelected,
              onSelected: (_) {
                ref.read(selectedFirmProvider.notifier).state = f['id'];
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class StatusFilterChips extends ConsumerWidget {
  const StatusFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedStatusProvider);

    final statuses = [null, 'active', 'completed', 'archived'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: statuses.map((status) {
        final label = status ?? 'All';
        final isSelected = selected == status;

        return Padding(
          padding: const EdgeInsets.all(4),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) {
              ref.read(selectedStatusProvider.notifier).state = status;
            },
          ),
        );
      }).toList(),
    );
  }
}
