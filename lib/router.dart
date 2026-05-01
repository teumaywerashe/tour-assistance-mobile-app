import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/about/about_screen.dart';
import 'screens/feedback/feedback_screen.dart';
import 'screens/building_detail/building_detail_screen.dart';
import 'screens/admin/login_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/feedback_review_screen.dart';
import 'widgets/nav_shell.dart';
import 'widgets/admin_nav_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      if (isAdminRoute && !isAuth) return '/login';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => NavShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
          GoRoute(
            path: '/map',
            builder: (c, s) => MapScreen(
              initialQuery: s.uri.queryParameters['q'],
              initialBuildingId: s.uri.queryParameters['building'],
            ),
          ),
          GoRoute(path: '/categories', builder: (c, s) => const CategoriesScreen()),
          GoRoute(path: '/about', builder: (c, s) => const AboutScreen()),
          GoRoute(path: '/feedback', builder: (c, s) => const FeedbackScreen()),
        ],
      ),
      GoRoute(
        path: '/building/:id',
        pageBuilder: (c, s) => CustomTransitionPage(
          child: BuildingDetailScreen(id: s.pathParameters['id']!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(path: '/login', builder: (c, s) => const AdminLoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AdminNavShell(child: child),
        routes: [
          GoRoute(path: '/admin/dashboard', builder: (c, s) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/feedback-review', builder: (c, s) => const AdminFeedbackReviewScreen()),
        ],
      ),
    ],
  );
});
