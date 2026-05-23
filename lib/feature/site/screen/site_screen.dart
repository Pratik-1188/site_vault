import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/site_provider.dart';
import '../model/site.dart';

class SitesScreen extends ConsumerStatefulWidget {
  const SitesScreen({super.key});

  @override
  ConsumerState<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends ConsumerState<SitesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(visibleCountProvider.notifier).increment(10);
    }
  }

  void _onSearchChanged(String value) {
    ref.read(searchQueryProvider.notifier).update(value);
    ref.read(visibleCountProvider.notifier).update(10);
  }

  void _onFirmChanged(String? firmId) {
    ref.read(selectedFirmProvider.notifier).update(firmId);
    ref.read(visibleCountProvider.notifier).update(10);
  }

  void _onStatusChanged(String? status) {
    ref.read(selectedStatusProvider.notifier).update(status);
    ref.read(visibleCountProvider.notifier).update(10);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sitesAsync = ref.watch(paginatedSitesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sites')),
      body: Column(
        children: [
          _buildSearch(),
          _buildFilters(),
          Expanded(child: _buildList(sitesAsync)),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: const InputDecoration(
          hintText: 'Search sites...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final selectedFirm = ref.watch(selectedFirmProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);

    final firms = [
      {"id": "0f140f6f-d994-4695-a838-bee13b3802f1", "name": "KK Electricals"},
      {"id": "4e01a36a-87c0-4cca-9428-a2747a130c96", "name": "KK Solar"},
      {"id": "169eceeb-dfc3-4535-b6ad-2e9f8eb884d3", "name": "KK Associates"},
    ];

    return Column(
      children: [
        // Firm filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip('All', selectedFirm == null, () => _onFirmChanged(null)),
              ...firms.map((f) {
                return _chip(
                  f['name']!,
                  selectedFirm == f['id'],
                  () => _onFirmChanged(f['id']),
                );
              }),
            ],
          ),
        ),

        // Status filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip(
                'All',
                selectedStatus == null,
                () => _onStatusChanged(null),
              ),
              _chip(
                'Active',
                selectedStatus == 'active',
                () => _onStatusChanged('active'),
              ),
              _chip(
                'Completed',
                selectedStatus == 'completed',
                () => _onStatusChanged('completed'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildList(AsyncValue<List<Site>> sitesAsync) {
    return sitesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sites) {
        if (sites.isEmpty) {
          return const Center(child: Text('No sites found'));
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: sites.length,
          itemBuilder: (_, index) {
            final site = sites[index];

            return ListTile(
              title: Text(site.name),
              subtitle: Text(site.status),
            );
          },
        );
      },
    );
  }
}
