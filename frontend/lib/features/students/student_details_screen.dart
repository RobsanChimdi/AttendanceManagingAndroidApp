import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/student_models.dart';
import '../../services/student_service.dart';

class StudentDetailsScreen extends ConsumerStatefulWidget {
  final int studentId;

  const StudentDetailsScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends ConsumerState<StudentDetailsScreen> {
  final StudentService _studentService = StudentService();
  
  bool _isLoading = false;
  String? _errorMessage;
  Student? _student;
  Map<String, dynamic>? _faceEnrollmentStatus;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final student = await _studentService.getStudent(widget.studentId);
      final enrollmentStatus = await _studentService.getFaceEnrollmentStatus(widget.studentId);
      setState(() {
        _student = student;
        _faceEnrollmentStatus = enrollmentStatus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadStudent,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/students/${widget.studentId}/edit');
            },
          ),
        ],
      ),
      body: _student == null
          ? const Center(child: Text('Student not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            child: Text(
                              '${_student!.firstName[0]}${_student!.lastName[0]}',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_student!.firstName} ${_student!.middleName ?? ''} ${_student!.lastName}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${_student!.studentId}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildStatusChip(_student!.status),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Personal Information Section
                  _buildSectionCard(
                    'Personal Information',
                    Icons.person,
                    [
                      _buildInfoRow('First Name', _student!.firstName),
                      if (_student!.middleName != null)
                        _buildInfoRow('Middle Name', _student!.middleName!),
                      _buildInfoRow('Last Name', _student!.lastName),
                      if (_student!.gender != null)
                        _buildInfoRow('Gender', _student!.gender!),
                      if (_student!.dateOfBirth != null)
                        _buildInfoRow('Date of Birth', _student!.dateOfBirth!),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Academic Information Section
                  _buildSectionCard(
                    'Academic Information',
                    Icons.school,
                    [
                      if (_student!.grade != null)
                        _buildInfoRow('Grade', _student!.grade!),
                      if (_student!.section != null)
                        _buildInfoRow('Section', _student!.section!),
                      if (_student!.classId != null)
                        _buildInfoRow('Class ID', _student!.classId.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Guardian Information Section
                  _buildSectionCard(
                    'Guardian Information',
                    Icons.family_restroom,
                    [
                      if (_student!.guardianName != null)
                        _buildInfoRow('Guardian Name', _student!.guardianName!),
                      if (_student!.guardianPhone != null)
                        _buildInfoRow('Guardian Phone', _student!.guardianPhone!),
                      if (_student!.guardianEmail != null)
                        _buildInfoRow('Guardian Email', _student!.guardianEmail!),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Face Enrollment Section
                  _buildSectionCard(
                    'Face Enrollment',
                    Icons.face,
                    [
                      _buildInfoRow('Status', _faceEnrollmentStatus?['enrolled'] == true ? 'Enrolled' : 'Not Enrolled'),
                      if (_faceEnrollmentStatus?['enrolled'] == true)
                        _buildInfoRow('Last Updated', _faceEnrollmentStatus?['enrollment_date']?.toString().split('T')[0] ?? 'Unknown'),
                      if (_faceEnrollmentStatus?['enrolled'] == true)
                        _buildInfoRow('Model', '${_faceEnrollmentStatus?['model_name'] ?? 'Unknown'} (${_faceEnrollmentStatus?['model_version'] ?? 'Unknown'})'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Attendance Section
                  _buildSectionCard(
                    'Attendance',
                    Icons.calendar_today,
                    [
                      _buildInfoRow('Attendance Rate', '0%'),
                      _buildInfoRow('Present Count', '0'),
                      _buildInfoRow('Absent Count', '0'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  const Text(
                    'Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildActionButton(
                        'Enroll Face',
                        Icons.face,
                        Colors.blue,
                        () {
                          if (_student != null) {
                            context.push(
                              '/students/${widget.studentId}/face-enroll',
                              extra: {
                                'studentName': '${_student!.firstName} ${_student!.lastName}',
                                'studentIdStr': _student!.studentId,
                              },
                            );
                          }
                        },
                      ),
                      _buildActionButton(
                        'Re-enroll Face',
                        Icons.refresh,
                        Colors.orange,
                        () {
                          if (_student != null) {
                            context.push(
                              '/students/${widget.studentId}/face-enroll',
                              extra: {
                                'studentName': '${_student!.firstName} ${_student!.lastName}',
                                'studentIdStr': _student!.studentId,
                              },
                            );
                          }
                        },
                      ),
                      _buildActionButton(
                        'Generate QR',
                        Icons.qr_code,
                        Colors.green,
                        () {
                          if (_student != null) {
                            context.push(
                              '/students/${widget.studentId}/qr',
                              extra: {
                                'studentName': '${_student!.firstName} ${_student!.lastName}',
                              },
                            );
                          }
                        },
                      ),
                      _buildActionButton(
                        'View Attendance',
                        Icons.calendar_view_month,
                        Colors.purple,
                        () => _showComingSoonDialog('Attendance History'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showDeleteDialog(),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Student'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(StudentStatus status) {
    Color color;
    String label;

    switch (status) {
      case StudentStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case StudentStatus.inactive:
        color = Colors.red;
        label = 'Inactive';
        break;
      case StudentStatus.graduated:
        color = Colors.blue;
        label = 'Graduated';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontSize: 12),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature will be implemented in a later stage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStudent();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent() async {
    try {
      await _studentService.deleteStudent(widget.studentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete student: $e')),
        );
      }
    }
  }
}
