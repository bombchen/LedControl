import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:led_control/core/models/device.dart';
import 'package:led_control/core/storage/device_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'device_provider.g.dart';

/// SharedPreferences Provider
@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return SharedPreferences.getInstance();
}

/// 设备存储 Provider
@riverpod
Future<DeviceStorage> deviceStorage(DeviceStorageRef ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return DeviceStorage(prefs);
}

/// 设备列表 Provider
@riverpod
class DeviceList extends _$DeviceList {
  @override
  Future<List<Device>> build() async {
    final storage = await ref.watch(deviceStorageProvider.future);
    return storage.getAllDevices();
  }

  /// 添加设备
  Future<void> addDevice(Device device) async {
    final storage = await ref.read(deviceStorageProvider.future);
    await storage.saveDevice(device);
    ref.invalidateSelf();
  }

  /// 选择当前设备
  Future<void> selectDevice(String deviceId) async {
    final storage = await ref.read(deviceStorageProvider.future);
    await storage.setSelectedDevice(deviceId);
    ref.invalidateSelf();
  }

  /// 删除设备
  Future<void> removeDevice(String deviceId) async {
    final storage = await ref.read(deviceStorageProvider.future);
    await storage.deleteDevice(deviceId);
    ref.invalidateSelf();
  }

  /// 更新设备
  Future<void> updateDevice(Device device) async {
    final storage = await ref.read(deviceStorageProvider.future);
    await storage.saveDevice(device);
    ref.invalidateSelf();
  }

  /// 发现流程写入或更新设备
  Future<void> updateOrAddDiscoveredDevice(Device device) async {
    final storage = await ref.read(deviceStorageProvider.future);
    await storage.saveDevice(device);
    ref.invalidateSelf();
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
    final storage = await ref.read(deviceStorageProvider.future);
    await storage.clear();
    ref.invalidateSelf();
  }

  /// 刷新设备列表
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// 便捷访问设备列表的 Provider
final deviceProvider = deviceListProvider;
