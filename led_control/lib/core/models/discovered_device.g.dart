// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovered_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscoveredDeviceImpl _$$DiscoveredDeviceImplFromJson(
        Map<String, dynamic> json) =>
    _$DiscoveredDeviceImpl(
      ipAddress: json['ipAddress'] as String,
      port: (json['port'] as num?)?.toInt() ?? 8888,
      name: json['name'] as String?,
      currentEffect: json['currentEffect'] as String?,
      brightness: (json['brightness'] as num?)?.toInt(),
      responseTime: DateTime.parse(json['responseTime'] as String),
      signalStrength: (json['signalStrength'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DiscoveredDeviceImplToJson(
        _$DiscoveredDeviceImpl instance) =>
    <String, dynamic>{
      'ipAddress': instance.ipAddress,
      'port': instance.port,
      'name': instance.name,
      'currentEffect': instance.currentEffect,
      'brightness': instance.brightness,
      'responseTime': instance.responseTime.toIso8601String(),
      'signalStrength': instance.signalStrength,
    };
