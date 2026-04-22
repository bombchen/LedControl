import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:led_control/core/models/device.dart';
import 'package:led_control/core/providers/device_provider.dart';

part 'discovery_provider.g.dart';

@riverpod
class DeviceDiscovery extends _$DeviceDiscovery {
  @override
  Future<List<Device>> build() async {
    final devices = await ref.watch(deviceProvider.future);
    return devices.where((device) => device.isOnline).toList();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> addDiscoveredDevice(Device device) async {
    final existingDevices = await ref.read(deviceProvider.future);

    // TODO: Merge discovered device into persisted devices using IP-first matching.
    // Consider whether to preserve user-edited fields like name/isSelected while
    // updating discovery-derived fields like isOnline and lastSeen.
    final mergedDevice = _mergeDevice(existingDevices, device);

    await ref.read(deviceProvider.notifier).updateOrAddDiscoveredDevice(mergedDevice);
    ref.invalidateSelf();
  }

  Device _mergeDevice(List<Device> existingDevices, Device discoveredDevice) {
    final existingDevice = existingDevices.cast<Device?>().firstWhere(
      (device) => device?.ipAddress == discoveredDevice.ipAddress,
      orElse: () => null,
    );

    if (existingDevice == null) {
      return discoveredDevice;
    }

    return existingDevice.copyWith(
      ipAddress: discoveredDevice.ipAddress,
      port: discoveredDevice.port,
      lastSeen: discoveredDevice.lastSeen,
      isOnline: discoveredDevice.isOnline,
    );
  }
}
