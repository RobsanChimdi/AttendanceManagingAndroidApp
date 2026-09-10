import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading.dart';
import '../../models/student_models.dart';
import '../../services/student_service.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final StudentService _studentService = StudentService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Student> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _total = 0;
  int _skip = 0;
  final int _limit = 20;
  
  String? _selectedGrade;
  String? _selectedSection;
  StudentStatus? _selectedStatus;
  String? _sortBy;
  String _sortOrder = 'asc';

  final List<String> _grades = ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];
  final List<String> _sections = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _studentService.getStudents(
        skip: _skip,
        limit: _limit,
        grade: _selectedGrade,
        section: _selectedSection,
        status: _selectedStatus,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      setState(() {
        _students = result.students;
        _total = result.total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Students'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Grade'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Grades')),
                    ..._grades.map((grade) => DropdownMenuItem(
                          value: grade,
                          child: Text(grade),
                        )),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedGrade = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Section'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSection,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Sections')),
                    ..._sections.map((section) => DropdownMenuItem(
                          value: section,
                          child: Text(section),
                        )),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedSection = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Status'),
                const SizedBox(height: 8),
                DropdownButtonFormField<StudentStatus>(
                  value: _selectedStatus,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Status')),
                    ...StudentStatus.values.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.name),
                        )),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _selectedGrade = null;
                  _selectedSection = null;
                  _selectedStatus = null;
                });
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _skip = 0;
                });
                Navigator.pop(context);
                _loadStudents();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Students'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('First Name'),
              value: 'first_name',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value;
                });
                Navigator.pop(context);
                _loadStudents();
              },
            ),
            RadioListTile<String>(
              title: const Text('Last Name'),
              value: 'last_name',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value;
                });
                Navigator.pop(context);
                _loadStudents();
              },
            ),
            RadioListTile<String>(
              title: const Text('Student ID'),
              value: 'student_id',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value;
                });
                Navigator.pop(context);
                _loadStudents();
              },
            ),
            RadioListTile<String>(
              title: const Text('Grade'),
              value: 'grade',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value;
                });
                Navigator.pop(context);
                _loadStudents();
              },
            ),
            const Divider(),
            RadioListTile<String>(
              title: const Text('Ascending'),
              value: 'asc',
              groupValue: _sortOrder,
              onChanged: (value) {
                setState(() {
                  _sortOrder = value!;
                });
                Navigator.pop(context);
                _loadStudents();
              },
            ),
            RadioListTile<String>(
              title: const Text('Descending'),
              value: 'desc',
              groupValue: _sortOrder,
              onChanged: (value) {
                setState(() {
                  _sortOrder = value!;
                });
                Navigator.pop(context);
                _loadStudents();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationSm,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or student ID...',
                hintStyle: TextStyle(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _loadStudents();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _loadStudents();
                  }
                });
              },
            ),
          ),
          
          // Student list
          Expanded(
            child: _isLoading
                ? const AppLoading(message: 'Loading students...')
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
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
                              ElevatedButton(
                                onPressed: _loadStudents,
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
                      )
                    : _students.isEmpty
                        ? NoSearchResultsEmptyState(
                            message: 'Try adjusting your search or filters',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: _students.length,
                            itemBuilder: (context, index) {
                              final student = _students[index];
                              return AppCard(
                                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                onTap: () {
                                  context.push('/students/${student.id}');
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary.withOpacity(0.1),
                                      child: Text(
                                        '${student.firstName[0]}${student.lastName[0]}',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${student.firstName} ${student.lastName}',
                                            style: AppTextStyles.titleMedium.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'ID: ${student.studentId}',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          if (student.grade != null || student.section != null)
                                            Text(
                                              '${student.grade ?? ''} ${student.section ?? ''}'.trim(),
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    _buildStatusBadge(student.status),
                                    const SizedBox(width: AppSpacing.sm),
                                    Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textHint,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          
          // Pagination info
          if (_total > 0)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${_skip + 1}-${(_skip + _limit).clamp(1, _total)} of $_total',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _skip > 0
                            ? () {
                                setState(() {
                                  _skip = (_skip - _limit).clamp(0, _total);
                                });
                                _loadStudents();
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _skip + _limit < _total
                            ? () {
                                setState(() {
                                  _skip += _limit;
                                });
                                _loadStudents();
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/students/add');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
    );
  }

  Widget _buildStatusBadge(StudentStatus status) {
    StatusType type;
    String label;

    switch (status) {
      case StudentStatus.active:
        type = StatusType.present;
        label = 'Active';
        break;
      case StudentStatus.inactive:
        type = StatusType.absent;
        label = 'Inactive';
        break;
      case StudentStatus.graduated:
        type = StatusType.info;
        label = 'Graduated';
        break;
    }

    return AppStatusBadge(label: label, type: type, isSmall: true);
  }
}
