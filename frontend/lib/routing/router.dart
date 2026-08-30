import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import features (screens)
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/admin_dashboard_screen.dart';
import '../features/dashboard/teacher_dashboard_screen.dart';

// Import providers
import '../providers/auth_provider.dart';
import '../models/auth_models.dart';

// GoRouter provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      
      final userRole = authState.maybeWhen(
        authenticated: (user) => user.role,
        orElse: () => null,
      );
      
      final isLoginRoute = state.matchedLocation == '/login';
      final isAdminRoute = state.matchedLocation == '/admin-dashboard';
      final isTeacherRoute = state.matchedLocation == '/teacher-dashboard';
      
      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }
      
      // If authenticated and trying to access login page
      if (isAuthenticated && isLoginRoute) {
        // Redirect based on role
        if (userRole == UserRole.admin) {
          return '/admin-dashboard';
        } else {
          return '/teacher-dashboard';
        }
      }
      
      // Role-based access control
      if (isAdminRoute && userRole != UserRole.admin) {
        return '/teacher-dashboard';
      }
      
      if (isTeacherRoute && userRole != UserRole.teacher) {
        return '/admin-dashboard';
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
        path: '/admin-dashboard',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/teacher-dashboard',
        name: 'teacher-dashboard',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
});
