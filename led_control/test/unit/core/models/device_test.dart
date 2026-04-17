import 'package:flutter_test/flutter_test.dart';
import 'package:led_control/core/models/device.dart';

void main() {
  group('Device', () {
    test('应该创建设备实例', () {
      final device = Device(
        id: 'test-id',
        name: '测试设备',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime(2024, 1, 1),
        isOnline: true,
      );

      expect(device.id, 'test-id');
      expect(device.name, '测试设备');
      expect(device.ipAddress, '192.168.1.100');
      expect(device.port, 8888);
      expect(device.lastSeen, DateTime(2024, 1, 1));
      expect(device.isOnline, true);
    });

    test('应该支持拷贝并修改字段', () {
      final device = Device(
        id: 'test-id',
        name: '测试设备',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime(2024, 1, 1),
        isOnline: false,
      );

      final updated = device.copyWith(
        name: '更新后的设备',
        isOnline: true,
      );

      expect(updated.id, 'test-id'); // 未改变
      expect(updated.name, '更新后的设备');
      expect(updated.ipAddress, '192.168.1.100'); // 未改变
      expect(updated.isOnline, true);
    });

    test('应该序列化为 JSON', () {
      final device = Device(
        id: 'test-id',
        name: '测试设备',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime(2024, 1, 1, 12, 0, 0),
        isOnline: true,
      );

      final json = device.toJson();

      expect(json['id'], 'test-id');
      expect(json['name'], '测试设备');
      expect(json['ipAddress'], '192.168.1.100');
      expect(json['port'], 8888);
      expect(json['lastSeen'], '2024-01-01T12:00:00.000');
      expect(json['isOnline'], true);
    });

    test('应该从 JSON 反序列化', () {
      final json = {
        'id': 'test-id',
        'name': '测试设备',
        'ipAddress': '192.168.1.100',
        'port': 8888,
        'lastSeen': '2024-01-01T12:00:00.000',
        'isOnline': true,
      };

      final device = Device.fromJson(json);

      expect(device.id, 'test-id');
      expect(device.name, '测试设备');
      expect(device.ipAddress, '192.168.1.100');
      expect(device.port, 8888);
      expect(device.lastSeen, DateTime(2024, 1, 1, 12, 0, 0));
      expect(device.isOnline, true);
    });

    test('序列化和反序列化应该保持数据一致', () {
      final original = Device(
        id: 'test-id',
        name: '测试设备',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime(2024, 1, 1, 12, 30, 45),
        isOnline: true,
      );

      final json = original.toJson();
      final restored = Device.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.ipAddress, original.ipAddress);
      expect(restored.port, original.port);
      expect(restored.lastSeen, original.lastSeen);
      expect(restored.isOnline, original.isOnline);
    });

    test('离线设备应该有正确的状态显示', () {
      final device = Device(
        id: 'test-id',
        name: '离线设备',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime(2024, 1, 1),
        isOnline: false,
      );

      expect(device.statusText, '离线');
      expect(device.isConnected, false);
    });

    test('在线设备应该有正确的状态显示', () {
      final device = Device(
        id: 'test-id',
        name: '在线设备',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      expect(device.statusText, '在线');
      expect(device.isConnected, true);
    });
  });
}
