import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:led_control/core/models/device.dart';

/// 设备存储服务
/// 使用 SharedPreferences 持久化设备列表
class DeviceStorage {
  DeviceStorage(this._prefs);

  final SharedPreferences _prefs;
  static const String _devicesKey = 'saved_devices';

  /// 保存设备
  Future<void> saveDevice(Device device) async {
    final devices = await getAllDevices();

    // 查找是否已存在
    final index = devices.indexWhere((d) => d.id == device.id);

    if (index >= 0) {
      // 更新现有设备
      devices[index] = device;
    } else {
      // 添加新设备
      devices.add(device);
    }

    await _saveDevices(devices);
  }

  /// 设置当前选中设备
  Future<void> setSelectedDevice(String id) async {
    final devices = await getAllDevices();
    final updatedDevices = devices
        .map((device) => device.copyWith(isSelected: device.id == id))
        .toList();
    await _saveDevices(updatedDevices);
  }

  /// 获取指定设备
  Future<Device?> getDevice(String id) async {
    final devices = await getAllDevices();
    try {
      return devices.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有设备
  Future<List<Device>> getAllDevices() async {
    final devicesJson = _prefs.getStringList(_devicesKey);
    if (devicesJson == null) return [];

    try {
      return devicesJson.map((json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return Device.fromJson(map);
      }).toList();
    } catch (e) {
      // 如果解析失败，返回空列表
      return [];
    }
  }

  /// 删除设备
  Future<void> deleteDevice(String id) async {
    final devices = await getAllDevices();
    devices.removeWhere((d) => d.id == id);
    await _saveDevices(devices);
  }

  /// 清空所有设备
  Future<void> clear() async {
    await _prefs.remove(_devicesKey);
  }

  /// 检查设备是否存在
  Future<bool> deviceExists(String id) async {
    final device = await getDevice(id);
    return device != null;
  }

  /// 通过 IP 地址查找设备
  Future<Device?> findDeviceByIP(String ipAddress) async {
    final devices = await getAllDevices();
    try {
      return devices.firstWhere((d) => d.ipAddress == ipAddress);
    } catch (e) {
      return null;
    }
  }

  /// 更新设备在线状态
  Future<void> updateDeviceStatus(String id, bool isOnline) async {
    final device = await getDevice(id);
    if (device != null) {
      final updated = device.copyWith(
        isOnline: isOnline,
        lastSeen: DateTime.now(),
      );
      await saveDevice(updated);
    }
  }

  /// 保存设备列表到存储
  Future<void> _saveDevices(List<Device> devices) async {
    final devicesJson = devices.map((device) {
      final json = device.toJson();
      return jsonEncode(json);
    }).toList();

    await _prefs.setStringList(_devicesKey, devicesJson);
  }

  /// 获取设备数量
  Future<int> getDeviceCount() async {
    final devices = await getAllDevices();
    return devices.length;
  }

  /// 批量保存设备
  Future<void> saveDevices(List<Device> devices) async {
    await _saveDevices(devices);
  }
}
