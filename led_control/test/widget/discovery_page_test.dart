import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:led_control/features/discovery/discovery_page.dart';

void main() {
  testWidgets('discovery page shows scan and provisioning actions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: DiscoveryPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('设备搜索'), findsOneWidget);
    expect(find.text('扫描设备'), findsAtLeastNWidgets(1));
    expect(find.text('手动添加 IP'), findsOneWidget);
    expect(find.text('开始配网'), findsOneWidget);
  });
}
