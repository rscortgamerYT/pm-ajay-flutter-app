import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/scroll_dashboard_page.dart';
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
import '../../features/collaboration_hub/presentation/pages/collaboration_hub_page.dart';
import '../../features/adarsh_gram/presentation/pages/villages_list_page.dart';
import '../../features/adarsh_gram/presentation/pages/village_detail_page.dart';

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
      
      // Dashboard Routes
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/scroll-dashboard',
        name: 'scroll-dashboard',
        builder: (context, state) => const ScrollDashboardPage(),
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
      
      // Collaboration Hub Route
      GoRoute(
        path: '/collaboration',
        name: 'collaboration',
        builder: (context, state) => const CollaborationHubPage(),
      ),
      
      // Adarsh Gram Routes
      GoRoute(
        path: '/adarsh-gram',
        name: 'adarsh-gram',
        builder: (context, state) => const VillagesListPage(),
      ),
      GoRoute(
        path: '/adarsh-gram/villages',
        name: 'villages',
        builder: (context, state) => const VillagesListPage(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'village-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return VillageDetailPage(villageId: id);
            },
          ),
        ],
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