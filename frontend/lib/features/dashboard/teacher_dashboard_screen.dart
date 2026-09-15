import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../providers/auth_provider.dart';
import '../../services/dashboard_service.dart';
import '../../services/websocket_service.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  final RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not found');
      }

      final data = await _dashboardService.getTeacherDashboardStatistics(
        user.id,
      );
      if (mounted) {
        setState(() {
          _statistics = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onRefresh() async {
    await _loadStatistics();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    // Listen to real-time notification push events via WebSocket
    ref.listen(notificationStreamProvider, (previous, next) {
      next.whenData((payload) {
        if (!context.mounted) return;
        final message =
            payload['message'] ??
            payload['title'] ??
            'New notification received';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(message.toString())),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _statistics == null
          ? _buildEmptyView()
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    if (user != null)
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user.name}',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Teacher',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              user.email,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Statistics cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.3,
                      children: [
                        StatCard(
                          title: 'Total Students',
                          value: '${_statistics!['total_students'] ?? 0}',
                          icon: Icons.people,
                          color: AppColors.primary,
                        ),
                        StatCard(
                          title: 'Present Today',
                          value: '${_statistics!['present_today'] ?? 0}',
                          icon: Icons.check_circle,
                          color: AppColors.success,
                        ),
                        StatCard(
                          title: 'Absent Today',
                          value: '${_statistics!['absent_today'] ?? 0}',
                          icon: Icons.cancel,
                          color: AppColors.error,
                        ),
                        StatCard(
                          title: 'Average Attendance',
                          value:
                              '${_statistics!['average_attendance']?.toStringAsFixed(1) ?? '0'}%',
                          icon: Icons.trending_up,
                          color: AppColors.secondary,
                        ),
                        StatCard(
                          title: 'Critical Students',
                          value: '${_statistics!['critical_students'] ?? 0}',
                          icon: Icons.warning,
                          color: AppColors.warning,
                        ),
                        StatCard(
                          title: 'Classes',
                          value: '${_statistics!['total_classes'] ?? 0}',
                          icon: Icons.class_,
                          color: AppColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick actions
                    Text(
                      'Quick Actions',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.5,
                      children: [
                        ActionCard(
                          title: 'Start Attendance',
                          icon: Icons.play_circle,
                          onTap: () {
                            context.push('/attendance/start');
                          },
                        ),
                        ActionCard(
                          title: 'Scan QR',
                          icon: Icons.qr_code_scanner,
                          onTap: () {
                            context.push('/attendance/start');
                          },
                        ),
                        ActionCard(
                          title: 'Add Student',
                          icon: Icons.person_add,
                          onTap: () {
                            context.push('/students/add');
                          },
                        ),
                        ActionCard(
                          title: 'Students',
                          icon: Icons.people,
                          onTap: () {
                            context.push('/students');
                          },
                        ),
                        ActionCard(
                          title: 'Critical Attendance',
                          icon: Icons.warning,
                          color: AppColors.error,
                          onTap: () {
                            context.push('/students/critical-attendance');
                          },
                        ),
                        ActionCard(
                          title: 'Analytics',
                          icon: Icons.analytics,
                          onTap: () {
                            context.push('/analytics');
                          },
                        ),
                        ActionCard(
                          title: 'Reports',
                          icon: Icons.assessment,
                          onTap: () {
                            context.push('/reports');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _loadStatistics,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 64, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'No Data Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Pull to refresh', style: TextStyle(color: AppColors.textHint)),
        ],
      ),
    );
  }
}
