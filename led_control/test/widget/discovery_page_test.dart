import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:led_control/app.dart';
import 'package:led_control/core/models/device.dart';
import 'package:led_control/core/models/network_result.dart';
import 'package:led_control/core/network/udp_client.dart';
import 'package:led_control/core/providers/control_provider.dart';
import 'package:led_control/core/providers/device_provider.dart';
import 'package:led_control/core/providers/discovery_provider.dart';
import 'package:led_control/core/storage/device_storage.dart';
import 'package:led_control/features/discovery/discovery_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePrefs implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  bool? getBool(String key) => _data[key] as bool?;
  @override
  double? getDouble(String key) => _data[key] as double?;
  @override
  int? getInt(String key) => _data[key] as int?;
  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;
  @override
  String? getString(String key) => _data[key] as String?;
  @override
  bool containsKey(String key) => _data.containsKey(key);
  @override
  Set<String> getKeys() => _data.keys.toSet();
  @override
  dynamic get(String key) => _data[key];
  @override
  Future<bool> setBool(String key, bool value) async { _data[key] = value; return true; }
  @override
  Future<bool> setDouble(String key, double value) async { _data[key] = value; return true; }
  @override
  Future<bool> setInt(String key, int value) async { _data[key] = value; return true; }
  @override
  Future<bool> setString(String key, String value) async { _data[key] = value; return true; }
  @override
  Future<bool> setStringList(String key, List<String> value) async { _data[key] = value; return true; }
  @override
  Future<bool> remove(String key) async { _data.remove(key); return true; }
  @override
  Future<bool> clear() async { _data.clear(); return true; }
  @override
  Future<bool> commit() async => true;
  @override
  Future<bool> reload() async => true;
  @override
  Set<String> get keys => _data.keys.toSet();
  @override
  bool? operator [](String key) => _data[key] as bool?;
  @override
  Future<void> setMockInitialValues(Map<String, Object> values) async {}
}

class _FakeUdpClient extends UDPClient {
  @override
  Future<NetworkResult<String>> sendCommand({
    required String ipAddress,
    required int port,
    required String command,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    return const NetworkSuccess('OK');
  }
}

class _FakeDeviceStorage extends DeviceStorage {
  _FakeDeviceStorage() : super(_FakePrefs());

  List<Device> _devices = [];

  @override
  Future<List<Device>> getAllDevices() async => _devices;

  @override
  Future<void> saveDevice(Device device) async {
    _devices = [
      ..._devices.where((d) => d.id != device.id),
      device,
    ];
  }

  @override
  Future<void> setSelectedDevice(String id) async {
    _devices = [
      for (final device in _devices)
        device.copyWith(isSelected: device.id == id),
    ];
  }

  @override
  Future<void> deleteDevice(String id) async {
    _devices = _devices.where((device) => device.id != id).toList();
  }

  @override
  Future<void> clear() async {
    _devices = [];
  }
}

void main() {
  testWidgets('discovery page shows scan and provisioning actions', (tester) async {
    final storage = _FakeDeviceStorage();
    await storage.saveDevice(
      Device(
        id: 'device-1',
        name: '客厅灯',
        ipAddress: '192.168.1.10',
        port: 8888,
        lastSeen: DateTime(2026, 4, 22),
        isOnline: true,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => _FakePrefs()),
        deviceStorageProvider.overrideWith((ref) async => storage),
        udpClientProvider.overrideWith((ref) => _FakeUdpClient()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CupertinoApp(
          home: DiscoveryPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('设备搜索'), findsOneWidget);
    expect(find.text('扫描设备'), findsAtLeastNWidgets(1));
    expect(find.text('手动添加 IP'), findsOneWidget);
    expect(find.text('开始配网'), findsOneWidget);
    expect(find.text('客厅灯'), findsOneWidget);
    expect(find.text('192.168.1.10:8888'), findsOneWidget);

    await tester.tap(find.text('开始配网'));
    await tester.pumpAndSettle();
    expect(find.text('配网引导'), findsOneWidget);
  });

  testWidgets('tapping discovered device enters control page', (tester) async {
    final storage = _FakeDeviceStorage();
    await storage.saveDevice(
      Device(
        id: 'device-1',
        name: '客厅灯',
        ipAddress: '192.168.1.10',
        port: 8888,
        lastSeen: DateTime(2026, 4, 22),
        isOnline: true,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => _FakePrefs()),
        deviceStorageProvider.overrideWith((ref) async => storage),
        udpClientProvider.overrideWith((ref) => _FakeUdpClient()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LedControlApp(),
      ),
    );

    await tester.pump();
    expect(find.text('客厅灯'), findsOneWidget);

    await tester.tap(find.text('客厅灯'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('效果控制'), findsOneWidget);
  });

  testWidgets('manual add IP enters control page', (tester) async {
    final storage = _FakeDeviceStorage();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => _FakePrefs()),
        deviceStorageProvider.overrideWith((ref) async => storage),
        udpClientProvider.overrideWith((ref) => _FakeUdpClient()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LedControlApp(),
      ),
    );

    await tester.pump();

    await tester.tap(find.text('手动添加 IP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(
      find.byType(CupertinoTextField).at(0),
      '书房灯',
    );
    await tester.enterText(
      find.byType(CupertinoTextField).at(1),
      '192.168.1.88',
    );
    await tester.enterText(
      find.byType(CupertinoTextField).at(2),
      '9999',
    );

    await tester.tap(find.text('保存'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('效果控制'), findsOneWidget);
  });
}
