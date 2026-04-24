import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:led_control/core/providers/app_entry_provider.dart';

void main() {
  test('app entry defaults to discovery and can switch to control', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(appEntryProvider), AppEntryMode.discovery);

    container.read(appEntryProvider.notifier).showControl();
    expect(container.read(appEntryProvider), AppEntryMode.control);

    container.read(appEntryProvider.notifier).showDiscovery();
    expect(container.read(appEntryProvider), AppEntryMode.discovery);
  });
}
