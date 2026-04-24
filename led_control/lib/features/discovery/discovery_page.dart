import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/models/device.dart';
import 'package:led_control/core/providers/app_entry_provider.dart';
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

  Future<void> _enterControlForDevice(WidgetRef ref, String deviceId) async {
    await ref.read(deviceProvider.notifier).selectDevice(deviceId);
    ref.read(appEntryProvider.notifier).showControl();
  }

  Future<void> _openManualAddSheet(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final ipController = TextEditingController();
    final portController = TextEditingController(text: '8888');

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemBackground,
        child: SafeArea(
          child: CupertinoFormSection.insetGrouped(
            header: const Text('手动添加设备'),
            children: [
              CupertinoFormRow(
                prefix: const Text('名称'),
                child: CupertinoTextField(controller: nameController),
              ),
              CupertinoFormRow(
                prefix: const Text('IP 地址'),
                child: CupertinoTextField(controller: ipController),
              ),
              CupertinoFormRow(
                prefix: const Text('端口'),
                child: CupertinoTextField(
                  controller: portController,
                  keyboardType: TextInputType.number,
                ),
              ),
              CupertinoButton(
                onPressed: () async {
                  final device = Device(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    ipAddress: ipController.text.trim(),
                    port: int.tryParse(portController.text.trim()) ?? 8888,
                    lastSeen: DateTime.now(),
                    isOnline: false,
                  );
                  await ref.read(deviceProvider.notifier).addDevice(device);
                  await ref.read(deviceProvider.notifier).selectDevice(device.id);
                  ref.read(appEntryProvider.notifier).showControl();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('保存'),
              ),
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
            ],
          ),
        ),
      ),
    );

    nameController.dispose();
    ipController.dispose();
    portController.dispose();
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
              onPressed: () => _openManualAddSheet(context, ref),
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
                        onTap: () => _enterControlForDevice(ref, device.id),
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
