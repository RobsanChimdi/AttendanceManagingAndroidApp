import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/student_models.dart';
import '../../services/student_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_status_badge.dart';

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
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Student Details'),
          backgroundColor: AppColors.surface,
          elevation: AppSpacing.elevationSm,
        ),
        body: const AppLoading(message: 'Loading student details...'),
      );
    }

    if (_errorMessage != null && _student == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Student Details'),
          backgroundColor: AppColors.surface,
          elevation: AppSpacing.elevationSm,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: 'Retry',
                onPressed: _loadStudent,
                type: ButtonType.primary,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationSm,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/students/${widget.studentId}/edit');
            },
            color: AppColors.textSecondary,
          ),
        ],
      ),
      body: _student == null
          ? const Center(child: Text('Student not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            '${_student!.firstName[0]}${_student!.lastName[0]}',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.surface,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_student!.firstName} ${_student!.middleName ?? ''} ${_student!.lastName}',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'ID: ${_student!.studentId}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              _buildStatusBadge(_student!.status),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
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
                  const SizedBox(height: AppSpacing.lg),
                  
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
                  const SizedBox(height: AppSpacing.lg),
                  
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
                  const SizedBox(height: AppSpacing.lg),
                  
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
                  const SizedBox(height: AppSpacing.lg),
                  
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
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Action Buttons
                  Text(
                    'Actions',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    children: [
                      _buildActionButton(
                        'Enroll Face',
                        Icons.face,
                        AppColors.primary,
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
                        AppColors.warning,
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
                        AppColors.success,
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
                        AppColors.secondary,
                        () => _showComingSoonDialog('Attendance History'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Delete Button
                  AppButton(
                    text: 'Delete Student',
                    icon: Icons.delete,
                    onPressed: () => _showDeleteDialog(),
                    isFullWidth: true,
                    type: ButtonType.danger,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
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
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      backgroundColor: AppColors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(StudentStatus status) {
    switch (status) {
      case StudentStatus.active:
        return const AppStatusBadge(
          type: StatusType.present,
          label: 'Active',
        );
      case StudentStatus.inactive:
        return const AppStatusBadge(
          type: StatusType.absent,
          label: 'Inactive',
        );
      case StudentStatus.graduated:
        return const AppStatusBadge(
          type: StatusType.info,
          label: 'Graduated',
        );
    }
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Coming Soon',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '$feature will be implemented in a later stage.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          AppButton(
            text: 'OK',
            onPressed: () => Navigator.pop(context),
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Student',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this student? This action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            type: ButtonType.secondary,
          ),
          AppButton(
            text: 'Delete',
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStudent();
            },
            type: ButtonType.danger,
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
