import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_empty_state.dart';
import '../../services/report_service.dart';

enum ReportType {
  daily,
  weekly,
  monthly,
  student,
  class_,
  critical,
}

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final ReportService _reportService = ReportService();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  
  bool _isLoading = false;
  String? _errorMessage;
  
  ReportType _selectedReportType = ReportType.daily;
  
  // Filters
  DateTime? _selectedDate;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _selectedGrade;
  int? _selectedClassId;
  String? _selectedSection;
  int? _selectedStudentId;
  String? _selectedStatus;
  String? _selectedMethod;
  
  // Report data
  Map<String, dynamic>? _reportData;
  List<dynamic> _records = [];
  int _total = 0;
  int _currentPage = 0;
  int _pageSize = 20;
  Map<String, dynamic>? _summary;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> data;
      
      switch (_selectedReportType) {
        case ReportType.daily:
          if (_selectedDate == null) {
            _selectedDate = DateTime.now();
          }
          data = await _reportService.getDailyAttendanceReport(
            date: _selectedDate!,
            grade: _selectedGrade,
            classId: _selectedClassId,
            section: _selectedSection,
            skip: _currentPage * _pageSize,
            limit: _pageSize,
          );
          break;
        case ReportType.weekly:
          final weekStart = _dateFrom ?? DateTime.now();
          data = await _reportService.getWeeklyAttendanceReport(
            weekStart: weekStart,
            grade: _selectedGrade,
            classId: _selectedClassId,
            section: _selectedSection,
            skip: _currentPage * _pageSize,
            limit: _pageSize,
          );
          break;
        case ReportType.monthly:
          final now = _dateFrom ?? DateTime.now();
          data = await _reportService.getMonthlyAttendanceReport(
            year: now.year,
            month: now.month,
            grade: _selectedGrade,
            classId: _selectedClassId,
            section: _selectedSection,
            skip: _currentPage * _pageSize,
            limit: _pageSize,
          );
          break;
        case ReportType.student:
          if (_selectedStudentId == null) {
            throw Exception('Please select a student');
          }
          data = await _reportService.getStudentAttendanceReport(
            studentId: _selectedStudentId!,
            dateFrom: _dateFrom,
            dateTo: _dateTo,
            skip: _currentPage * _pageSize,
            limit: _pageSize,
          );
          break;
        case ReportType.class_:
          if (_selectedClassId == null) {
            throw Exception('Please select a class');
          }
          data = await _reportService.getClassAttendanceReport(
            classId: _selectedClassId!,
            dateFrom: _dateFrom,
            dateTo: _dateTo,
            skip: _currentPage * _pageSize,
            limit: _pageSize,
          );
          break;
        case ReportType.critical:
          data = await _reportService.getCriticalAttendanceReport(
            threshold: 50.0,
            grade: _selectedGrade,
            classId: _selectedClassId,
            section: _selectedSection,
            skip: _currentPage * _pageSize,
            limit: _pageSize,
          );
          break;
      }

      if (mounted) {
        setState(() {
          _reportData = data;
          _records = data['records'] ?? [];
          _total = data['total'] ?? 0;
          _summary = data['summary'];
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
    _currentPage = 0;
    await _loadReport();
    _refreshController.refreshCompleted();
  }

  Future<void> _exportCSV() async {
    try {
      String csvContent;
      
      if (_selectedReportType == ReportType.daily) {
        csvContent = await _reportService.exportDailyAttendanceCSV(
          date: _selectedDate ?? DateTime.now(),
          grade: _selectedGrade,
          classId: _selectedClassId,
          section: _selectedSection,
        );
      } else if (_selectedReportType == ReportType.critical) {
        csvContent = await _reportService.exportCriticalAttendanceCSV(
          threshold: 50.0,
          grade: _selectedGrade,
          classId: _selectedClassId,
          section: _selectedSection,
        );
      } else {
        // Generate CSV locally for other report types
        final headers = ['ID', 'Student', 'Class', 'Status', 'Date'];
        final csvRows = <List<dynamic>>[headers];
        for (final rec in _records) {
          csvRows.add([
            rec['student_id'] ?? rec['roll_number'] ?? '',
            rec['student_name'] ?? rec['full_name'] ?? '',
            '${rec['grade'] ?? ''} ${rec['section'] ?? ''}'.trim(),
            rec['status'] ?? '',
            rec['check_in_time'] ?? rec['marked_at'] ?? '',
          ]);
        }
        csvContent = const ListToCsvConverter().convert(csvRows);
      }

      // Save to file and share
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/report_$timestamp.csv');
      await file.writeAsString(csvContent);
      
      await Share.shareXFiles([XFile(file.path)], text: 'Attendance Report');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export CSV: $e')),
        );
      }
    }
  }

  Future<void> _exportPDF() async {
    try {
      List<int> pdfBytes;
      if (_selectedReportType == ReportType.daily) {
        pdfBytes = await _reportService.exportDailyAttendancePDF(
          date: _selectedDate ?? DateTime.now(),
          grade: _selectedGrade,
          classId: _selectedClassId,
          section: _selectedSection,
        );
      } else if (_selectedReportType == ReportType.critical) {
        pdfBytes = await _reportService.exportCriticalAttendancePDF(
          threshold: 50.0,
          grade: _selectedGrade,
          classId: _selectedClassId,
          section: _selectedSection,
        );
      } else {
        pdfBytes = await _reportService.exportDailyAttendancePDF(
          date: DateTime.now(),
        );
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/report_$timestamp.pdf');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Attendance PDF Report');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationSm,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
            tooltip: 'Refresh',
            color: AppColors.textSecondary,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPDF,
            tooltip: 'Export PDF',
            color: AppColors.textSecondary,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportCSV,
            tooltip: 'Export CSV',
            color: AppColors.textSecondary,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(),
          const Divider(height: 1, color: AppColors.divider),
          
          // Report content
          Expanded(
            child: _isLoading
                ? const AppLoading(message: 'Loading report...')
                : _errorMessage != null
                    ? _buildErrorView()
                    : _records.isEmpty
                        ? _buildEmptyView()
                        : _buildReportContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report type selector
          Text(
            'Report Type',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ReportType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(_getReportTypeLabel(type)),
                    selected: _selectedReportType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedReportType = type;
                          _currentPage = 0;
                        });
                        _loadReport();
                      }
                    },
                    selectedColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: _selectedReportType == type ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Date filters
          if (_selectedReportType == ReportType.daily) ...[
            _buildDateFilter(
              'Date',
              _selectedDate,
              (date) {
                setState(() {
                  _selectedDate = date;
                });
                _loadReport();
              },
            ),
          ],
          
          if (_selectedReportType == ReportType.weekly || 
              _selectedReportType == ReportType.monthly ||
              _selectedReportType == ReportType.student ||
              _selectedReportType == ReportType.class_) ...[
            Row(
              children: [
                Expanded(
                  child: _buildDateFilter(
                    'From',
                    _dateFrom,
                    (date) {
                      setState(() {
                        _dateFrom = date;
                      });
                      _loadReport();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildDateFilter(
                    'To',
                    _dateTo,
                    (date) {
                      setState(() {
                        _dateTo = date;
                      });
                      _loadReport();
                    },
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: AppSpacing.lg),
          
          // Additional filters
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildDropdownFilter(
                'Grade',
                ['All', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
                _selectedGrade,
                (value) {
                  setState(() {
                    _selectedGrade = value == 'All' ? null : value;
                  });
                  _loadReport();
                },
              ),
              _buildDropdownFilter(
                'Status',
                ['All', 'PRESENT', 'ABSENT'],
                _selectedStatus,
                (value) {
                  setState(() {
                    _selectedStatus = value == 'All' ? null : value;
                  });
                  _loadReport();
                },
              ),
              _buildDropdownFilter(
                'Method',
                ['All', 'FACE', 'QR', 'MANUAL'],
                _selectedMethod,
                (value) {
                  setState(() {
                    _selectedMethod = value == 'All' ? null : value;
                  });
                  _loadReport();
                },
              ),
            ],
          ),
          
          // Summary if available
          if (_summary != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildSummaryCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildDateFilter(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(selectedDate)
                  : label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selectedDate != null ? AppColors.textPrimary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    List<String> options,
    String? selectedValue,
    Function(String?) onSelected,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue ?? 'All',
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option, style: AppTextStyles.bodyMedium),
            );
          }).toList(),
          onChanged: onSelected,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
          dropdownColor: AppColors.surface,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: AppColors.primary.withOpacity(0.05),
      isBordered: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', _summary?['total_records'] ?? 0, Icons.description, AppColors.primary),
          _buildSummaryItem('Present', _summary?['present_count'] ?? 0, Icons.check_circle, AppColors.success),
          _buildSummaryItem('Absent', _summary?['absent_count'] ?? 0, Icons.cancel, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, dynamic value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
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
              onPressed: _loadReport,
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return NoDataEmptyState(
      message: 'Try adjusting your filters',
      onRefresh: _loadReport,
    );
  }

  Widget _buildReportContent() {
    return Column(
      children: [
        // Records count
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${_records.length} of $_total records',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (_total > _pageSize)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                              _loadReport();
                            }
                          : null,
                      color: AppColors.textSecondary,
                    ),
                    Text(
                      '${_currentPage + 1}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: (_currentPage + 1) * _pageSize < _total
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                              _loadReport();
                            }
                          : null,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
            ],
          ),
        ),
        
        // Table
        Expanded(
          child: SingleChildScrollView(
            child: AppCard(
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(AppColors.surfaceVariant),
                  columns: _buildTableColumns(),
                  rows: _records.map((record) {
                    return _buildTableRow(record);
                  }).toList(),
                  columnSpacing: AppSpacing.md,
                  horizontalMargin: AppSpacing.lg,
                  headingRowHeight: 56,
                  dataRowHeight: 56,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildTableColumns() {
    if (_selectedReportType == ReportType.critical) {
      return [
        DataColumn(
          label: Text(
            'Student',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'ID',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Grade',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Section',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Attendance %',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Guardian',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ];
    }
    
    return [
      DataColumn(
        label: Text(
          'Date',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Student',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'ID',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Class',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Status',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Method',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Time',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
  }

  DataRow _buildTableRow(dynamic record) {
    if (_selectedReportType == ReportType.critical) {
      return DataRow(
        cells: [
          DataCell(Text(
            record['student_name'] ?? '',
            style: AppTextStyles.bodyMedium,
          )),
          DataCell(Text(
            record['student_id_str'] ?? '',
            style: AppTextStyles.bodyMedium,
          )),
          DataCell(Text(
            record['grade'] ?? '',
            style: AppTextStyles.bodyMedium,
          )),
          DataCell(Text(
            record['section'] ?? '',
            style: AppTextStyles.bodyMedium,
          )),
          DataCell(
            Text(
              '${record['attendance_percentage']?.toStringAsFixed(1) ?? '0'}%',
              style: AppTextStyles.bodyMedium.copyWith(
                color: (record['attendance_percentage'] ?? 0) < 50
                    ? AppColors.error
                    : AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataCell(Text(
            record['guardian_name'] ?? '',
            style: AppTextStyles.bodyMedium,
          )),
        ],
      );
    }
    
    return DataRow(
      cells: [
        DataCell(Text(
          _formatDate(record['date']),
          style: AppTextStyles.bodyMedium,
        )),
        DataCell(Text(
          record['student_name'] ?? '',
          style: AppTextStyles.bodyMedium,
        )),
        DataCell(Text(
          record['student_id_str'] ?? '',
          style: AppTextStyles.bodyMedium,
        )),
        DataCell(Text(
          record['class_name'] ?? '',
          style: AppTextStyles.bodyMedium,
        )),
        DataCell(
          Row(
            children: [
              Icon(
                record['status'] == 'PRESENT' ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: record['status'] == 'PRESENT' ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                record['status'] ?? '',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
        DataCell(Text(
          record['method'] ?? '',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        )),
        DataCell(Text(
          _formatTime(record['recognized_at']),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textHint,
          ),
        )),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is String) {
      try {
        final parsed = DateTime.parse(date);
        return DateFormat('yyyy-MM-dd').format(parsed);
      } catch (e) {
        return date;
      }
    }
    return DateFormat('yyyy-MM-dd').format(date as DateTime);
  }

  String _formatTime(dynamic dateTime) {
    if (dateTime == null) return '';
    if (dateTime is String) {
      try {
        final parsed = DateTime.parse(dateTime);
        return DateFormat('HH:mm').format(parsed);
      } catch (e) {
        return '';
      }
    }
    return DateFormat('HH:mm').format(dateTime as DateTime);
  }

  String _getReportTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.daily:
        return 'Daily';
      case ReportType.weekly:
        return 'Weekly';
      case ReportType.monthly:
        return 'Monthly';
      case ReportType.student:
        return 'Student';
      case ReportType.class_:
        return 'Class';
      case ReportType.critical:
        return 'Critical';
    }
  }
}
