// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'7cd30c9640ca952d1bcf1772c709fc45dc47c8b3';

/// SharedPreferences Provider
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider =
    AutoDisposeFutureProvider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferencesRef = AutoDisposeFutureProviderRef<SharedPreferences>;
String _$deviceStorageHash() => r'1bd8be87212dcaad82e122d3572bd7770e938c99';

/// 设备存储 Provider
///
/// Copied from [deviceStorage].
@ProviderFor(deviceStorage)
final deviceStorageProvider = AutoDisposeProvider<DeviceStorage>.internal(
  deviceStorage,
  name: r'deviceStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeviceStorageRef = AutoDisposeProviderRef<DeviceStorage>;
String _$deviceListHash() => r'6d22a7737578aa5e39a0fcc33b0cbb9073a70207';

/// 设备列表 Provider
///
/// Copied from [DeviceList].
@ProviderFor(DeviceList)
final deviceListProvider =
    AutoDisposeAsyncNotifierProvider<DeviceList, List<Device>>.internal(
  DeviceList.new,
  name: r'deviceListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deviceListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeviceList = AutoDisposeAsyncNotifier<List<Device>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
