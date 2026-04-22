// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Device _$DeviceFromJson(Map<String, dynamic> json) {
  return _Device.fromJson(json);
}

/// @nodoc
mixin _$Device {
  /// 唯一标识符 (UUID)
  String get id => throw _privateConstructorUsedError;

  /// 用户自定义的设备名称
  String get name => throw _privateConstructorUsedError;

  /// IP 地址
  String get ipAddress => throw _privateConstructorUsedError;

  /// 是否为当前选中设备
  bool get isSelected => throw _privateConstructorUsedError;

  /// UDP 端口（默认 8888）
  int get port => throw _privateConstructorUsedError;

  /// 最后在线时间
  DateTime get lastSeen => throw _privateConstructorUsedError;

  /// 是否在线
  bool get isOnline => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeviceCopyWith<Device> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceCopyWith<$Res> {
  factory $DeviceCopyWith(Device value, $Res Function(Device) then) =
      _$DeviceCopyWithImpl<$Res, Device>;
  @useResult
  $Res call(
      {String id,
      String name,
      String ipAddress,
      bool isSelected,
      int port,
      DateTime lastSeen,
      bool isOnline});
}

/// @nodoc
class _$DeviceCopyWithImpl<$Res, $Val extends Device>
    implements $DeviceCopyWith<$Res> {
  _$DeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ipAddress = null,
    Object? isSelected = null,
    Object? port = null,
    Object? lastSeen = null,
    Object? isOnline = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: null == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      lastSeen: null == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceImplCopyWith<$Res> implements $DeviceCopyWith<$Res> {
  factory _$$DeviceImplCopyWith(
          _$DeviceImpl value, $Res Function(_$DeviceImpl) then) =
      __$$DeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String ipAddress,
      bool isSelected,
      int port,
      DateTime lastSeen,
      bool isOnline});
}

/// @nodoc
class __$$DeviceImplCopyWithImpl<$Res>
    extends _$DeviceCopyWithImpl<$Res, _$DeviceImpl>
    implements _$$DeviceImplCopyWith<$Res> {
  __$$DeviceImplCopyWithImpl(
      _$DeviceImpl _value, $Res Function(_$DeviceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ipAddress = null,
    Object? isSelected = null,
    Object? port = null,
    Object? lastSeen = null,
    Object? isOnline = null,
  }) {
    return _then(_$DeviceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: null == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      lastSeen: null == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceImpl extends _Device {
  const _$DeviceImpl(
      {required this.id,
      required this.name,
      required this.ipAddress,
      this.isSelected = false,
      this.port = 8888,
      required this.lastSeen,
      this.isOnline = false})
      : super._();

  factory _$DeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceImplFromJson(json);

  /// 唯一标识符 (UUID)
  @override
  final String id;

  /// 用户自定义的设备名称
  @override
  final String name;

  /// IP 地址
  @override
  final String ipAddress;

  /// 是否为当前选中设备
  @override
  @JsonKey()
  final bool isSelected;

  /// UDP 端口（默认 8888）
  @override
  @JsonKey()
  final int port;

  /// 最后在线时间
  @override
  final DateTime lastSeen;

  /// 是否在线
  @override
  @JsonKey()
  final bool isOnline;

  @override
  String toString() {
    return 'Device(id: $id, name: $name, ipAddress: $ipAddress, isSelected: $isSelected, port: $port, lastSeen: $lastSeen, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, ipAddress, isSelected, port, lastSeen, isOnline);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceImplCopyWith<_$DeviceImpl> get copyWith =>
      __$$DeviceImplCopyWithImpl<_$DeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceImplToJson(
      this,
    );
  }
}

abstract class _Device extends Device {
  const factory _Device(
      {required final String id,
      required final String name,
      required final String ipAddress,
      final bool isSelected,
      final int port,
      required final DateTime lastSeen,
      final bool isOnline}) = _$DeviceImpl;
  const _Device._() : super._();

  factory _Device.fromJson(Map<String, dynamic> json) = _$DeviceImpl.fromJson;

  @override

  /// 唯一标识符 (UUID)
  String get id;
  @override

  /// 用户自定义的设备名称
  String get name;
  @override

  /// IP 地址
  String get ipAddress;
  @override

  /// 是否为当前选中设备
  bool get isSelected;
  @override

  /// UDP 端口（默认 8888）
  int get port;
  @override

  /// 最后在线时间
  DateTime get lastSeen;
  @override

  /// 是否在线
  bool get isOnline;
  @override
  @JsonKey(ignore: true)
  _$$DeviceImplCopyWith<_$DeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
