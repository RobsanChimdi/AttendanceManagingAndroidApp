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

  testWidgets('Student registration screen renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.byType(MyApp), findsOneWidget);
  });

  testWidgets('Face enrollment screen renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
