import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/providers/discovery_provider.dart';
import 'package:led_control/core/providers/device_provider.dart';
import 'package:led_control/features/provisioning/provisioning_guide_page.dart';

class DiscoveryPage extends ConsumerWidget {
  const DiscoveryPage({super.key});

  void _openProvisioning(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => const ProvisioningGuidePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoveryAsync = ref.watch(deviceDiscoveryProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('设备搜索'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '扫描设备',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('搜索局域网内已联网的 LED 设备，并作为控制或配网流程入口。'),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: () {
                ref.read(deviceDiscoveryProvider.notifier).refresh();
              },
              child: const Text('扫描设备'),
            ),
            const SizedBox(height: 12),
            CupertinoButton(
              onPressed: () {},
              child: const Text('手动添加 IP'),
            ),
            const SizedBox(height: 12),
            CupertinoButton(
              onPressed: () => _openProvisioning(context),
              child: const Text('开始配网'),
            ),
            const SizedBox(height: 24),
            discoveryAsync.when(
              loading: () => const Text('正在准备扫描...'),
              error: (error, stack) => const Text('设备扫描暂不可用'),
              data: (devices) {
                if (devices.isEmpty) {
                  return const Text('未发现在线设备');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('已发现 ${devices.length} 台在线设备'),
                    const SizedBox(height: 12),
                    ...devices.map(
                      (device) => CupertinoListTile(
                        title: Text(device.name),
                        subtitle: Text(device.networkAddress),
                        trailing: device.isSelected
                            ? const Text('当前')
                            : const Icon(CupertinoIcons.chevron_forward),
                        onTap: () async {
                          await ref.read(deviceProvider.notifier).selectDevice(device.id);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
