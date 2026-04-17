import 'package:freezed_annotation/freezed_annotation.dart';

part 'discovered_device.freezed.dart';
part 'discovered_device.g.dart';

/// 扫描发现的设备信息
@freezed
class DiscoveredDevice with _$DiscoveredDevice {
  const DiscoveredDevice._();

  const factory DiscoveredDevice({
    /// IP 地址
    required String ipAddress,

    /// UDP 端口
    @Default(8888) int port,

    /// 设备名称（从响应中解析）
    String? name,

    /// 当前灯效
    String? currentEffect,

    /// 当前亮度
    int? brightness,

    /// 响应时间
    required DateTime responseTime,

    /// 信号强度（基于响应时间估算）
    int? signalStrength,
  }) = _DiscoveredDevice;

  /// 从 JSON 创建实例
  factory DiscoveredDevice.fromJson(Map<String, dynamic> json) =>
      _$DiscoveredDeviceFromJson(json);

  /// 从状态响应创建设备实例
  factory DiscoveredDevice.fromStatusResponse({
    required String ipAddress,
    required int port,
    required String status,
  }) {
    // 解析状态响应: MODE:effect;BRIGHT:value
    final modeMatch = RegExp(r'MODE:(\w+)').firstMatch(status);
    final brightMatch = RegExp(r'BRIGHT:(\d+)').firstMatch(status);

    return DiscoveredDevice(
      ipAddress: ipAddress,
      port: port,
      currentEffect: modeMatch?.group(1),
      brightness: brightMatch != null ? int.tryParse(brightMatch.group(1)!) : null,
      responseTime: DateTime.now(),
    );
  }

  /// 获取完整的网络地址
  String get networkAddress => '$ipAddress:$port';

  /// 是否有完整信息
  bool get hasCompleteInfo => name != null && currentEffect != null && brightness != null;

  /// 设备显示名称
  String get displayName => name ?? 'LED 设备 ($ipAddress)';
}

/// 扫描结果
class ScanResult {
  const ScanResult({
    required this.devices,
    required this.duration,
  });

  /// 发现的设备列表
  final List<DiscoveredDevice> devices;

  /// 扫描耗时
  final Duration duration;

  /// 是否发现新设备
  bool get hasNewDevices => devices.isNotEmpty;
}
