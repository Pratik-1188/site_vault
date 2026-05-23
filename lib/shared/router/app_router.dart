import 'package:go_router/go_router.dart';
import 'package:site_vault/feature/site/screen/site_screen.dart';
import 'package:site_vault/feature/site/screen/site_detail_screen.dart';
import 'package:site_vault/feature/site/model/site.dart';

/// A premium, centralized router using go_router for efficient, M3-aligned navigation.
///
/// Defines the routes for:
/// - `/` - Sites Screen Directory
/// - `/site/:id` - Site Detail Screen (accepts a Site model via [extra] for instant visual loading)
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'sites',
      builder: (context, state) => const SitesScreen(),
    ),
    GoRoute(
      path: '/site/:id',
      name: 'site-detail',
      builder: (context, state) {
        final siteId = state.pathParameters['id']!;
        final site = state.extra as Site?;
        return SiteDetailScreen(siteId: siteId, site: site);
      },
    ),
  ],
);
