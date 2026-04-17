import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:led_control/core/providers/scan_provider.dart';
import 'package:led_control/core/network/device_scanner.dart';
import 'package:led_control/core/models/discovered_device.dart';

class MockDeviceScanner extends Mock implements DeviceScanner {}

void main() {
  setUpAll(() {
    // 注册 mocktail 的 fallback 值
    registerFallbackValue(const Duration(seconds: 5));
  });

  group('ScanProvider', () {
    late MockDeviceScanner mockScanner;

    setUp(() {
      mockScanner = MockDeviceScanner();
    });

    test('应该能够初始化扫描状态', () {
      // Arrange & Act
      final container = ProviderContainer(
        overrides: [
          deviceScannerProvider.overrideWithValue(mockScanner),
        ],
      );

      final state = container.read(scanProvider);

      // Assert
      expect(state.isScanning, false);
      expect(state.devices, isEmpty);
      expect(state.error, isNull);
      container.dispose();
    });

    test('应该能够开始扫描', () async {
      // Arrange
      when(() => mockScanner.scan(
        timeout: any(named: 'timeout'),
        onDeviceFound: any(named: 'onDeviceFound'),
      )).thenAnswer((_) async => []);

      // Act
      final container = ProviderContainer(
        overrides: [
          deviceScannerProvider.overrideWithValue(mockScanner),
        ],
      );

      await container.read(scanProvider.notifier).startScan();

      // Assert
      final state = container.read(scanProvider);
      expect(state.isScanning, false); // 扫描完成
      verify(() => mockScanner.scan(
        timeout: any(named: 'timeout'),
        onDeviceFound: any(named: 'onDeviceFound'),
      )).called(1);
      container.dispose();
    });

    test('应该能够发现设备', () async {
      // Arrange
      final discoveredDevices = [
        DiscoveredDevice(
          ipAddress: '192.168.1.100',
          port: 8888,
          responseTime: DateTime.now(),
        ),
      ];

      when(() => mockScanner.scan(
        timeout: any(named: 'timeout'),
        onDeviceFound: any(named: 'onDeviceFound'),
      )).thenAnswer((invocation) async {
        // 调用 onDeviceFound 回调
        final onDeviceFound = invocation.namedArguments[#onDeviceFound] as void Function(DiscoveredDevice);
        for (final device in discoveredDevices) {
          onDeviceFound(device);
        }
        return discoveredDevices;
      });

      // Act
      final container = ProviderContainer(
        overrides: [
          deviceScannerProvider.overrideWithValue(mockScanner),
        ],
      );

      await container.read(scanProvider.notifier).startScan();

      // Assert
      final state = container.read(scanProvider);
      expect(state.devices.length, 1);
      expect(state.devices[0].ipAddress, '192.168.1.100');
      container.dispose();
    });

    test('应该能够处理扫描错误', () async {
      // Arrange
      when(() => mockScanner.scan(
        timeout: any(named: 'timeout'),
        onDeviceFound: any(named: 'onDeviceFound'),
      )).thenThrow(const ScannerException('扫描失败'));

      // Act
      final container = ProviderContainer(
        overrides: [
          deviceScannerProvider.overrideWithValue(mockScanner),
        ],
      );

      await container.read(scanProvider.notifier).startScan();

      // Assert
      final state = container.read(scanProvider);
      expect(state.isScanning, false);
      expect(state.error, '扫描失败');
      container.dispose();
    });

    test('停止非扫描状态不应该调用 dispose', () async {
      // Arrange - 没有正在进行的扫描
      when(() => mockScanner.dispose()).thenAnswer((_) async {});

      // Act
      final container = ProviderContainer(
        overrides: [
          deviceScannerProvider.overrideWithValue(mockScanner),
        ],
      );

      // 直接调用停止扫描（没有正在进行的扫描）
      await container.read(scanProvider.notifier).stopScan();

      // Assert - dispose 不应该被调用
      verifyNever(() => mockScanner.dispose());
      container.dispose();
    });

    test('应该能够清除扫描结果', () async {
      // Arrange
      final discoveredDevices = [
        DiscoveredDevice(
          ipAddress: '192.168.1.100',
          port: 8888,
          responseTime: DateTime.now(),
        ),
      ];

      when(() => mockScanner.scan(
        timeout: any(named: 'timeout'),
        onDeviceFound: any(named: 'onDeviceFound'),
      )).thenAnswer((_) async => discoveredDevices);

      // Act
      final container = ProviderContainer(
        overrides: [
          deviceScannerProvider.overrideWithValue(mockScanner),
        ],
      );

      await container.read(scanProvider.notifier).startScan();
      container.read(scanProvider.notifier).clearResults();

      // Assert
      final state = container.read(scanProvider);
      expect(state.devices, isEmpty);
      expect(state.error, isNull);
      container.dispose();
    });
  });
}
