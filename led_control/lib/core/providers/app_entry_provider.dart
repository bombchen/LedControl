import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_entry_provider.g.dart';

enum AppEntryMode { discovery, control }

@riverpod
class AppEntry extends _$AppEntry {
  @override
  AppEntryMode build() => AppEntryMode.discovery;

  void showDiscovery() {
    state = AppEntryMode.discovery;
  }

  void showControl() {
    state = AppEntryMode.control;
  }
}
