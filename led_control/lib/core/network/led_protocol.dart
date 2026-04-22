import 'package:led_control/core/models/device.dart';
import 'package:led_control/core/models/led_effect.dart';

/// LED 设备通信协议
class LEDProtocol {
  LEDProtocol._();

  // ========== 控制命令 (UDP 8888) ==========

  /// 设置灯效命令
  /// 格式: mode:effect
  static String setEffect(LEDEffect effect) {
    return 'mode:${effect.commandValue}';
  }

  /// 下一个灯效命令
  /// 格式: mode:next
  static String nextEffect() {
    return 'mode:next';
  }

  /// 上一个灯效命令
  /// 格式: mode:prev
  static String previousEffect() {
    return 'mode:prev';
  }

  /// 设置亮度命令
  /// 格式: bright:value (0-255)
  static String setBrightness(int value) {
    if (value < 0 || value > 255) {
      throw ArgumentError('亮度值必须在 0-255 范围内');
    }
    return 'bright:$value';
  }

  /// 查询状态命令
  /// 格式: status
  static String getStatus() {
    return 'status';
  }

  // ========== 配置命令 (UDP 8889) ==========

  /// WiFi 配置命令
  /// 格式: config:SSID:PASSWORD
  static String configWiFi(String ssid, String password) {
    return 'config:$ssid:$password';
  }

  /// 扫描网络命令
  /// 格式: list
  static String listNetworks() {
    return 'list';
  }
}

/// 协议响应结果
class ProtocolResponse {
  const ProtocolResponse({
    required this.isSuccess,
    this.data,
    this.error,
  });

  final bool isSuccess;
  final String? data;
  final String? error;

  /// 解析为状态信息（如果响应是状态格式）
  DeviceStatus? get asStatus {
    if (!isSuccess || data == null) return null;

    // 状态格式: MODE:effect;BRIGHT:value
    final modeMatch = RegExp(r'MODE:(\w+)').firstMatch(data!);
    final brightMatch = RegExp(r'BRIGHT:(\d+)').firstMatch(data!);

    if (modeMatch != null && brightMatch != null) {
      return DeviceStatus(
        effect: LEDEffect.fromCommandValue(modeMatch.group(1)!),
        brightness: int.parse(brightMatch.group(1)!),
      );
    }
    return null;
  }
}

/// LED 协议响应解析器
class LEDProtocolParser {
  LEDProtocolParser._();

  /// 解析设备响应
  static ProtocolResponse parseResponse(String response) {
    if (response.isEmpty) {
      return const ProtocolResponse(
        isSuccess: false,
        error: '空响应',
      );
    }

    // 错误响应: ERROR:message
    if (response.startsWith('ERROR:')) {
      return ProtocolResponse(
        isSuccess: false,
        error: response.substring(6),
      );
    }

    // 成功响应: OK:data 或 OK!message
    if (response.startsWith('OK:')) {
      return ProtocolResponse(
        isSuccess: true,
        data: response.substring(3),
      );
    }

    if (response.startsWith('OK!')) {
      return ProtocolResponse(
        isSuccess: true,
        data: response.substring(3),
      );
    }

    // 状态响应: MODE:effect;BRIGHT:value
    // 直接返回成功，data包含完整响应字符串供asStatus解析
    if (response.contains('MODE:') && response.contains('BRIGHT:')) {
      return ProtocolResponse(
        isSuccess: true,
        data: response,
      );
    }

    // 未知格式
    return ProtocolResponse(
      isSuccess: false,
      error: '未知响应格式: $response',
    );
  }
}
