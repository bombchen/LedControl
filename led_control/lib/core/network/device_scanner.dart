import 'dart:async';
import 'dart:io';
import 'package:led_control/core/network/udp_client.dart';
import 'package:led_control/core/models/discovered_device.dart';
import 'package:led_control/core/network/led_protocol.dart';
import 'package:led_control/core/models/network_result.dart';

/// 设备扫描器
/// 用于发现本地网络中的 LED 设备
class DeviceScanner {
  DeviceScanner({UDPClient? client})
      : _client = client ?? UDPClient();

  final UDPClient _client;
  RawDatagramSocket? _scanSocket;
  bool _isScanning = false;

  /// 是否正在扫描
  bool get isScanning => _isScanning;

  /// 扫描本地网络中的设备
  Future<List<DiscoveredDevice>> scan({
    Duration timeout = const Duration(seconds: 5),
    void onDeviceFound(DiscoveredDevice device)?,
  }) async {
    if (_isScanning) {
      throw const ScannerException('扫描正在进行中');
    }

    _isScanning = true;
    final stopwatch = Stopwatch()..start();

    try {
      // 初始化客户端
      if (!_client.isInitialized) {
        await _client.initialize();
      }

      // 创建专用的扫描 socket
      _scanSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _scanSocket!.broadcastEnabled = true;
      _scanSocket!.readEventsEnabled = true;

      // 发送广播查询
      final queryCommand = LEDProtocol.getStatus();
      final data = queryCommand.codeUnits;
      _scanSocket!.send(
        data,
        InternetAddress('255.255.255.255'),
        8888,
      );

      // 收集响应
      final devices = <DiscoveredDevice>[];
      final receivedAddresses = <String>{};

      await for (final event in _scanSocket!) {
        if (event == RawSocketEvent.read) {
          final datagram = _scanSocket!.receive();
          if (datagram != null) {
            final address = datagram.address.address;
            final response = String.fromCharCodes(datagram.data);

            // 避免重复添加同一设备
            if (!receivedAddresses.contains(address)) {
              receivedAddresses.add(address);

              // 解析响应
              final parsed = LEDProtocolParser.parseResponse(response);

              if (parsed.isSuccess && parsed.data != null) {
                final device = DiscoveredDevice.fromStatusResponse(
                  ipAddress: address,
                  port: datagram.port,
                  status: parsed.data!,
                );

                devices.add(device);
                onDeviceFound?.call(device);
              }
            }
          }
        }

        // 超时检查
        if (stopwatch.elapsed >= timeout) {
          break;
        }
      }

      return devices;
    } on SocketException catch (e) {
      throw ScannerException('网络扫描失败: ${e.message}');
    } catch (e) {
      throw ScannerException('扫描出错: $e');
    } finally {
      _isScanning = false;
      _scanSocket?.close();
      _scanSocket = null;
    }
  }

  /// 验证指定 IP 地址的设备
  Future<DiscoveredDevice?> verifyDevice(String ipAddress, {int port = 8888}) async {
    try {
      final result = await _client.sendCommand(
        ipAddress: ipAddress,
        port: port,
        command: LEDProtocol.getStatus(),
        timeout: const Duration(seconds: 3),
      );

      if (result is NetworkSuccess<String>) {
        final parsed = LEDProtocolParser.parseResponse(result.data);

        if (parsed.isSuccess && parsed.data != null) {
          return DiscoveredDevice.fromStatusResponse(
            ipAddress: ipAddress,
            port: port,
            status: parsed.data!,
          );
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    _scanSocket?.close();
    _scanSocket = null;
    await _client.close();
  }
}

/// 扫描器异常
class ScannerException implements Exception {
  const ScannerException(this.message);

  final String message;

  @override
  String toString() => 'ScannerException: $message';
}
