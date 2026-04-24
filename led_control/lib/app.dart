import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/providers/app_entry_provider.dart';
import 'package:led_control/features/control/control_page.dart';
import 'package:led_control/features/discovery/discovery_page.dart';

class LedControlApp extends ConsumerWidget {
  const LedControlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryMode = ref.watch(appEntryProvider);

    return CupertinoApp(
      title: 'LED 灯带控制器',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
        barBackgroundColor: CupertinoColors.systemBackground,
      ),
      home: entryMode == AppEntryMode.discovery
          ? const DiscoveryPage()
          : const ControlPage(),
    );
  }
}
