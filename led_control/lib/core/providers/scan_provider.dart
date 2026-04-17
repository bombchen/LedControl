import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:led_control/core/network/device_scanner.dart';
import 'package:led_control/core/models/discovered_device.dart';

part 'scan_provider.g.dart';

/// 设备扫描器 Provider
@riverpod
DeviceScanner deviceScanner(DeviceScannerRef ref) {
  return DeviceScanner();
}

/// 扫描状态
class ScanState {
  const ScanState({
    this.isScanning = false,
    this.devices = const [],
    this.error,
    this.foundDeviceCount = 0,
  });

  final bool isScanning;
  final List<DiscoveredDevice> devices;
  final String? error;
  final int foundDeviceCount;

  ScanState copyWith({
    bool? isScanning,
    List<DiscoveredDevice>? devices,
    String? error,
    int? foundDeviceCount,
  }) {
    return ScanState(
      isScanning: isScanning ?? this.isScanning,
      devices: devices ?? this.devices,
      error: error ?? this.error,
      foundDeviceCount: foundDeviceCount ?? this.foundDeviceCount,
    );
  }
}

/// 设备扫描器 Provider
@riverpod
class DeviceScan extends _$DeviceScan {
  @override
  ScanState build() {
    return const ScanState();
  }

  /// 开始扫描
  Future<void> startScan({Duration timeout = const Duration(seconds: 5)}) async {
    // 如果已经在扫描，不重复扫描
    if (state.isScanning) {
      return;
    }

    // 更新状态为扫描中
    state = state.copyWith(
      isScanning: true,
      error: null,
      devices: [],
      foundDeviceCount: 0,
    );

    try {
      final scanner = ref.read(deviceScannerProvider);

      // 开始扫描并收集设备
      final discoveredDevices = await scanner.scan(
        timeout: timeout,
        onDeviceFound: (device) {
          // 实时更新状态，添加发现的设备
          state = state.copyWith(
            devices: [...state.devices, device],
            foundDeviceCount: state.foundDeviceCount + 1,
          );
        },
      );

      // 扫描完成 - 使用最终收集的设备列表
      state = state.copyWith(
        isScanning: false,
        devices: discoveredDevices.isNotEmpty ? discoveredDevices : state.devices,
      );
    } on ScannerException catch (e) {
      // 扫描出错
      state = state.copyWith(
        isScanning: false,
        error: e.message,
      );
    } catch (e) {
      // 未知错误
      state = state.copyWith(
        isScanning: false,
        error: '扫描出错: $e',
      );
    }
  }

  /// 停止扫描
  Future<void> stopScan() async {
    if (!state.isScanning) {
      return;
    }

    try {
      final scanner = ref.read(deviceScannerProvider);

      // 停止扫描（通过 dispose 关闭扫描器）
      await scanner.dispose();

      state = state.copyWith(isScanning: false);
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: '停止扫描出错: $e',
      );
    }
  }

  /// 清除扫描结果
  void clearResults() {
    state = state.copyWith(
      devices: [],
      error: null,
      foundDeviceCount: 0,
    );
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 通过 IP 地址查找已发现的设备
  DiscoveredDevice? findDevice(String ipAddress) {
    try {
      return state.devices.firstWhere((d) => d.ipAddress == ipAddress);
    } catch (e) {
      return null;
    }
  }

  /// 检查设备是否已发现
  bool isDeviceDiscovered(String ipAddress) {
    return findDevice(ipAddress) != null;
  }
}

/// 便捷访问扫描器的 Provider
final scanProvider = deviceScanProvider;
