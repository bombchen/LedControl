import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
