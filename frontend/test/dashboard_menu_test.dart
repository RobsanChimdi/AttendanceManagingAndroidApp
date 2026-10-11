import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_ai/features/dashboard/admin_dashboard_screen.dart';
import 'package:edutrack_ai/features/dashboard/teacher_dashboard_screen.dart';

void main() {
  testWidgets('admin dashboard menu includes key navigation items', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final items = buildAdminDashboardMenuItems(context);
            expect(items, hasLength(4));
            expect(
              items.map((item) => (item as PopupMenuItem<String>).value),
              containsAll([
                'students',
                'critical-attendance',
                'analytics',
                'reports',
              ]),
            );
            return const SizedBox();
          },
        ),
      ),
    );
  });

  testWidgets('teacher dashboard menu includes teacher navigation items', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final items = buildTeacherDashboardMenuItems(context);
            expect(items, hasLength(5));
            expect(
              items.map((item) => (item as PopupMenuItem<String>).value),
              containsAll([
                'start-attendance',
                'students',
                'critical-attendance',
                'analytics',
                'reports',
              ]),
            );
            return const SizedBox();
          },
        ),
      ),
    );
  });
}
