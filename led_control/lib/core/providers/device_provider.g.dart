// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'aa7ace48f3c0dce382957e3c6eac2449573583a9';

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
String _$deviceStorageHash() => r'598cf3de7c437ff1458f84b77d756c0132886d75';

/// 设备存储 Provider
///
/// Copied from [deviceStorage].
@ProviderFor(deviceStorage)
final deviceStorageProvider = AutoDisposeFutureProvider<DeviceStorage>.internal(
  deviceStorage,
  name: r'deviceStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeviceStorageRef = AutoDisposeFutureProviderRef<DeviceStorage>;
String _$deviceListHash() => r'379b89dbda5ce0412a91f5c66049689b48970419';

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
