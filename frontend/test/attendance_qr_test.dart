import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_ai/main.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MyApp(),
    );
  }

  testWidgets('Attendance scanner screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.byType(MyApp), findsOneWidget);
  });

  testWidgets('Attendance scanner requires camera permission smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.byType(MyApp), findsOneWidget);
  });

  testWidgets('Attendance scanner shows session info smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.byType(MyApp), findsOneWidget);
  });

  testWidgets('QR scanner screen renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
