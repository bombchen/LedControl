import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/providers/provisioning_provider.dart';

void main() {
  test('provisioning state starts at guide', () {
    final container = ProviderContainer();

    final state = container.read(provisioningProvider);

    expect(state.step, ProvisioningStep.guide);
    expect(state.selectedSsid, isNull);
    expect(state.errorMessage, isNull);

    container.dispose();
  });

  test('provisioning state moves through the onboarding steps', () {
    final container = ProviderContainer();
    final notifier = container.read(provisioningProvider.notifier);

    notifier.goToWifiSelect();
    expect(container.read(provisioningProvider).step, ProvisioningStep.wifiSelect);

    notifier.selectSsid('MyWifi');
    final selected = container.read(provisioningProvider);
    expect(selected.step, ProvisioningStep.passwordEntry);
    expect(selected.selectedSsid, 'MyWifi');

    notifier.complete();
    expect(container.read(provisioningProvider).step, ProvisioningStep.complete);

    container.dispose();
  });

  test('provisioning state can move into waiting and complete', () {
    final container = ProviderContainer();
    final notifier = container.read(provisioningProvider.notifier);

    notifier.goToWifiSelect();
    notifier.selectSsid('MyWifi');
    notifier.retry();

    expect(container.read(provisioningProvider).step, ProvisioningStep.waiting);

    notifier.complete();
    expect(container.read(provisioningProvider).step, ProvisioningStep.complete);

    container.dispose();
  });
}
