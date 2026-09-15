import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/analytics_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_empty_state.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final RefreshController _refreshController = RefreshController(initialRefresh: true);
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Analytics data
  Map<String, dynamic>? _attendanceTrend;
  Map<String, dynamic>? _classComparison;
  Map<String, dynamic>? _gradeComparison;
  Map<String, dynamic>? _presentAbsentDistribution;
  Map<String, dynamic>? _criticalAttendanceBreakdown;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _analyticsService.getAttendanceTrend(days: 30),
        _analyticsService.getClassComparison(),
        _analyticsService.getGradeComparison(),
        _analyticsService.getPresentAbsentDistribution(),
        _analyticsService.getCriticalAttendanceBreakdown(),
      ]);

      if (mounted) {
        setState(() {
          _attendanceTrend = results[0];
          _classComparison = results[1];
          _gradeComparison = results[2];
          _presentAbsentDistribution = results[3];
          _criticalAttendanceBreakdown = results[4];
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
    await _loadAnalytics();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationSm,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            color: AppColors.textSecondary,
          ),
        ],
      ),
      body: _isLoading
          ? const AppLoading(message: 'Loading analytics...')
          : _errorMessage != null
              ? _buildErrorView()
              : _attendanceTrend == null
                  ? _buildEmptyView()
                  : SmartRefresher(
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Attendance Trend Chart
                            _buildSectionCard(
                              'Attendance Trend (30 Days)',
                              Icons.trending_up,
                              _buildAttendanceTrendChart(),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            
                            // Present vs Absent Distribution
                            _buildSectionCard(
                              'Present vs Absent Distribution',
                              Icons.pie_chart,
                              _buildPresentAbsentChart(),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            
                            // Class Comparison
                            _buildSectionCard(
                              'Attendance by Class',
                              Icons.bar_chart,
                              _buildClassComparisonChart(),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            
                            // Grade Comparison
                            _buildSectionCard(
                              'Attendance by Grade',
                              Icons.school,
                              _buildGradeComparisonChart(),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            
                            // Critical Attendance Breakdown
                            _buildSectionCard(
                              'Critical Attendance Breakdown',
                              Icons.warning,
                              _buildCriticalAttendanceBreakdown(),
                            ),
                            const SizedBox(height: AppSpacing.xl),
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
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: 'Retry',
              onPressed: _loadAnalytics,
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return NoDataEmptyState(
      message: 'Pull to refresh',
      onRefresh: _loadAnalytics,
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget child) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 250,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTrendChart() {
    if (_attendanceTrend == null || _attendanceTrend!['trend'] == null) {
      return const Center(child: Text('No data available', style: AppTextStyles.bodyMedium));
    }

    final trend = _attendanceTrend!['trend'] as List;
    final dataPoints = trend.map((e) => e['attendance_rate'] as double).toList();
    final dates = trend.map((e) => _formatDate(e['date'] as String)).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < dates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dates[value.toInt()],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              interval: dates.length > 7 ? (dates.length / 7).ceil().toDouble() : 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 20 == 0) {
                  return Text(
                    '${value.toInt()}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              dataPoints.length,
              (index) => FlSpot(index.toDouble(), dataPoints[index]),
            ),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: 100,
      ),
    );
  }

  Widget _buildPresentAbsentChart() {
    if (_presentAbsentDistribution == null) {
      return const Center(child: Text('No data available', style: AppTextStyles.bodyMedium));
    }

    final present = _presentAbsentDistribution!['present'] ?? 0;
    final absent = _presentAbsentDistribution!['absent'] ?? 0;
    final notMarked = _presentAbsentDistribution!['not_marked'] ?? 0;

    if (present + absent + notMarked == 0) {
      return const Center(child: Text('No attendance data available', style: AppTextStyles.bodyMedium));
    }

    return PieChart(
      PieChartData(
        sections: [
          if (present > 0)
            PieChartSectionData(
              value: present.toDouble(),
              title: '${((present / (present + absent + notMarked)) * 100).toStringAsFixed(1)}%',
              color: AppColors.success,
              radius: 80,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          if (absent > 0)
            PieChartSectionData(
              value: absent.toDouble(),
              title: '${((absent / (present + absent + notMarked)) * 100).toStringAsFixed(1)}%',
              color: AppColors.error,
              radius: 80,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          if (notMarked > 0)
            PieChartSectionData(
              value: notMarked.toDouble(),
              title: '${((notMarked / (present + absent + notMarked)) * 100).toStringAsFixed(1)}%',
              color: AppColors.textHint,
              radius: 80,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildClassComparisonChart() {
    if (_classComparison == null || _classComparison!['classes'] == null) {
      return const Center(child: Text('No data available', style: AppTextStyles.bodyMedium));
    }

    final classes = _classComparison!['classes'] as List;
    if (classes.isEmpty) {
      return const Center(child: Text('No class data available', style: AppTextStyles.bodyMedium));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barGroups: List.generate(
          classes.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: classes[index]['attendance_rate'] as double,
                color: _getClassColor(index),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < classes.length) {
                  final className = classes[value.toInt()]['class_name'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      className.length > 10 ? '${className.substring(0, 10)}...' : className,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 20 == 0) {
                  return Text(
                    '${value.toInt()}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildGradeComparisonChart() {
    if (_gradeComparison == null || _gradeComparison!['grades'] == null) {
      return const Center(child: Text('No data available', style: AppTextStyles.bodyMedium));
    }

    final grades = _gradeComparison!['grades'] as List;
    if (grades.isEmpty) {
      return const Center(child: Text('No grade data available', style: AppTextStyles.bodyMedium));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barGroups: List.generate(
          grades.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: grades[index]['average_attendance'] as double,
                color: _getGradeColor(index),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < grades.length) {
                  final grade = grades[value.toInt()]['grade'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      grade,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 20 == 0) {
                  return Text(
                    '${value.toInt()}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildCriticalAttendanceBreakdown() {
    if (_criticalAttendanceBreakdown == null) {
      return const Center(child: Text('No data available', style: AppTextStyles.bodyMedium));
    }

    final totalCritical = _criticalAttendanceBreakdown!['total_critical'] ?? 0;
    final byClass = _criticalAttendanceBreakdown!['by_class'] as List? ?? [];
    final byGrade = _criticalAttendanceBreakdown!['by_grade'] as List? ?? [];

    if (totalCritical == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 48, color: AppColors.success),
            SizedBox(height: 16),
            Text(
              'No Critical Students',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCriticalStat('Total Critical', totalCritical.toString(), Icons.warning, AppColors.error),
            _buildCriticalStat('Classes Affected', byClass.length.toString(), Icons.class_, AppColors.warning),
            _buildCriticalStat('Grades Affected', byGrade.length.toString(), Icons.school, AppColors.secondary),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (byClass.isNotEmpty) ...[
          Text(
            'By Class:',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: byClass.map((cls) => Chip(
              label: Text('${cls['class_name']}: ${cls['count']}', style: AppTextStyles.bodySmall),
              backgroundColor: AppColors.warning.withValues(alpha: 0.1),
            )).toList(),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (byGrade.isNotEmpty) ...[
          Text(
            'By Grade:',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: byGrade.map((grade) => Chip(
              label: Text('Grade ${grade['grade']}: ${grade['count']}', style: AppTextStyles.bodySmall),
              backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCriticalStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}';
  }

  Color _getClassColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.secondary,
      AppColors.info,
      AppColors.error,
      AppColors.primaryDark,
      AppColors.secondaryDark,
    ];
    return colors[index % colors.length];
  }

  Color _getGradeColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.secondary,
      AppColors.info,
      AppColors.error,
    ];
    return colors[index % colors.length];
  }
}
