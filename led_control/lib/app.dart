import 'package:flutter/cupertino.dart';
import 'package:led_control/features/discovery/discovery_page.dart';

class LedControlApp extends StatelessWidget {
  const LedControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'LED 灯带控制器',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
        barBackgroundColor: CupertinoColors.systemBackground,
      ),
      home: DiscoveryPage(),
    );
  }
}
