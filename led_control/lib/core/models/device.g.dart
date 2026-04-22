// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceImpl _$$DeviceImplFromJson(Map<String, dynamic> json) => _$DeviceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      isSelected: json['isSelected'] as bool? ?? false,
      port: (json['port'] as num?)?.toInt() ?? 8888,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
    );

Map<String, dynamic> _$$DeviceImplToJson(_$DeviceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ipAddress': instance.ipAddress,
      'isSelected': instance.isSelected,
      'port': instance.port,
      'lastSeen': instance.lastSeen.toIso8601String(),
      'isOnline': instance.isOnline,
    };
