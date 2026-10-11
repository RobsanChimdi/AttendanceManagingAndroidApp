import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_ai/main.dart';
import 'package:edutrack_ai/models/auth_models.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Verify login screen elements are present
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Login with empty fields shows validation error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Tap login button without entering credentials
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify validation error is shown
    expect(find.text('Please enter your email'), findsOneWidget);
  });

  testWidgets('Login with invalid email format shows error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Enter invalid email in first TextFormField
    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify email format error is shown
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('Password field toggles visibility', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Tap eye icon to toggle password visibility
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  test('Login response parses backend snake_case JSON', () {
    final json = {
      'access_token': 'token123',
      'refresh_token': 'refresh456',
      'token_type': 'bearer',
      'user': {
        'id': 1,
        'name': 'Test Teacher',
        'email': 'teacher@example.com',
        'role': 'TEACHER',
        'created_at': '2025-01-01T00:00:00.000Z',
        'updated_at': '2025-01-01T00:00:00.000Z',
      },
    };

    final response = LoginResponse.fromJson(json);

    expect(response.accessToken, 'token123');
    expect(response.refreshToken, 'refresh456');
    expect(response.user.role, UserRole.teacher);
  });
}
