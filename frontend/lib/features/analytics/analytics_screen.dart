import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/analytics_service.dart';

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
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _attendanceTrend == null
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
                            // Attendance Trend Chart
                            _buildSectionCard(
                              'Attendance Trend (30 Days)',
                              Icons.trending_up,
                              _buildAttendanceTrendChart(),
                            ),
                            const SizedBox(height: 24),
                            
                            // Present vs Absent Distribution
                            _buildSectionCard(
                              'Present vs Absent Distribution',
                              Icons.pie_chart,
                              _buildPresentAbsentChart(),
                            ),
                            const SizedBox(height: 24),
                            
                            // Class Comparison
                            _buildSectionCard(
                              'Attendance by Class',
                              Icons.bar_chart,
                              _buildClassComparisonChart(),
                            ),
                            const SizedBox(height: 24),
                            
                            // Grade Comparison
                            _buildSectionCard(
                              'Attendance by Grade',
                              Icons.school,
                              _buildGradeComparisonChart(),
                            ),
                            const SizedBox(height: 24),
                            
                            // Critical Attendance Breakdown
                            _buildSectionCard(
                              'Critical Attendance Breakdown',
                              Icons.warning,
                              _buildCriticalAttendanceBreakdown(),
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
              onPressed: _loadAnalytics,
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
            'No Analytics Data Available',
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

  Widget _buildSectionCard(String title, IconData icon, Widget child) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTrendChart() {
    if (_attendanceTrend == null || _attendanceTrend!['trend'] == null) {
      return const Center(child: Text('No data available'));
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
                      style: const TextStyle(fontSize: 10),
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
                  return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
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
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
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
      return const Center(child: Text('No data available'));
    }

    final present = _presentAbsentDistribution!['present'] ?? 0;
    final absent = _presentAbsentDistribution!['absent'] ?? 0;
    final notMarked = _presentAbsentDistribution!['not_marked'] ?? 0;

    if (present + absent + notMarked == 0) {
      return const Center(child: Text('No attendance data available'));
    }

    return PieChart(
      PieChartData(
        sections: [
          if (present > 0)
            PieChartSectionData(
              value: present.toDouble(),
              title: '${((present / (present + absent + notMarked)) * 100).toStringAsFixed(1)}%',
              color: Colors.green,
              radius: 80,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          if (absent > 0)
            PieChartSectionData(
              value: absent.toDouble(),
              title: '${((absent / (present + absent + notMarked)) * 100).toStringAsFixed(1)}%',
              color: Colors.red,
              radius: 80,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          if (notMarked > 0)
            PieChartSectionData(
              value: notMarked.toDouble(),
              title: '${((notMarked / (present + absent + notMarked)) * 100).toStringAsFixed(1)}%',
              color: Colors.grey,
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
      return const Center(child: Text('No data available'));
    }

    final classes = _classComparison!['classes'] as List;
    if (classes.isEmpty) {
      return const Center(child: Text('No class data available'));
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
                      style: const TextStyle(fontSize: 10),
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
                  return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
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
        gridData: FlGridData(show: true, drawVerticalLine: false),
      ),
    );
  }

  Widget _buildGradeComparisonChart() {
    if (_gradeComparison == null || _gradeComparison!['grades'] == null) {
      return const Center(child: Text('No data available'));
    }

    final grades = _gradeComparison!['grades'] as List;
    if (grades.isEmpty) {
      return const Center(child: Text('No grade data available'));
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
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                  return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
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
        gridData: FlGridData(show: true, drawVerticalLine: false),
      ),
    );
  }

  Widget _buildCriticalAttendanceBreakdown() {
    if (_criticalAttendanceBreakdown == null) {
      return const Center(child: Text('No data available'));
    }

    final totalCritical = _criticalAttendanceBreakdown!['total_critical'] ?? 0;
    final byClass = _criticalAttendanceBreakdown!['by_class'] as List? ?? [];
    final byGrade = _criticalAttendanceBreakdown!['by_grade'] as List? ?? [];

    if (totalCritical == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 48, color: Colors.green),
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
            _buildCriticalStat('Total Critical', totalCritical.toString(), Icons.warning, Colors.red),
            _buildCriticalStat('Classes Affected', byClass.length.toString(), Icons.class_, Colors.orange),
            _buildCriticalStat('Grades Affected', byGrade.length.toString(), Icons.school, Colors.purple),
          ],
        ),
        const SizedBox(height: 16),
        if (byClass.isNotEmpty) ...[
          const Text('By Class:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: byClass.map((cls) => Chip(
              label: Text('${cls['class_name']}: ${cls['count']}'),
              backgroundColor: Colors.orange.shade100,
            )).toList(),
          ),
        ],
        const SizedBox(height: 16),
        if (byGrade.isNotEmpty) ...[
          const Text('By Grade:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: byGrade.map((grade) => Chip(
              label: Text('Grade ${grade['grade']}: ${grade['count']}'),
              backgroundColor: Colors.purple.shade100,
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
        const SizedBox(height: 8),
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
          style: TextStyle(color: Colors.grey[600]),
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
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  Color _getGradeColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];
    return colors[index % colors.length];
  }
}
