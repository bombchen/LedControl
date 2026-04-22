import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/models/device.dart';
import 'package:led_control/core/providers/device_provider.dart';
import 'package:led_control/features/provisioning/provisioning_guide_page.dart';

class DeviceSettingsPage extends ConsumerStatefulWidget {
  const DeviceSettingsPage({super.key, required this.device});

  final Device device;

  @override
  ConsumerState<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends ConsumerState<DeviceSettingsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _ipController;
  late final TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.name);
    _ipController = TextEditingController(text: widget.device.ipAddress);
    _portController = TextEditingController(text: widget.device.port.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _saveDevice() async {
    final updatedDevice = widget.device.copyWith(
      name: _nameController.text.trim(),
      ipAddress: _ipController.text.trim(),
      port: int.tryParse(_portController.text.trim()) ?? widget.device.port,
    );

    await ref.read(deviceProvider.notifier).updateDevice(updatedDevice);
    if (!mounted) return;

    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: const Text('设备信息已更新'),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDevice() async {
    await ref.read(deviceProvider.notifier).removeDevice(widget.device.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _reProvision() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => const ProvisioningGuidePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('设备设置'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('基础信息'),
              children: [
                CupertinoFormRow(
                  prefix: const Text('名称'),
                  child: CupertinoTextField(controller: _nameController),
                ),
                CupertinoFormRow(
                  prefix: const Text('IP 地址'),
                  child: CupertinoTextField(controller: _ipController),
                ),
                CupertinoFormRow(
                  prefix: const Text('端口'),
                  child: CupertinoTextField(controller: _portController, keyboardType: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: _saveDevice,
              child: const Text('保存修改'),
            ),
            const SizedBox(height: 12),
            CupertinoButton(
              onPressed: _reProvision,
              child: const Text('重新配网'),
            ),
            const SizedBox(height: 12),
            CupertinoButton(
              onPressed: _deleteDevice,
              child: const Text('删除设备'),
            ),
          ],
        ),
      ),
    );
  }
}
