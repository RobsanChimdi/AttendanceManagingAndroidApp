import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or student ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadStudents();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadStudents,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _students.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No students found'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _students.length,
                            itemBuilder: (context, index) {
                              final student = _students[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      '${student.firstName[0]}${student.lastName[0]}',
                                    ),
                                  ),
                                  title: Text(
                                    '${student.firstName} ${student.lastName}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('ID: ${student.studentId}'),
                                      if (student.grade != null || student.section != null)
                                        Text(
                                          '${student.grade ?? ''} ${student.section ?? ''}'.trim(),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildStatusChip(student.status),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                  onTap: () {
                                    context.push('/students/${student.id}');
                                  },
                                ),
                              );
                            },
                          ),
          ),
          
          // Pagination info
          if (_total > 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Showing ${_skip + 1}-${(_skip + _limit).clamp(1, _total)} of $_total'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/students/add');
        },
        child: const Icon(Icons.add),
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
}
