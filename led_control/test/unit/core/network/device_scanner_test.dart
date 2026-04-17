import 'package:flutter_test/flutter_test.dart';
import 'package:led_control/core/models/discovered_device.dart';

void main() {
  group('DiscoveredDevice', () {
    test('应该能够创建发现的设备实例', () {
      final device = DiscoveredDevice(
        ipAddress: '192.168.1.100',
        port: 8888,
        name: 'LED 设备',
        currentEffect: 'rainbow',
        brightness: 128,
        responseTime: DateTime(2024, 1, 1),
      );

      expect(device.ipAddress, '192.168.1.100');
      expect(device.port, 8888);
      expect(device.name, 'LED 设备');
      expect(device.currentEffect, 'rainbow');
      expect(device.brightness, 128);
    });

    test('应该能够从状态响应创建设备', () {
      final device = DiscoveredDevice.fromStatusResponse(
        ipAddress: '192.168.1.100',
        port: 8888,
        status: 'MODE:rainbow;BRIGHT:128',
      );

      expect(device.ipAddress, '192.168.1.100');
      expect(device.port, 8888);
      expect(device.currentEffect, 'rainbow');
      expect(device.brightness, 128);
    });

    test('应该正确显示网络地址', () {
      final device = DiscoveredDevice(
        ipAddress: '192.168.1.100',
        port: 8888,
        responseTime: DateTime.now(),
      );

      expect(device.networkAddress, '192.168.1.100:8888');
    });

    test('应该正确判断是否有完整信息', () {
      final completeDevice = DiscoveredDevice(
        ipAddress: '192.168.1.100',
        port: 8888,
        name: 'LED 设备',
        currentEffect: 'rainbow',
        brightness: 128,
        responseTime: DateTime.now(),
      );

      final incompleteDevice = DiscoveredDevice(
        ipAddress: '192.168.1.100',
        port: 8888,
        responseTime: DateTime.now(),
      );

      expect(completeDevice.hasCompleteInfo, true);
      expect(incompleteDevice.hasCompleteInfo, false);
    });

    test('应该正确显示设备名称', () {
      final namedDevice = DiscoveredDevice(
        ipAddress: '192.168.1.100',
        port: 8888,
        name: '我的 LED',
        responseTime: DateTime.now(),
      );

      final unnamedDevice = DiscoveredDevice(
        ipAddress: '192.168.1.100',
        port: 8888,
        responseTime: DateTime.now(),
      );

      expect(namedDevice.displayName, '我的 LED');
      expect(unnamedDevice.displayName, 'LED 设备 (192.168.1.100)');
    });

    test('应该能够序列化为 JSON', () {
      final device = DiscoveredDevice(
        ipAddress: '192.168.1.100',
        port: 8888,
        name: 'LED 设备',
        currentEffect: 'rainbow',
        brightness: 128,
        responseTime: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final json = device.toJson();

      expect(json['ipAddress'], '192.168.1.100');
      expect(json['port'], 8888);
      expect(json['name'], 'LED 设备');
      expect(json['currentEffect'], 'rainbow');
      expect(json['brightness'], 128);
    });

    test('应该从 JSON 反序列化', () {
      final json = {
        'ipAddress': '192.168.1.100',
        'port': 8888,
        'name': 'LED 设备',
        'currentEffect': 'rainbow',
        'brightness': 128,
        'responseTime': '2024-01-01T12:00:00.000',
      };

      final device = DiscoveredDevice.fromJson(json);

      expect(device.ipAddress, '192.168.1.100');
      expect(device.port, 8888);
      expect(device.name, 'LED 设备');
      expect(device.currentEffect, 'rainbow');
      expect(device.brightness, 128);
    });
  });
}
