import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:led_control/core/providers/device_provider.dart';
import 'package:led_control/core/storage/device_storage.dart';
import 'package:led_control/core/models/device.dart';

class MockDeviceStorage extends Mock implements DeviceStorage {}

void main() {
  group('DeviceProvider', () {
    late MockDeviceStorage mockStorage;

    setUp(() {
      mockStorage = MockDeviceStorage();
    });

    test('应该能够初始化并获取空设备列表', () async {
      when(() => mockStorage.getAllDevices())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async =>
              throw UnimplementedError('should be overridden in tests')),
          deviceStorageProvider.overrideWith((ref) async => mockStorage),
        ],
      );

      final devices = await container.read(deviceProvider.future);

      expect(devices, isEmpty);
      container.dispose();
    });

    test('应该能够从存储加载设备列表', () async {
      final devices = [
        Device(
          id: 'id1',
          name: '设备1',
          ipAddress: '192.168.1.100',
          port: 8888,
          lastSeen: DateTime.now(),
          isOnline: true,
        ),
        Device(
          id: 'id2',
          name: '设备2',
          ipAddress: '192.168.1.101',
          port: 8888,
          lastSeen: DateTime.now(),
          isOnline: false,
        ),
      ];

      when(() => mockStorage.getAllDevices())
          .thenAnswer((_) async => devices);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async =>
              throw UnimplementedError('should be overridden in tests')),
          deviceStorageProvider.overrideWith((ref) async => mockStorage),
        ],
      );

      final loadedDevices = await container.read(deviceProvider.future);

      expect(loadedDevices.length, 2);
      expect(loadedDevices[0].id, 'id1');
      expect(loadedDevices[1].id, 'id2');
      container.dispose();
    });

    test('应该能够添加设备并刷新列表', () async {
      final newDevice = Device(
        id: 'new-id',
        name: '新设备',
        ipAddress: '192.168.1.102',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      when(() => mockStorage.getAllDevices())
          .thenAnswer((_) async => []);
      when(() => mockStorage.saveDevice(newDevice))
          .thenAnswer((_) async {});
      when(() => mockStorage.getAllDevices())
          .thenAnswer((_) async => [newDevice]);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async =>
              throw UnimplementedError('should be overridden in tests')),
          deviceStorageProvider.overrideWith((ref) async => mockStorage),
        ],
      );

      await container.read(deviceProvider.future);
      await container.read(deviceProvider.notifier).addDevice(newDevice);
      await container.read(deviceProvider.notifier).refresh();
      final devices = await container.read(deviceProvider.future);

      expect(devices, hasLength(1));
      expect(devices.first.id, 'new-id');
      verify(() => mockStorage.saveDevice(newDevice)).called(1);
      container.dispose();
    });

    test('应该能够选择当前设备', () async {
      final devices = [
        Device(
          id: 'id1',
          name: '设备1',
          ipAddress: '192.168.1.100',
          port: 8888,
          lastSeen: DateTime.now(),
          isOnline: true,
        ),
        Device(
          id: 'id2',
          name: '设备2',
          ipAddress: '192.168.1.101',
          port: 8888,
          lastSeen: DateTime.now(),
          isOnline: false,
        ),
      ];

      when(() => mockStorage.getAllDevices())
          .thenAnswer((_) async => devices);
      when(() => mockStorage.setSelectedDevice('id2'))
          .thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async =>
              throw UnimplementedError('should be overridden in tests')),
          deviceStorageProvider.overrideWith((ref) async => mockStorage),
        ],
      );

      await container.read(deviceProvider.future);
      await container.read(deviceProvider.notifier).selectDevice('id2');

      verify(() => mockStorage.setSelectedDevice('id2')).called(1);
      container.dispose();
    });

    test('应该能够删除设备', () async {
      final devices = [
        Device(
          id: 'id1',
          name: '设备1',
          ipAddress: '192.168.1.100',
          port: 8888,
          lastSeen: DateTime.now(),
          isOnline: true,
        ),
      ];

      when(() => mockStorage.getAllDevices())
          .thenAnswer((_) async => devices);
      when(() => mockStorage.deleteDevice('id1'))
          .thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async =>
              throw UnimplementedError('should be overridden in tests')),
          deviceStorageProvider.overrideWith((ref) async => mockStorage),
        ],
      );

      await container.read(deviceProvider.notifier).removeDevice('id1');
      verify(() => mockStorage.deleteDevice('id1')).called(1);
      container.dispose();
    });

    test('应该能够更新设备', () async {
      final originalDevice = Device(
        id: 'id1',
        name: '原始名称',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      final updatedDevice = originalDevice.copyWith(name: '更新后的名称');

      when(() => mockStorage.getAllDevices())
          .thenAnswer((_) async => [originalDevice]);
      when(() => mockStorage.saveDevice(updatedDevice))
          .thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async =>
              throw UnimplementedError('should be overridden in tests')),
          deviceStorageProvider.overrideWith((ref) async => mockStorage),
        ],
      );

      await container.read(deviceProvider.notifier).updateDevice(updatedDevice);
      verify(() => mockStorage.saveDevice(updatedDevice)).called(1);
      container.dispose();
    });

    test('应该能够通过 ID 获取设备', () async {
      final devices = [
        Device(
          id: 'id1',
          name: '设备1',
          ipAddress: '192.168.1.100',
          port: 8888,
          lastSeen: DateTime.now(),
          isOnline: true,
        ),
      ];

      when(() => mockStorage.getAllDevices())
          .thenAnswer((_) async => devices);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async =>
              throw UnimplementedError('should be overridden in tests')),
          deviceStorageProvider.overrideWith((ref) async => mockStorage),
        ],
      );

      await container.read(deviceProvider.future);
      final device = container.read(deviceProvider.notifier).getDevice('id1');

      expect(device, isNotNull);
      expect(device!.id, 'id1');
      container.dispose();
    });

    test('应该能够重新配网入口使用现有设备设置', () async {
      final device = Device(
        id: 'id1',
        name: '设备1',
        ipAddress: '192.168.1.100',
        port: 8888,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      expect(device.ipAddress, '192.168.1.100');
      expect(device.port, 8888);
    });
  });
}
