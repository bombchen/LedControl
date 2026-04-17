import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:led_control/app.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LedControlApp(),
      ),
    );

    // Verify that the splash screen is displayed.
    expect(find.text('LED 灯带控制器'), findsOneWidget);
    expect(find.text('初始化中...'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.lightbulb), findsOneWidget);
  });
}
