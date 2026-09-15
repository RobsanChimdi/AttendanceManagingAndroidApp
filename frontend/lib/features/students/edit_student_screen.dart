import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/student_models.dart';
import '../../services/student_service.dart';

class EditStudentScreen extends ConsumerStatefulWidget {
  final int studentId;

  const EditStudentScreen({super.key, required this.studentId});

  @override
  ConsumerState<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends ConsumerState<EditStudentScreen> {
  final StudentService _studentService = StudentService();
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  String? _selectedGrade;
  String? _selectedSection;
  int? _selectedClassId;
  StudentStatus? _selectedStatus;
  
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  Student? _student;

  final List<String> _grades = ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];
  final List<String> _sections = ['A', 'B', 'C', 'D', 'E'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadStudent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final student = await _studentService.getStudent(widget.studentId);
      setState(() {
        _student = student;
        _firstNameController.text = student.firstName;
        _middleNameController.text = student.middleName ?? '';
        _lastNameController.text = student.lastName;
        _selectedGender = student.gender;
        _selectedDateOfBirth = student.dateOfBirth != null 
            ? DateTime.tryParse(student.dateOfBirth!) 
            : null;
        _selectedGrade = student.grade;
        _selectedSection = student.section;
        _selectedClassId = student.classId;
        _guardianNameController.text = student.guardianName ?? '';
        _guardianPhoneController.text = student.guardianPhone ?? '';
        _guardianEmailController.text = student.guardianEmail ?? '';
        _selectedStatus = student.status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final studentUpdate = StudentUpdate(
        firstName: _firstNameController.text.trim(),
        middleName: _middleNameController.text.trim().isEmpty ? null : _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth?.toIso8601String().split('T')[0],
        grade: _selectedGrade,
        section: _selectedSection,
        classId: _selectedClassId,
        guardianName: _guardianNameController.text.trim().isEmpty ? null : _guardianNameController.text.trim(),
        guardianPhone: _guardianPhoneController.text.trim().isEmpty ? null : _guardianPhoneController.text.trim(),
        guardianEmail: _guardianEmailController.text.trim().isEmpty ? null : _guardianEmailController.text.trim(),
        status: _selectedStatus,
      );

      await _studentService.updateStudent(widget.studentId, studentUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSaving = false;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDateOfBirth = picked;
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
        appBar: AppBar(title: const Text('Edit Student')),
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
        title: const Text('Edit Student'),
        actions: [
          if (_student != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student ID (read-only)
              if (_student != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student ID',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _student!.studentId,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              
              // Personal Information Section
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _middleNameController,
                decoration: const InputDecoration(
                  labelText: 'Middle Name',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wc),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Select Gender')),
                  ..._genders.map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      )),
                ],
                onChanged: _isSaving ? null : (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: _isSaving ? null : _selectDateOfBirth,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDateOfBirth != null
                        ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                        : 'Select Date',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Academic Information Section
              const Text(
                'Academic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedGrade,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Select Grade')),
                  ..._grades.map((grade) => DropdownMenuItem(
                        value: grade,
                        child: Text(grade),
                      )),
                ],
                onChanged: _isSaving ? null : (value) {
                  setState(() {
                    _selectedGrade = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedSection,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Select Section')),
                  ..._sections.map((section) => DropdownMenuItem(
                        value: section,
                        child: Text(section),
                      )),
                ],
                onChanged: _isSaving ? null : (value) {
                  setState(() {
                    _selectedSection = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Class ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                keyboardType: TextInputType.number,
                initialValue: _selectedClassId?.toString(),
                onChanged: (value) {
                  setState(() {
                    _selectedClassId = value.isNotEmpty ? int.tryParse(value) : null;
                  });
                },
                enabled: !_isSaving,
              ),
              const SizedBox(height: 24),
              
              // Guardian Information Section
              const Text(
                'Guardian Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _guardianNameController,
                decoration: const InputDecoration(
                  labelText: 'Guardian Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _guardianPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Guardian Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final phoneRegex = RegExp(r'^[0-9+\-\s()]+$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _guardianEmailController,
                decoration: const InputDecoration(
                  labelText: 'Guardian Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
                enabled: !_isSaving,
              ),
              const SizedBox(height: 24),
              
              // Status Section
              const Text(
                'Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<StudentStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Student Status',
                  border: OutlineInputBorder(),
                ),
                items: StudentStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    )).toList(),
                onChanged: _isSaving ? null : (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Update Student'),
                ),
              ),
            ],
          ),
        ),
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
