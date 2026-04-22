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
        child: Center(
          child: CupertinoButton.filled(
            onPressed: () => ref.read(provisioningProvider.notifier).selectSsid('MyWifi'),
            child: const Text('选择 MyWifi'),
          ),
        ),
      ),
    );
  }
}
