import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/main.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Setup Mock SharedPreferences for ProviderScope
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const InclusiveEdStudentApp(),
      ),
    );

    // Initial check (may not find standard counters as this is a custom app)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
