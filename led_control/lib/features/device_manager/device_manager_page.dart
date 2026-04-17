import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/providers/device_provider.dart';
import 'package:led_control/core/providers/scan_provider.dart';
import 'package:led_control/core/models/device.dart';
import 'package:led_control/features/device_manager/widgets/device_list_item.dart';
import 'package:led_control/features/device_manager/widgets/add_device_bottom_sheet.dart';

/// 设备管理页面
class DeviceManagerPage extends ConsumerStatefulWidget {
  const DeviceManagerPage({super.key});

  @override
  ConsumerState<DeviceManagerPage> createState() => _DeviceManagerPageState();
}

class _DeviceManagerPageState extends ConsumerState<DeviceManagerPage> {
  @override
  void initState() {
    super.initState();
    // 初始加载设备列表
    Future.microtask(() {
      ref.read(deviceProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(deviceProvider);
    final scanState = ref.watch(scanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设备管理'),
        actions: [
          // 扫描按钮
          IconButton(
            icon: const Icon(Icons.wifi_find),
            onPressed: scanState.isScanning
                ? null
                : () => _showScanOptions(context),
            tooltip: '扫描设备',
          ),
        ],
      ),
      body: devicesAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('加载设备列表...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(deviceProvider.notifier).refresh();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        data: (devices) {
          if (devices.isEmpty) {
            return _buildEmptyState(context, scanState);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(deviceProvider.notifier).refresh();
            },
            child: ListView.builder(
              itemCount: devices.length + 1, // +1 for scan results header
              itemBuilder: (context, index) {
                if (index == devices.length) {
                  // 显示扫描结果
                  return _buildScanResults(context, scanState);
                }
                return DeviceListItem(
                  device: devices[index],
                  onEdit: (device) => _editDevice(context, device),
                  onDelete: (device) => _confirmDeleteDevice(context, device),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDeviceOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context, ScanState scanState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无设备',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('点击 + 添加设备，或使用扫描功能发现设备'),
          if (scanState.devices.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('发现 ${scanState.devices.length} 个设备，请添加'),
          ],
        ],
      ),
    );
  }

  /// 构建扫描结果区域
  Widget _buildScanResults(BuildContext context, ScanState scanState) {
    if (scanState.devices.isEmpty && !scanState.isScanning) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (scanState.isScanning)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('正在扫描设备...'),
              ],
            ),
          ),
        if (scanState.devices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              '发现的设备 (${scanState.devices.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ...scanState.devices.map((device) => ListTile(
              leading: const Icon(Icons.wifi_find),
              title: Text(device.ipAddress),
              subtitle: Text(device.displayName),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () => _addDiscoveredDevice(context, device),
              ),
            )),
        if (scanState.error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(child: Text(scanState.error!)),
                  IconButton(
                    onPressed: () {
                      ref.read(scanProvider.notifier).clearError();
                    },
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 显示扫描选项
  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wifi_find),
              title: const Text('扫描本地网络'),
              onTap: () {
                Navigator.pop(context);
                _startScan();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('刷新设备列表'),
              onTap: () {
                Navigator.pop(context);
                ref.read(deviceProvider.notifier).refresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 开始扫描
  Future<void> _startScan() async {
    await ref.read(scanProvider.notifier).startScan();
  }

  /// 显示添加设备选项
  void _showAddDeviceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddDeviceBottomSheet(),
    );
  }

  /// 添加发现的设备
  Future<void> _addDiscoveredDevice(
    BuildContext context,
    dynamic discoveredDevice,
  ) async {
    // TODO: 实现添加发现的设备到已保存列表
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('功能开发中...')),
    );
  }

  /// 编辑设备
  Future<void> _editDevice(BuildContext context, Device device) async {
    // TODO: 实现编辑设备功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑设备: ${device.name}')),
    );
  }

  /// 确认删除设备
  Future<void> _confirmDeleteDevice(
    BuildContext context,
    Device device,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除设备 "${device.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(deviceProvider.notifier).removeDevice(device.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设备已删除')),
        );
      }
    }
  }
}
