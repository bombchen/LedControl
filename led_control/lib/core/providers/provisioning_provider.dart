import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:led_control/core/models/network_result.dart';
import 'package:led_control/core/network/led_protocol.dart';
import 'package:led_control/core/network/udp_client.dart';
import 'package:led_control/core/providers/control_provider.dart';

part 'provisioning_provider.g.dart';

enum ProvisioningStep { guide, wifiSelect, passwordEntry, waiting, complete, error }

class ProvisioningState {
  const ProvisioningState({
    required this.step,
    this.selectedSsid,
    this.errorMessage,
  });

  final ProvisioningStep step;
  final String? selectedSsid;
  final String? errorMessage;

  factory ProvisioningState.initial() => const ProvisioningState(step: ProvisioningStep.guide);

  ProvisioningState copyWith({
    ProvisioningStep? step,
    String? selectedSsid,
    String? errorMessage,
  }) {
    return ProvisioningState(
      step: step ?? this.step,
      selectedSsid: selectedSsid ?? this.selectedSsid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class Provisioning extends _$Provisioning {
  @override
  ProvisioningState build() {
    return ProvisioningState.initial();
  }

  void goToWifiSelect() {
    state = state.copyWith(step: ProvisioningStep.wifiSelect, errorMessage: null);
  }

  void selectSsid(String ssid) {
    state = state.copyWith(
      step: ProvisioningStep.passwordEntry,
      selectedSsid: ssid,
      errorMessage: null,
    );
  }

  Future<void> submitPassword({
    required String ipAddress,
    required String password,
    int port = 8889,
  }) async {
    final ssid = state.selectedSsid;
    if (ssid == null || ssid.isEmpty) {
      state = state.copyWith(
        step: ProvisioningStep.error,
        errorMessage: '请先选择 Wi‑Fi',
      );
      return;
    }

    state = state.copyWith(step: ProvisioningStep.waiting, errorMessage: null);

    final client = ref.read(udpClientProvider);
    final result = await client.sendCommand(
      ipAddress: ipAddress,
      port: port,
      command: LEDProtocol.configWiFi(ssid, password),
    );

    if (result is NetworkSuccess<String>) {
      state = state.copyWith(step: ProvisioningStep.waiting, errorMessage: null);
      return;
    }

    final error = result as NetworkError<String>;
    state = state.copyWith(
      step: ProvisioningStep.error,
      errorMessage: error.message,
    );
  }

  void retry() {
    state = state.copyWith(step: ProvisioningStep.waiting, errorMessage: null);
  }

  void complete() {
    state = state.copyWith(step: ProvisioningStep.complete, errorMessage: null);
  }
}
