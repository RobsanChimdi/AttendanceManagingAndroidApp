import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../providers/auth_provider.dart';
import '../../services/dashboard_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  final RefreshController _refreshController = RefreshController(initialRefresh: true);
  
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _statistics;

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
      final data = await _dashboardService.getDashboardStatistics();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome, ${user.name}',
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Administrator',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.grey,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        user.email,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            
                            // Statistics cards
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.3,
                              children: [
                                _buildStatCard(
                                  context,
                                  'Total Students',
                                  '${_statistics!['total_students'] ?? 0}',
                                  Icons.people,
                                  Colors.blue,
                                ),
                                _buildStatCard(
                                  context,
                                  'Total Teachers',
                                  '${_statistics!['total_teachers'] ?? 0}',
                                  Icons.person,
                                  Colors.orange,
                                ),
                                _buildStatCard(
                                  context,
                                  'Today\'s Attendance',
                                  '${_statistics!['present_today'] ?? 0}',
                                  Icons.check_circle,
                                  Colors.green,
                                ),
                                _buildStatCard(
                                  context,
                                  'Average Attendance',
                                  '${_statistics!['average_attendance']?.toStringAsFixed(1) ?? '0'}%',
                                  Icons.trending_up,
                                  Colors.purple,
                                ),
                                _buildStatCard(
                                  context,
                                  'Critical Students',
                                  '${_statistics!['critical_students'] ?? 0}',
                                  Icons.warning,
                                  Colors.red,
                                ),
                                _buildStatCard(
                                  context,
                                  'Classes',
                                  '${_statistics!['total_classes'] ?? 0}',
                                  Icons.class_,
                                  Colors.teal,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Quick actions
                            Text(
                              'Quick Actions',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.5,
                              children: [
                                _buildActionCard(
                                  context,
                                  'Manage Students',
                                  Icons.people,
                                  () {
                                    context.push('/students');
                                  },
                                ),
                                _buildActionCard(
                                  context,
                                  'Manage Classes',
                                  Icons.class_,
                                  () {
                                    // TODO: Navigate to classes management
                                  },
                                ),
                                _buildActionCard(
                                  context,
                                  'Manage Teachers',
                                  Icons.person,
                                  () {
                                    // TODO: Navigate to teachers management
                                  },
                                ),
                                _buildActionCard(
                                  context,
                                  'Critical Attendance',
                                  Icons.warning,
                                  Colors.red,
                                  () {
                                    context.push('/students/critical-attendance');
                                  },
                                ),
                                _buildActionCard(
                                  context,
                                  'Analytics',
                                  Icons.analytics,
                                  () {
                                    context.push('/analytics');
                                  },
                                ),
                                _buildActionCard(
                                  context,
                                  'Reports',
                                  Icons.assessment,
                                  () {
                                    // TODO: Navigate to reports
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadStatistics,
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
          const Icon(Icons.inbox, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Data Available',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, [
    Color? color,
  ]) {
    final cardColor = color ?? Theme.of(context).primaryColor;
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: cardColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
