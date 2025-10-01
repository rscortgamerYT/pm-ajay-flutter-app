import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/agencies/presentation/pages/agencies_list_page.dart';
import '../../features/agencies/presentation/pages/agency_detail_page.dart';
import '../../features/projects/presentation/pages/projects_list_page.dart';
import '../../features/projects/presentation/pages/project_detail_page.dart';
import '../../features/funds/presentation/pages/funds_list_page.dart';
import '../../features/funds/presentation/pages/fund_detail_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/ai_insights/presentation/pages/ai_insights_page.dart';
import '../../features/map/presentation/pages/projects_map_page.dart';

// Router Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash Route
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // Dashboard Route
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      
      // Agency Routes
      GoRoute(
        path: '/agencies',
        name: 'agencies',
        builder: (context, state) => const AgenciesListPage(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'agency-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AgencyDetailPage(agencyId: id);
            },
          ),
        ],
      ),
      
      // Project Routes
      GoRoute(
        path: '/projects',
        name: 'projects',
        builder: (context, state) => const ProjectsListPage(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'project-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ProjectDetailPage(projectId: id);
            },
          ),
        ],
      ),
      
      // Fund Routes
      GoRoute(
        path: '/funds',
        name: 'funds',
        builder: (context, state) => const FundsListPage(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'fund-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return FundDetailPage(fundId: id);
            },
          ),
        ],
      ),
      
      // Notification Routes
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      
      // Reports Routes
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsPage(),
      ),
      
      // AI Insights Route
      GoRoute(
        path: '/ai-insights',
        name: 'ai-insights',
        builder: (context, state) => const AIInsightsPage(),
      ),
      
      // Map Route
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const ProjectsMapPage(),
      ),
      
      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    
    // Error Handler
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});