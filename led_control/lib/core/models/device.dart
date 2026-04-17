import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';
part 'device.g.dart';

/// LED 设备数据模型
@freezed
class Device with _$Device {
  const Device._();

  const factory Device({
    /// 唯一标识符 (UUID)
    required String id,

    /// 用户自定义的设备名称
    required String name,

    /// IP 地址
    required String ipAddress,

    /// UDP 端口（默认 8888）
    @Default(8888) int port,

    /// 最后在线时间
    required DateTime lastSeen,

    /// 是否在线
    @Default(false) bool isOnline,
  }) = _Device;

  /// 从 JSON 创建设备实例
  factory Device.fromJson(Map<String, dynamic> json) =>
      _$DeviceFromJson(json);

  /// 设备连接状态
  bool get isConnected => isOnline;

  /// 状态文本显示
  String get statusText => isOnline ? '在线' : '离线';

  /// 获取完整的网络地址
  String get networkAddress => '$ipAddress:$port';
}
