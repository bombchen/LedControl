import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/features/provisioning/provisioning_guide_page.dart';
import 'package:led_control/features/provisioning/wifi_select_page.dart';
import 'package:led_control/features/provisioning/password_entry_page.dart';
import 'package:led_control/features/provisioning/provisioning_wait_page.dart';

void main() {
  testWidgets('provisioning flow pages render their core actions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: ProvisioningGuidePage(),
        ),
      ),
    );

    expect(find.text('配网引导'), findsOneWidget);
    expect(find.text('已连接热点'), findsOneWidget);

    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: WifiSelectPage(),
        ),
      ),
    );

    expect(find.text('Wi‑Fi 选择'), findsOneWidget);
    expect(find.text('选择 MyWifi'), findsOneWidget);

    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: PasswordEntryPage(),
        ),
      ),
    );

    expect(find.text('密码输入'), findsOneWidget);
    expect(find.text('连接'), findsOneWidget);

    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: ProvisioningWaitPage(),
        ),
      ),
    );

    expect(find.text('配网等待'), findsOneWidget);
    expect(find.text('重新尝试'), findsOneWidget);
  });
}
