import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:led_control/core/storage/device_storage.dart';
import 'package:led_control/core/models/device.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'device_provider.g.dart';

/// SharedPreferences Provider
@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

/// 设备存储 Provider
@riverpod
DeviceStorage deviceStorage(DeviceStorageRef ref) {
  final prefsAsyncValue = ref.watch(sharedPreferencesProvider);
  return prefsAsyncValue.when(
    data: (prefs) => DeviceStorage(prefs),
    loading: () => throw UnimplementedError('SharedPreferences not loaded'),
    error: (_, __) => throw UnimplementedError('Failed to load SharedPreferences'),
  );
}

/// 设备列表 Provider
@riverpod
class DeviceList extends _$DeviceList {
  @override
  Future<List<Device>> build() async {
    final storage = ref.read(deviceStorageProvider);
    return await storage.getAllDevices();
  }

  /// 添加设备
  Future<void> addDevice(Device device) async {
    final storage = ref.read(deviceStorageProvider);
    await storage.saveDevice(device);

    // 直接更新状态
    final currentDevices = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentDevices, device]);
  }

  /// 删除设备
  Future<void> removeDevice(String deviceId) async {
    final storage = ref.read(deviceStorageProvider);
    await storage.deleteDevice(deviceId);

    // 直接更新状态
    final currentDevices = state.valueOrNull ?? [];
    state = AsyncValue.data(
      currentDevices.where((d) => d.id != deviceId).toList(),
    );
  }

  /// 更新设备
  Future<void> updateDevice(Device device) async {
    final storage = ref.read(deviceStorageProvider);
    await storage.saveDevice(device);

    // 直接更新状态
    final currentDevices = state.valueOrNull ?? [];
    state = AsyncValue.data(
      currentDevices.map((d) => d.id == device.id ? device : d).toList(),
    );
  }

  /// 通过 ID 获取设备
  Device? getDevice(String deviceId) {
    final currentDevices = state.valueOrNull;
    if (currentDevices == null) return null;

    try {
      return currentDevices.firstWhere((d) => d.id == deviceId);
    } catch (e) {
      return null;
    }
  }

  /// 通过 IP 地址查找设备
  Device? findDeviceByIP(String ipAddress) {
    final currentDevices = state.valueOrNull;
    if (currentDevices == null) return null;

    try {
      return currentDevices.firstWhere((d) => d.ipAddress == ipAddress);
    } catch (e) {
      return null;
    }
  }

  /// 清空所有设备
  Future<void> clearAll() async {
    final storage = ref.read(deviceStorageProvider);
    await storage.clear();

    // 直接更新状态
    state = const AsyncValue.data([]);
  }

  /// 刷新设备列表
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// 便捷访问设备列表的 Provider
final deviceProvider = deviceListProvider;
