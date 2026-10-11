import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/student_service.dart';

class CriticalAttendanceScreen extends ConsumerStatefulWidget {
  const CriticalAttendanceScreen({super.key});

  @override
  ConsumerState<CriticalAttendanceScreen> createState() => _CriticalAttendanceScreenState();
}

class _CriticalAttendanceScreenState extends ConsumerState<CriticalAttendanceScreen> {
  final StudentService _studentService = StudentService();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _criticalStudents = [];
  int _total = 0;
  final double _threshold = 50.0;

  @override
  void initState() {
    super.initState();
    _loadCriticalStudents();
  }

  Future<void> _loadCriticalStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _studentService.getCriticalAttendanceStudents(
        threshold: _threshold,
      );
      if (mounted) {
        setState(() {
          _criticalStudents = data['students'] ?? [];
          _total = data['total'] ?? 0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Critical Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCriticalStudents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _criticalStudents.isEmpty
                  ? _buildEmptyView()
                  : _buildListView(),
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
              onPressed: _loadCriticalStudents,
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
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'No Critical Attendance',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'All students have attendance above $_threshold%',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.orange.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '$_total Critical Students',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
              Text(
                'Threshold: $_threshold%',
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            itemCount: _criticalStudents.length,
            itemBuilder: (context, index) {
              final student = _criticalStudents[index];
              return _buildStudentCard(student);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final attendancePercentage = student['attendance_percentage'] as double;
    final isCritical = attendancePercentage < _threshold;
    
    Color statusColor = isCritical ? Colors.red : Colors.green;
    String statusText = isCritical ? 'Critical' : 'OK';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    '${student['student_name'][0]}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['student_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${student['student_id_str']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Class info
            Row(
              children: [
                Icon(Icons.school, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Grade ${student['grade'] ?? 'N/A'} - Section ${student['section'] ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Attendance percentage
            Row(
              children: [
                Icon(Icons.percent, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Attendance: ${attendancePercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(Required: ${student['required_percentage']}%)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress bar
            LinearProgressIndicator(
              value: attendancePercentage / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
            const SizedBox(height: 12),
            
            // Guardian info
            if (student['guardian_name'] != null || student['guardian_phone'] != null)
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contact_phone, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Guardian',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (student['guardian_name'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          student['guardian_name'],
                          style: TextStyle(color: Colors.blue.shade900),
                        ),
                      ),
                    if (student['guardian_phone'] != null)
                      Text(
                        student['guardian_phone'],
                        style: TextStyle(color: Colors.blue.shade900),
                      ),
                  ],
                ),
              ),
            
            // Notification status
            if (student['latest_notification_status'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.notifications, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Notification: ${student['latest_notification_status']}',
                      style: TextStyle(
                        color: _getNotificationColor(student['latest_notification_status']),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'SENT':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
