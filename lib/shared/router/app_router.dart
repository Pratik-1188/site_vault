import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:site_vault/feature/home/screen/home_screen.dart';
import 'package:site_vault/feature/site/screen/site_screen.dart';
import 'package:site_vault/feature/site/screen/site_detail_screen.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';
import 'package:site_vault/feature/auth/screen/login_screen.dart';
import 'package:site_vault/feature/admin/screen/admin_screen.dart';
import 'package:site_vault/feature/analytics/screen/analytics_dashboard_screen.dart';

part 'app_router.g.dart';

/// A custom GoRouter refresh listenable that wraps a broadcast auth state stream.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// A reactive, Riverpod-generated GoRouter provider for the application.
///
/// Automatically guards routes:
/// - Redirects unauthenticated users to `/login`
/// - Redirects authenticated users away from `/login` to `/`
@riverpod
GoRouter appRouter(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authRepo.authStateStream),
    redirect: (context, state) {
      final isLoggedIn = authRepo.currentUser != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/sites',
        name: 'sites',
        builder: (context, state) => const SitesScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsDashboardScreen(),
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
}
