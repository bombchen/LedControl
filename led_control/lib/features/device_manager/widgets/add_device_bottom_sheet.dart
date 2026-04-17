import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/providers/device_provider.dart';
import 'package:led_control/core/models/device.dart';

/// 添加设备底部表单
class AddDeviceBottomSheet extends ConsumerStatefulWidget {
  const AddDeviceBottomSheet({super.key});

  @override
  ConsumerState<AddDeviceBottomSheet> createState() =>
      _AddDeviceBottomSheetState();
}

class _AddDeviceBottomSheetState extends ConsumerState<AddDeviceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '8888');
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题
              Row(
                children: [
                  const Text(
                    '添加设备',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 设备名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '设备名称',
                  hintText: '例如：客厅灯带',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入设备名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // IP 地址
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'IP 地址',
                  hintText: '例如：192.168.1.100',
                  prefixIcon: Icon(Icons.computer),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入 IP 地址';
                  }
                  // 简单的 IP 地址格式验证
                  final ipRegex = RegExp(
                    r'^(\d{1,3}\.){3}\d{1,3}$',
                  );
                  if (!ipRegex.hasMatch(value.trim())) {
                    return '请输入有效的 IP 地址';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 端口
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: '端口',
                  hintText: '默认：8888',
                  prefixIcon: Icon(Icons.settings_ethernet),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入端口号';
                  }
                  final port = int.tryParse(value.trim());
                  if (port == null || port < 1 || port > 65535) {
                    return '请输入有效的端口号 (1-65535)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 保存按钮
              FilledButton(
                onPressed: _isSaving ? null : _saveDevice,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 保存设备
  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 检查设备是否已存在
      final existingDevice = ref
          .read(deviceProvider.notifier)
          .findDeviceByIP(_ipController.text.trim());

      if (existingDevice != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('该 IP 地址的设备已存在')),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // 创建新设备 - 使用时间戳作为简单 ID
      final device = Device(
        id: 'device_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        ipAddress: _ipController.text.trim(),
        port: int.parse(_portController.text.trim()),
        lastSeen: DateTime.now(),
        isOnline: false, // 新添加的设备默认离线，需要连接测试
      );

      await ref.read(deviceProvider.notifier).addDevice(device);

      if (!mounted) return;

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设备添加成功')),
      );

      // 关闭表单
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      // 显示错误消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
