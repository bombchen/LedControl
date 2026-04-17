import 'package:flutter_test/flutter_test.dart';
import 'package:led_control/core/models/led_effect.dart';
import 'package:led_control/core/network/led_protocol.dart';

void main() {
  group('LEDProtocol', () {
    group('控制命令', () {
      test('应该生成设置效果命令', () {
        final cmd = LEDProtocol.setEffect(LEDEffect.rainbow);
        expect(cmd, 'mode:rainbow');
      });

      test('应该生成下一个效果命令', () {
        final cmd = LEDProtocol.nextEffect();
        expect(cmd, 'mode:next');
      });

      test('应该生成上一个效果命令', () {
        final cmd = LEDProtocol.previousEffect();
        expect(cmd, 'mode:prev');
      });

      test('应该生成设置亮度命令', () {
        final cmd = LEDProtocol.setBrightness(180);
        expect(cmd, 'bright:180');
      });

      test('应该生成查询状态命令', () {
        final cmd = LEDProtocol.getStatus();
        expect(cmd, 'status');
      });

      test('亮度值应该在有效范围内', () {
        expect(() => LEDProtocol.setBrightness(-1), throwsArgumentError);
        expect(() => LEDProtocol.setBrightness(256), throwsArgumentError);
        expect(() => LEDProtocol.setBrightness(0), returnsNormally);
        expect(() => LEDProtocol.setBrightness(255), returnsNormally);
      });
    });

    group('配置命令', () {
      test('应该生成 WiFi 配置命令', () {
        final cmd = LEDProtocol.configWiFi('MyWiFi', 'password123');
        expect(cmd, 'config:MyWiFi:password123');
      });

      test('应该生成扫描网络命令', () {
        final cmd = LEDProtocol.listNetworks();
        expect(cmd, 'list');
      });
    });

    group('响应解析', () {
      test('应该解析成功响应', () {
        final result = LEDProtocolParser.parseResponse('OK:rainbow');
        expect(result.isSuccess, true);
        expect(result.data, 'rainbow');
        expect(result.error, isNull);
      });

      test('应该解析重启动响应', () {
        final result = LEDProtocolParser.parseResponse('OK!Rebooting...');
        expect(result.isSuccess, true);
        expect(result.data, 'Rebooting...');
      });

      test('应该解析状态响应', () {
        final result = LEDProtocolParser.parseResponse('MODE:rainbow;BRIGHT:180');
        expect(result.isSuccess, true);

        final status = result.asStatus;
        expect(status, isNotNull);
        expect(status?.effect, LEDEffect.rainbow);
        expect(status?.brightness, 180);
      });

      test('应该解析错误响应', () {
        final result = LEDProtocolParser.parseResponse('ERROR:Invalid command');
        expect(result.isSuccess, false);
        expect(result.data, isNull);
        expect(result.error, 'Invalid command');
      });

      test('应该处理空响应', () {
        final result = LEDProtocolParser.parseResponse('');
        expect(result.isSuccess, false);
        expect(result.error, isNotNull);
      });

      test('应该处理未知格式响应', () {
        final result = LEDProtocolParser.parseResponse('unknown format');
        expect(result.isSuccess, false);
      });
    });
  });
}
