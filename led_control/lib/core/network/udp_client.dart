import 'dart:io';
import 'dart:async';
import 'package:led_control/core/models/network_result.dart';

/// UDP 客户端
class UDPClient {
  UDPClient();

  RawDatagramSocket? _socket;
  bool _isInitialized = false;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化 UDP 客户端
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _isInitialized = true;
      _socket!.broadcastEnabled = true;
      _socket!.readEventsEnabled = true;
    } catch (e) {
      throw UDPClientException('初始化 UDP 客户端失败: $e');
    }
  }

  /// 发送命令并等待响应
  Future<NetworkResult<String>> sendCommand({
    required String ipAddress,
    required int port,
    required String command,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final data = command.codeUnits;
      _socket!.send(data, InternetAddress(ipAddress), port);

      final response = await _waitForResponse(timeout);

      if (response != null) {
        return NetworkSuccess(response);
      } else {
        return const NetworkError(
          '请求超时',
          NetworkErrorType.timeout,
        );
      }
    } on SocketException catch (e) {
      return NetworkError(
        '网络连接失败: ${e.message}',
        NetworkErrorType.connectionFailed,
      );
    } on TimeoutException {
      return const NetworkError(
        '请求超时',
        NetworkErrorType.timeout,
      );
    } catch (e) {
      return NetworkError(
        '未知错误: $e',
        NetworkErrorType.unknown,
      );
    }
  }

  /// 等待响应数据
  Future<String?> _waitForResponse(Duration timeout) async {
    late StreamSubscription<RawSocketEvent> subscription;
    String? response;

    final completer = Completer<String?>();

    subscription = _socket!.listen((event) {
      final datagram = _socket!.receive();
      if (datagram != null) {
        response = String.fromCharCodes(datagram!.data);
        completer.complete(response);
        subscription.cancel();
      }
    });

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.complete(null);
      }
    });

    return completer.future;
  }

  /// 发送命令（不等待响应）
  Future<void> send({
    required String ipAddress,
    required int port,
    required String command,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final data = command.codeUnits;
    _socket!.send(data, InternetAddress(ipAddress), port);
  }

  /// 关闭 UDP 客户端
  Future<void> close() async {
    if (_isInitialized) {
      _socket!.close();
      _isInitialized = false;
    }
  }
}

/// UDP 客户端异常
class UDPClientException implements Exception {
  const UDPClientException(this.message);

  final String message;

  @override
  String toString() => 'UDPClientException: $message';
}
