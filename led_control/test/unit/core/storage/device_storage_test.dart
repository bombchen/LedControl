import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:led_control/core/storage/device_storage.dart';
import 'package:led_control/core/models/device.dart';

void main() {
  group('DeviceStorage', () {
    late DeviceStorage storage;

    setUp(() async {
      // 清除 SharedPreferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = DeviceStorage(prefs);
      await storage.clear();
    });

    test('应该能够保存设备', () async {
      final device = Device(
        id: 'test-id',
        name: '测试设备',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      await storage.saveDevice(device);

      final retrieved = await storage.getDevice('test-id');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'test-id');
      expect(retrieved.name, '测试设备');
    });

    test('应该能够获取所有设备', () async {
      final device1 = Device(
        id: 'id1',
        name: '设备1',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      final device2 = Device(
        id: 'id2',
        name: '设备2',
        ipAddress: '192.168.1.101',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: false,
      );

      await storage.saveDevice(device1);
      await storage.saveDevice(device2);

      final devices = await storage.getAllDevices();
      expect(devices.length, 2);
      expect(devices[0].id, 'id1');
      expect(devices[1].id, 'id2');
    });

    test('应该能够删除设备', () async {
      final device = Device(
        id: 'test-id',
        name: '测试设备',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      await storage.saveDevice(device);
      await storage.deleteDevice('test-id');

      final retrieved = await storage.getDevice('test-id');
      expect(retrieved, isNull);
    });

    test('应该能够更新设备', () async {
      final device = Device(
        id: 'test-id',
        name: '原始名称',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      await storage.saveDevice(device);

      final updated = device.copyWith(name: '更新后的名称');
      await storage.saveDevice(updated);

      final retrieved = await storage.getDevice('test-id');
      expect(retrieved!.name, '更新后的名称');
    });

    test('应该能够清空所有设备', () async {
      final device1 = Device(
        id: 'id1',
        name: '设备1',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      final device2 = Device(
        id: 'id2',
        name: '设备2',
        ipAddress: '192.168.1.101',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: false,
      );

      await storage.saveDevice(device1);
      await storage.saveDevice(device2);
      await storage.clear();

      final devices = await storage.getAllDevices();
      expect(devices, isEmpty);
    });

    test('应该能够检查设备是否存在', () async {
      final device = Device(
        id: 'test-id',
        name: '测试设备',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      expect(await storage.deviceExists('test-id'), false);

      await storage.saveDevice(device);
      expect(await storage.deviceExists('test-id'), true);
    });

    test('获取不存在的设备应该返回 null', () async {
      final retrieved = await storage.getDevice('non-existent');
      expect(retrieved, isNull);
    });

    test('应该能够通过 IP 地址查找设备', () async {
      final device = Device(
        id: 'test-id',
        name: '测试设备',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      await storage.saveDevice(device);

      final found = await storage.findDeviceByIP('192.168.1.100');
      expect(found, isNotNull);
      expect(found!.id, 'test-id');

      final notFound = await storage.findDeviceByIP('192.168.1.999');
      expect(notFound, isNull);
    });
  });
}
