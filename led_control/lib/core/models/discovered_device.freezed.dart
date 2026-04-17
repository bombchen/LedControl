// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discovered_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiscoveredDevice _$DiscoveredDeviceFromJson(Map<String, dynamic> json) {
  return _DiscoveredDevice.fromJson(json);
}

/// @nodoc
mixin _$DiscoveredDevice {
  /// IP 地址
  String get ipAddress => throw _privateConstructorUsedError;

  /// UDP 端口
  int get port => throw _privateConstructorUsedError;

  /// 设备名称（从响应中解析）
  String? get name => throw _privateConstructorUsedError;

  /// 当前灯效
  String? get currentEffect => throw _privateConstructorUsedError;

  /// 当前亮度
  int? get brightness => throw _privateConstructorUsedError;

  /// 响应时间
  DateTime get responseTime => throw _privateConstructorUsedError;

  /// 信号强度（基于响应时间估算）
  int? get signalStrength => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiscoveredDeviceCopyWith<DiscoveredDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoveredDeviceCopyWith<$Res> {
  factory $DiscoveredDeviceCopyWith(
          DiscoveredDevice value, $Res Function(DiscoveredDevice) then) =
      _$DiscoveredDeviceCopyWithImpl<$Res, DiscoveredDevice>;
  @useResult
  $Res call(
      {String ipAddress,
      int port,
      String? name,
      String? currentEffect,
      int? brightness,
      DateTime responseTime,
      int? signalStrength});
}

/// @nodoc
class _$DiscoveredDeviceCopyWithImpl<$Res, $Val extends DiscoveredDevice>
    implements $DiscoveredDeviceCopyWith<$Res> {
  _$DiscoveredDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ipAddress = null,
    Object? port = null,
    Object? name = freezed,
    Object? currentEffect = freezed,
    Object? brightness = freezed,
    Object? responseTime = null,
    Object? signalStrength = freezed,
  }) {
    return _then(_value.copyWith(
      ipAddress: null == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      currentEffect: freezed == currentEffect
          ? _value.currentEffect
          : currentEffect // ignore: cast_nullable_to_non_nullable
              as String?,
      brightness: freezed == brightness
          ? _value.brightness
          : brightness // ignore: cast_nullable_to_non_nullable
              as int?,
      responseTime: null == responseTime
          ? _value.responseTime
          : responseTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      signalStrength: freezed == signalStrength
          ? _value.signalStrength
          : signalStrength // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiscoveredDeviceImplCopyWith<$Res>
    implements $DiscoveredDeviceCopyWith<$Res> {
  factory _$$DiscoveredDeviceImplCopyWith(_$DiscoveredDeviceImpl value,
          $Res Function(_$DiscoveredDeviceImpl) then) =
      __$$DiscoveredDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String ipAddress,
      int port,
      String? name,
      String? currentEffect,
      int? brightness,
      DateTime responseTime,
      int? signalStrength});
}

/// @nodoc
class __$$DiscoveredDeviceImplCopyWithImpl<$Res>
    extends _$DiscoveredDeviceCopyWithImpl<$Res, _$DiscoveredDeviceImpl>
    implements _$$DiscoveredDeviceImplCopyWith<$Res> {
  __$$DiscoveredDeviceImplCopyWithImpl(_$DiscoveredDeviceImpl _value,
      $Res Function(_$DiscoveredDeviceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ipAddress = null,
    Object? port = null,
    Object? name = freezed,
    Object? currentEffect = freezed,
    Object? brightness = freezed,
    Object? responseTime = null,
    Object? signalStrength = freezed,
  }) {
    return _then(_$DiscoveredDeviceImpl(
      ipAddress: null == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      currentEffect: freezed == currentEffect
          ? _value.currentEffect
          : currentEffect // ignore: cast_nullable_to_non_nullable
              as String?,
      brightness: freezed == brightness
          ? _value.brightness
          : brightness // ignore: cast_nullable_to_non_nullable
              as int?,
      responseTime: null == responseTime
          ? _value.responseTime
          : responseTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      signalStrength: freezed == signalStrength
          ? _value.signalStrength
          : signalStrength // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscoveredDeviceImpl extends _DiscoveredDevice {
  const _$DiscoveredDeviceImpl(
      {required this.ipAddress,
      this.port = 8888,
      this.name,
      this.currentEffect,
      this.brightness,
      required this.responseTime,
      this.signalStrength})
      : super._();

  factory _$DiscoveredDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscoveredDeviceImplFromJson(json);

  /// IP 地址
  @override
  final String ipAddress;

  /// UDP 端口
  @override
  @JsonKey()
  final int port;

  /// 设备名称（从响应中解析）
  @override
  final String? name;

  /// 当前灯效
  @override
  final String? currentEffect;

  /// 当前亮度
  @override
  final int? brightness;

  /// 响应时间
  @override
  final DateTime responseTime;

  /// 信号强度（基于响应时间估算）
  @override
  final int? signalStrength;

  @override
  String toString() {
    return 'DiscoveredDevice(ipAddress: $ipAddress, port: $port, name: $name, currentEffect: $currentEffect, brightness: $brightness, responseTime: $responseTime, signalStrength: $signalStrength)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoveredDeviceImpl &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.currentEffect, currentEffect) ||
                other.currentEffect == currentEffect) &&
            (identical(other.brightness, brightness) ||
                other.brightness == brightness) &&
            (identical(other.responseTime, responseTime) ||
                other.responseTime == responseTime) &&
            (identical(other.signalStrength, signalStrength) ||
                other.signalStrength == signalStrength));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, ipAddress, port, name,
      currentEffect, brightness, responseTime, signalStrength);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoveredDeviceImplCopyWith<_$DiscoveredDeviceImpl> get copyWith =>
      __$$DiscoveredDeviceImplCopyWithImpl<_$DiscoveredDeviceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscoveredDeviceImplToJson(
      this,
    );
  }
}

abstract class _DiscoveredDevice extends DiscoveredDevice {
  const factory _DiscoveredDevice(
      {required final String ipAddress,
      final int port,
      final String? name,
      final String? currentEffect,
      final int? brightness,
      required final DateTime responseTime,
      final int? signalStrength}) = _$DiscoveredDeviceImpl;
  const _DiscoveredDevice._() : super._();

  factory _DiscoveredDevice.fromJson(Map<String, dynamic> json) =
      _$DiscoveredDeviceImpl.fromJson;

  @override

  /// IP 地址
  String get ipAddress;
  @override

  /// UDP 端口
  int get port;
  @override

  /// 设备名称（从响应中解析）
  String? get name;
  @override

  /// 当前灯效
  String? get currentEffect;
  @override

  /// 当前亮度
  int? get brightness;
  @override

  /// 响应时间
  DateTime get responseTime;
  @override

  /// 信号强度（基于响应时间估算）
  int? get signalStrength;
  @override
  @JsonKey(ignore: true)
  _$$DiscoveredDeviceImplCopyWith<_$DiscoveredDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
