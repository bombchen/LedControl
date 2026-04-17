import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:led_control/core/network/udp_client.dart';
import 'package:led_control/core/network/led_protocol.dart';
import 'package:led_control/core/models/led_effect.dart';
import 'package:led_control/core/models/network_result.dart';

part 'control_provider.g.dart';

/// UDP 客户端 Provider
@riverpod
UDPClient udpClient(UdpClientRef ref) {
  return UDPClient();
}

/// LED 控制状态
class ControlState {
  const ControlState({
    this.isLoading = false,
    this.lastError,
    this.lastCommandTime,
  });

  final bool isLoading;
  final String? lastError;
  final DateTime? lastCommandTime;

  ControlState copyWith({
    bool? isLoading,
    String? lastError,
    DateTime? lastCommandTime,
  }) {
    return ControlState(
      isLoading: isLoading ?? this.isLoading,
      lastError: lastError ?? this.lastError,
      lastCommandTime: lastCommandTime ?? this.lastCommandTime,
    );
  }
}

/// LED 控制结果
class ControlResult {
  const ControlResult({
    required this.isSuccess,
    this.data,
    this.error,
  });

  final bool isSuccess;
  final String? data;
  final String? error;

  factory ControlResult.success({String? data}) {
    return ControlResult(
      isSuccess: true,
      data: data,
    );
  }

  factory ControlResult.failure(String error) {
    return ControlResult(
      isSuccess: false,
      error: error,
    );
  }
}

/// LED 设备状态
class DeviceStatus {
  const DeviceStatus({
    required this.effect,
    required this.brightness,
  });

  final LEDEffect effect;
  final int brightness;
}

/// LED 控制器 Provider
@riverpod
class LEDControl extends _$LEDControl {
  @override
  ControlState build() {
    return const ControlState();
  }

  /// 设置灯效
  Future<ControlResult> setEffect({
    required String ipAddress,
    required LEDEffect effect,
    int port = 8888,
  }) async {
    state = state.copyWith(isLoading: true, lastError: null);

    try {
      final client = ref.read(udpClientProvider);
      final command = LEDProtocol.setEffect(effect);

      final result = await client.sendCommand(
        ipAddress: ipAddress,
        port: port,
        command: command,
        timeout: const Duration(seconds: 3),
      );

      if (result is NetworkSuccess<String>) {
        final response = LEDProtocolParser.parseResponse(result.data);

        if (response.isSuccess) {
          state = state.copyWith(
            isLoading: false,
            lastCommandTime: DateTime.now(),
          );
          return ControlResult.success(data: response.data);
        } else {
          state = state.copyWith(
            isLoading: false,
            lastError: response.error,
          );
          return ControlResult.failure(response.error ?? '未知错误');
        }
      } else {
        final error = result as NetworkError<String>;
        state = state.copyWith(
          isLoading: false,
          lastError: error.message,
        );
        return ControlResult.failure(error.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e.toString(),
      );
      return ControlResult.failure(e.toString());
    }
  }

  /// 设置亮度
  Future<ControlResult> setBrightness({
    required String ipAddress,
    required int brightness,
    int port = 8888,
  }) async {
    if (brightness < 0 || brightness > 255) {
      return ControlResult.failure('亮度值必须在 0-255 范围内');
    }

    state = state.copyWith(isLoading: true, lastError: null);

    try {
      final client = ref.read(udpClientProvider);
      final command = LEDProtocol.setBrightness(brightness);

      final result = await client.sendCommand(
        ipAddress: ipAddress,
        port: port,
        command: command,
        timeout: const Duration(seconds: 3),
      );

      if (result is NetworkSuccess<String>) {
        final response = LEDProtocolParser.parseResponse(result.data);

        if (response.isSuccess) {
          state = state.copyWith(
            isLoading: false,
            lastCommandTime: DateTime.now(),
          );
          return ControlResult.success(data: response.data);
        } else {
          state = state.copyWith(
            isLoading: false,
            lastError: response.error,
          );
          return ControlResult.failure(response.error ?? '未知错误');
        }
      } else {
        final error = result as NetworkError<String>;
        state = state.copyWith(
          isLoading: false,
          lastError: error.message,
        );
        return ControlResult.failure(error.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e.toString(),
      );
      return ControlResult.failure(e.toString());
    }
  }

  /// 切换到下一个灯效
  Future<ControlResult> nextEffect(
    String ipAddress, {
    int port = 8888,
  }) async {
    state = state.copyWith(isLoading: true, lastError: null);

    try {
      final client = ref.read(udpClientProvider);
      final command = LEDProtocol.nextEffect();

      final result = await client.sendCommand(
        ipAddress: ipAddress,
        port: port,
        command: command,
        timeout: const Duration(seconds: 3),
      );

      if (result is NetworkSuccess<String>) {
        final response = LEDProtocolParser.parseResponse(result.data);

        if (response.isSuccess) {
          state = state.copyWith(
            isLoading: false,
            lastCommandTime: DateTime.now(),
          );
          return ControlResult.success(data: response.data);
        } else {
          state = state.copyWith(
            isLoading: false,
            lastError: response.error,
          );
          return ControlResult.failure(response.error ?? '未知错误');
        }
      } else {
        final error = result as NetworkError<String>;
        state = state.copyWith(
          isLoading: false,
          lastError: error.message,
        );
        return ControlResult.failure(error.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e.toString(),
      );
      return ControlResult.failure(e.toString());
    }
  }

  /// 切换到上一个灯效
  Future<ControlResult> previousEffect(
    String ipAddress, {
    int port = 8888,
  }) async {
    state = state.copyWith(isLoading: true, lastError: null);

    try {
      final client = ref.read(udpClientProvider);
      final command = LEDProtocol.previousEffect();

      final result = await client.sendCommand(
        ipAddress: ipAddress,
        port: port,
        command: command,
        timeout: const Duration(seconds: 3),
      );

      if (result is NetworkSuccess<String>) {
        final response = LEDProtocolParser.parseResponse(result.data);

        if (response.isSuccess) {
          state = state.copyWith(
            isLoading: false,
            lastCommandTime: DateTime.now(),
          );
          return ControlResult.success(data: response.data);
        } else {
          state = state.copyWith(
            isLoading: false,
            lastError: response.error,
          );
          return ControlResult.failure(response.error ?? '未知错误');
        }
      } else {
        final error = result as NetworkError<String>;
        state = state.copyWith(
          isLoading: false,
          lastError: error.message,
        );
        return ControlResult.failure(error.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e.toString(),
      );
      return ControlResult.failure(e.toString());
    }
  }

  /// 查询设备状态
  Future<ControlResult> getStatus(
    String ipAddress, {
    int port = 8888,
  }) async {
    state = state.copyWith(isLoading: true, lastError: null);

    try {
      final client = ref.read(udpClientProvider);
      final command = LEDProtocol.getStatus();

      final result = await client.sendCommand(
        ipAddress: ipAddress,
        port: port,
        command: command,
        timeout: const Duration(seconds: 3),
      );

      if (result is NetworkSuccess<String>) {
        final response = LEDProtocolParser.parseResponse(result.data);

        if (response.isSuccess && response.data != null) {
          final status = response.asStatus;
          if (status != null) {
            state = state.copyWith(
              isLoading: false,
              lastCommandTime: DateTime.now(),
            );
            // 返回包含状态信息的结果
            return ControlResult.success(
              data: 'MODE:${status.effect.commandValue};BRIGHT:${status.brightness}',
            );
          }
        }

        state = state.copyWith(
          isLoading: false,
          lastError: response.error,
        );
        return ControlResult.failure(response.error ?? '无法解析设备状态');
      } else {
        final error = result as NetworkError<String>;
        state = state.copyWith(
          isLoading: false,
          lastError: error.message,
        );
        return ControlResult.failure(error.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e.toString(),
      );
      return ControlResult.failure(e.toString());
    }
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(lastError: null);
  }
}

/// 便捷访问控制器的 Provider
final controlProvider = lEDControlProvider;
