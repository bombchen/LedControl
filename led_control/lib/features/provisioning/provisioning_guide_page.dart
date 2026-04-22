import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/providers/provisioning_provider.dart';

class ProvisioningGuidePage extends ConsumerWidget {
  const ProvisioningGuidePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('配网引导'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('请先连接设备热点 LED_Config'),
              const SizedBox(height: 12),
              CupertinoButton.filled(
                onPressed: () => ref.read(provisioningProvider.notifier).goToWifiSelect(),
                child: const Text('已连接热点'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
