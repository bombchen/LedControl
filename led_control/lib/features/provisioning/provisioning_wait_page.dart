import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/providers/provisioning_provider.dart';

class ProvisioningWaitPage extends ConsumerWidget {
  const ProvisioningWaitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provisioningProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('配网等待'),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(height: 12),
            Text(state.errorMessage ?? '设备正在保存配置并重启'),
            const SizedBox(height: 12),
            CupertinoButton(
              onPressed: () => ref.read(provisioningProvider.notifier).retry(),
              child: const Text('重新尝试'),
            ),
          ],
        ),
      ),
    );
  }
}
