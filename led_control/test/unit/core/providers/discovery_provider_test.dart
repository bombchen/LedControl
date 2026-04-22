import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:led_control/core/models/device.dart';
import 'package:led_control/core/providers/device_provider.dart';
import 'package:led_control/core/providers/discovery_provider.dart';
import 'package:led_control/core/storage/device_storage.dart';

class MockDeviceStorage extends Mock implements DeviceStorage {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Device(
        id: 'fallback',
        name: 'fallback',
        ipAddress: '0.0.0.0',
        port: 8888,
        lastSeen: DateTime(2026, 1, 1),
        isOnline: false,
      ),
    );
  });

  group('DeviceDiscovery', () {
    late MockDeviceStorage mockStorage;

    setUp(() {
      mockStorage = MockDeviceStorage();
    });

    test('discovered devices should update stored devices by IP', () async {
      final stored = Device(
        id: 'stored-1',
        name: '客厅灯',
        ipAddress: '192.168.1.50',
        port: 8888,
        lastSeen: DateTime(2026, 4, 21),
        isOnline: false,
      );

      final discovered = Device(
        id: 'scan-1',
        name: '扫描到的灯',
        ipAddress: '192.168.1.50',
        port: 8888,
        lastSeen: DateTime(2026, 4, 21, 12),
        isOnline: true,
      );

      when(() => mockStorage.getAllDevices()).thenAnswer((_) async => [stored]);
      when(() => mockStorage.saveDevice(any())).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async =>
              throw UnimplementedError('should be overridden in tests')),
          deviceStorageProvider.overrideWith((ref) async => mockStorage),
        ],
      );

      await container.read(deviceProvider.future);
      await container.read(deviceDiscoveryProvider.notifier).addDiscoveredDevice(discovered);

      final captured = verify(() => mockStorage.saveDevice(captureAny())).captured.single as Device;
      expect(captured.id, stored.id);
      expect(captured.name, stored.name);
      expect(captured.ipAddress, stored.ipAddress);
      expect(captured.isOnline, isTrue);
      expect(captured.lastSeen, discovered.lastSeen);

      container.dispose();
    });
  });
}
