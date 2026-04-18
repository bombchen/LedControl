// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceScannerHash() => r'0037069ad88242edd0069978b9f49589de15ece3';

/// 设备扫描器 Provider
///
/// Copied from [deviceScanner].
@ProviderFor(deviceScanner)
final deviceScannerProvider = AutoDisposeProvider<DeviceScanner>.internal(
  deviceScanner,
  name: r'deviceScannerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceScannerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeviceScannerRef = AutoDisposeProviderRef<DeviceScanner>;
String _$deviceScanHash() => r'7852b3c21aeeb74156e8e187ebc58ab68ef17d5b';

/// 设备扫描器 Provider
///
/// Copied from [DeviceScan].
@ProviderFor(DeviceScan)
final deviceScanProvider =
    AutoDisposeNotifierProvider<DeviceScan, ScanState>.internal(
  DeviceScan.new,
  name: r'deviceScanProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deviceScanHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeviceScan = AutoDisposeNotifier<ScanState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
