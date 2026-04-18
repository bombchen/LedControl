import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:led_control/app.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LedControlApp(),
      ),
    );

    // Wait for async operations
    await tester.pump();

    // Verify the app starts without crashing
    expect(find.byType(CupertinoApp), findsOneWidget);
  });

  testWidgets('App displays control tabs', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LedControlApp(),
      ),
    );

    // Wait for async operations
    await tester.pump();

    // Verify that the control page is displayed with TabBar
    expect(find.byType(CupertinoTabScaffold), findsOneWidget);
  });
}
