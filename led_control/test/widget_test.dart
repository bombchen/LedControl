import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:led_control/app.dart';
import 'package:led_control/core/providers/app_entry_provider.dart';

void main() {
  testWidgets('App switches from discovery to control by entry mode', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LedControlApp(),
      ),
    );

    await tester.pump();

    expect(find.text('设备搜索'), findsOneWidget);
    expect(find.text('扫描设备'), findsAtLeastNWidgets(1));

    container.read(appEntryProvider.notifier).showControl();
    await tester.pump();

    expect(find.text('效果控制'), findsOneWidget);
  });
}
