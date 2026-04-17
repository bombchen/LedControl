// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$udpClientHash() => r'0b8063964fa5c51dcc0bba8b1772f119a16159ac';

/// UDP 客户端 Provider
///
/// Copied from [udpClient].
@ProviderFor(udpClient)
final udpClientProvider = AutoDisposeProvider<UDPClient>.internal(
  udpClient,
  name: r'udpClientProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$udpClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UdpClientRef = AutoDisposeProviderRef<UDPClient>;
String _$lEDControlHash() => r'f5331d094a55d3aeb311efb120e3ffdd5352f956';

/// LED 控制器 Provider
///
/// Copied from [LEDControl].
@ProviderFor(LEDControl)
final lEDControlProvider =
    AutoDisposeNotifierProvider<LEDControl, ControlState>.internal(
  LEDControl.new,
  name: r'lEDControlProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$lEDControlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LEDControl = AutoDisposeNotifier<ControlState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
