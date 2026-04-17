import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:led_control/core/providers/control_provider.dart';
import 'package:led_control/core/network/udp_client.dart';
import 'package:led_control/core/network/led_protocol.dart';
import 'package:led_control/core/models/led_effect.dart';
import 'package:led_control/core/models/network_result.dart';

class MockUDPClient extends Mock implements UDPClient {}

void main() {
  setUpAll(() {
    // 注册 mocktail 的 fallback 值
    registerFallbackValue(const Duration(seconds: 3));
  });

  group('ControlProvider', () {
    late MockUDPClient mockClient;

    setUp(() {
      mockClient = MockUDPClient();
    });

    test('应该能够设置灯效', () async {
      // Arrange
      final effect = LEDEffect.rainbow;
      final successResult = NetworkSuccess('OK:rainbow');

      when(() => mockClient.sendCommand(
        ipAddress: any(named: 'ipAddress'),
        port: any(named: 'port'),
        command: any(named: 'command'),
        timeout: any(named: 'timeout'),
      )).thenAnswer((_) async => successResult);

      // Act
      final container = ProviderContainer(
        overrides: [
          udpClientProvider.overrideWithValue(mockClient),
        ],
      );

      final result = await container.read(
        controlProvider.notifier
      ).setEffect(
        ipAddress: '192.168.1.100',
        effect: effect,
      );

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockClient.sendCommand(
        ipAddress: '192.168.1.100',
        port: 8888,
        command: 'mode:rainbow',
        timeout: const Duration(seconds: 3),
      )).called(1);
      container.dispose();
    });

    test('应该能够设置亮度', () async {
      // Arrange
      final successResult = NetworkSuccess('OK:brightness');

      when(() => mockClient.sendCommand(
        ipAddress: any(named: 'ipAddress'),
        port: any(named: 'port'),
        command: any(named: 'command'),
        timeout: any(named: 'timeout'),
      )).thenAnswer((_) async => successResult);

      // Act
      final container = ProviderContainer(
        overrides: [
          udpClientProvider.overrideWithValue(mockClient),
        ],
      );

      final result = await container.read(
        controlProvider.notifier
      ).setBrightness(
        ipAddress: '192.168.1.100',
        brightness: 128,
      );

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockClient.sendCommand(
        ipAddress: '192.168.1.100',
        port: 8888,
        command: 'bright:128',
        timeout: const Duration(seconds: 3),
      )).called(1);
      container.dispose();
    });

    test('应该能够切换到下一个灯效', () async {
      // Arrange
      final successResult = NetworkSuccess('OK:next');

      when(() => mockClient.sendCommand(
        ipAddress: any(named: 'ipAddress'),
        port: any(named: 'port'),
        command: any(named: 'command'),
        timeout: any(named: 'timeout'),
      )).thenAnswer((_) async => successResult);

      // Act
      final container = ProviderContainer(
        overrides: [
          udpClientProvider.overrideWithValue(mockClient),
        ],
      );

      final result = await container.read(
        controlProvider.notifier
      ).nextEffect('192.168.1.100');

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockClient.sendCommand(
        ipAddress: '192.168.1.100',
        port: 8888,
        command: 'mode:next',
        timeout: const Duration(seconds: 3),
      )).called(1);
      container.dispose();
    });

    test('应该能够切换到上一个灯效', () async {
      // Arrange
      final successResult = NetworkSuccess('OK:prev');

      when(() => mockClient.sendCommand(
        ipAddress: any(named: 'ipAddress'),
        port: any(named: 'port'),
        command: any(named: 'command'),
        timeout: any(named: 'timeout'),
      )).thenAnswer((_) async => successResult);

      // Act
      final container = ProviderContainer(
        overrides: [
          udpClientProvider.overrideWithValue(mockClient),
        ],
      );

      final result = await container.read(
        controlProvider.notifier
      ).previousEffect('192.168.1.100');

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockClient.sendCommand(
        ipAddress: '192.168.1.100',
        port: 8888,
        command: 'mode:prev',
        timeout: const Duration(seconds: 3),
      )).called(1);
      container.dispose();
    });

    test('应该能够查询设备状态', () async {
      // Arrange
      final successResult = NetworkSuccess('MODE:rainbow;BRIGHT:128');

      when(() => mockClient.sendCommand(
        ipAddress: any(named: 'ipAddress'),
        port: any(named: 'port'),
        command: any(named: 'command'),
        timeout: any(named: 'timeout'),
      )).thenAnswer((_) async => successResult);

      // Act
      final container = ProviderContainer(
        overrides: [
          udpClientProvider.overrideWithValue(mockClient),
        ],
      );

      final result = await container.read(
        controlProvider.notifier
      ).getStatus('192.168.1.100');

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, contains('MODE:rainbow'));
      expect(result.data, contains('BRIGHT:128'));
      verify(() => mockClient.sendCommand(
        ipAddress: '192.168.1.100',
        port: 8888,
        command: 'status',
        timeout: const Duration(seconds: 3),
      )).called(1);
      container.dispose();
    });

    test('应该能够处理网络错误', () async {
      // Arrange
      final errorResult = NetworkError<String>(
        '连接失败',
        NetworkErrorType.connectionFailed,
      );

      when(() => mockClient.sendCommand(
        ipAddress: any(named: 'ipAddress'),
        port: any(named: 'port'),
        command: any(named: 'command'),
        timeout: any(named: 'timeout'),
      )).thenAnswer((_) async => errorResult);

      // Act
      final container = ProviderContainer(
        overrides: [
          udpClientProvider.overrideWithValue(mockClient),
        ],
      );

      final result = await container.read(
        controlProvider.notifier
      ).setEffect(
        ipAddress: '192.168.1.100',
        effect: LEDEffect.rainbow,
      );

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, '连接失败');
      container.dispose();
    });

    test('验证亮度值范围', () {
      // 测试亮度值边界
      expect(() => LEDProtocol.setBrightness(-1), throwsArgumentError);
      expect(() => LEDProtocol.setBrightness(256), throwsArgumentError);

      // 测试有效亮度值
      expect(() => LEDProtocol.setBrightness(0), returnsNormally);
      expect(() => LEDProtocol.setBrightness(255), returnsNormally);
    });
  });
}
