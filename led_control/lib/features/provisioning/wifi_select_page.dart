import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/providers/provisioning_provider.dart';

class WifiSelectPage extends ConsumerWidget {
  const WifiSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Wi‑Fi 选择'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('请选择要连接的 Wi‑Fi 网络'),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: () => ref.read(provisioningProvider.notifier).selectSsid('MyWifi'),
              child: const Text('选择 MyWifi'),
            ),
            const SizedBox(height: 12),
            CupertinoButton(
              onPressed: () {},
              child: const Text('刷新列表'),
            ),
            const SizedBox(height: 12),
            CupertinoButton(
              onPressed: () {},
              child: const Text('手动输入 SSID'),
            ),
          ],
        ),
      ),
    );
  }
}
