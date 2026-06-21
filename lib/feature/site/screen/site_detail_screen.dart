import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/site/model/site_status.dart';
import 'package:site_vault/feature/site/screen/site_detail_controller.dart';
import 'package:site_vault/feature/site/screen/site_detail_dialogs.dart';
import 'package:site_vault/feature/site/widgets/analytics_tab.dart';
import 'package:site_vault/feature/site/widgets/documents_tab.dart';
import 'package:site_vault/feature/site/widgets/expense_tab.dart';
import 'package:site_vault/feature/site/widgets/settings_tab.dart';
import 'package:site_vault/shared/widget/sign_out_menu_button.dart';
import 'package:site_vault/shared/widget/app_refresh_indicator.dart';

class SiteDetailScreen extends ConsumerStatefulWidget {
  final String siteId;
  final Site? site;

  const SiteDetailScreen({super.key, required this.siteId, this.site});

  @override
  ConsumerState<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends ConsumerState<SiteDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final SiteDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(siteDetailControllerProvider(widget.siteId));
    _controller.addListener(_handleControllerChange);
    final currentTabIndex = _controller.state.currentTabIndex;
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: currentTabIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleTabChange() {
    if (_tabController.index != _controller.state.currentTabIndex) {
      _controller.setTabIndex(_tabController.index);
    }
  }

  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.bolt_rounded;
    final lower = categoryName.toLowerCase();
    if (lower.contains('labor') ||
        lower.contains('wage') ||
        lower.contains('salary')) {
      return Icons.engineering_rounded;
    } else if (lower.contains('cable') ||
        lower.contains('wire') ||
        lower.contains('transformer')) {
      return Icons.power_rounded;
    } else if (lower.contains('hardware') ||
        lower.contains('switch') ||
        lower.contains('fuse')) {
      return Icons.hardware_rounded;
    } else if (lower.contains('civil') ||
        lower.contains('concrete') ||
        lower.contains('foundation')) {
      return Icons.foundation_rounded;
    } else if (lower.contains('travel') ||
        lower.contains('fuel') ||
        lower.contains('transport')) {
      return Icons.local_shipping_rounded;
    }
    return Icons.bolt_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final state = controller.state;
    final detail = ref.watch(
      siteDetailContextProvider(
        SiteDetailContextParams(siteId: widget.siteId, initialSite: widget.site),
      ),
    );

    if (detail.site == null) {
      return detail.siteAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => context.pop(),
              tooltip: 'Back to Dashboard',
            ),
            title: const Text('Loading Details...'),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => context.pop(),
              tooltip: 'Back to Dashboard',
            ),
            title: const Text('Error'),
          ),
          body: Center(child: Text('Error loading site details: $err')),
        ),
        data: (fetchedSite) => _buildMainContent(
          context,
          controller: controller,
          state: state,
          site: fetchedSite,
          firmName: detail.firmName,
          isEditable: detail.isEditable,
        ),
      );
    }

    return _buildMainContent(
      context,
      controller: controller,
      state: state,
      site: detail.site!,
      firmName: detail.firmName,
      isEditable: detail.isEditable,
    );
  }

  Widget _buildMainContent(
    BuildContext context, {
    required SiteDetailController controller,
    required SiteDetailState state,
    required Site site,
    required String? firmName,
    required bool isEditable,
  }) {
    final baseColor = Theme.of(context).colorScheme.primary;

    return AppRefreshIndicator(
      onRefresh: controller.refresh,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar.medium(
                centerTitle: false,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
                scrolledUnderElevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => context.pop(),
                  tooltip: 'Back to Dashboard',
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      site.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (firmName != null && firmName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        firmName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  const SignOutMenuButton(),
                ],
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Expenses'),
                      Tab(text: 'Documents'),
                      Tab(text: 'Analytics'),
                      Tab(text: 'Settings'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              ExpenseTab(
                site: site,
                onOpenExpenseFormSheet: (context, siteId, firmId, expense) {
                  SiteDetailDialogs.showExpenseSheet(
                    context,
                    siteId: siteId,
                    firmId: firmId,
                    expenseToEdit: expense,
                  );
                },
                onShowExpenseDetail: (context, expense) {
                  SiteDetailDialogs.showExpenseDetail(
                    context,
                    ref: ref,
                    siteId: site.id,
                    site: site,
                    expense: expense,
                    isEditable: isEditable,
                    getCategoryIcon: _getCategoryIcon,
                  );
                },
                onDownloadOrOpenDocument: (context, path, title) {
                  SiteDetailDialogs.openDocument(
                    context,
                    ref: ref,
                    path: path,
                    fileName: title,
                  );
                },
                getCategoryIcon: _getCategoryIcon,
                onConfirmDeleteExpense: (context, expense) {
                  controller.deleteExpense(
                    context,
                    expense: expense,
                  );
                },
              ),
              DocumentsTab(
                site: site,
                onOpenDocument: (context, path, title) {
                  SiteDetailDialogs.openDocument(
                    context,
                    ref: ref,
                    path: path,
                    fileName: title,
                  );
                },
                onEditDocument: (context, doc) {
                  SiteDetailDialogs.showEditDocumentDialog(
                    context,
                    ref: ref,
                    siteId: site.id,
                    document: doc,
                  );
                },
                onDeleteDocument: (context, doc) {
                  controller.deleteDocument(
                    context,
                    document: doc,
                  );
                },
              ),
              AnalyticsTab(site: site, baseColor: baseColor),
              SettingsTab(
                site: site,
                baseColor: baseColor,
                isSaving: state.isSaving,
                onSaveSiteSettings:
                    (
                      siteId,
                      name,
                      description,
                      startedOn, {
                      SiteStatus? status,
                    }) =>
                        controller.saveSiteSettings(
                          context,
                          name: name,
                          description: description,
                          startedOn: startedOn,
                          status: status,
                          currentSite: site,
                        ),
              ),
            ],
          ),
        ),
        floatingActionButton: !isEditable || state.currentTabIndex >= 2
            ? null
            : FloatingActionButton.extended(
                onPressed: () {
                  if (state.currentTabIndex == 0) {
                    SiteDetailDialogs.showExpenseSheet(
                      context,
                      siteId: site.id,
                      firmId: site.firmId,
                    );
                  } else if (state.currentTabIndex == 1) {
                    SiteDetailDialogs.showDocumentSheet(
                      context,
                      siteId: site.id,
                      firmId: site.firmId,
                    );
                  }
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  state.currentTabIndex == 0 ? 'LOG EXPENSE' : 'ADD DOCUMENT',
                ),
              ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
