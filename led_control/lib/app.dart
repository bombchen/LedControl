import 'package:flutter/cupertino.dart';

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
      home: _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.lightbulb, size: 80, color: CupertinoColors.systemYellow),
            SizedBox(height: 16),
            Text('LED 灯带控制器', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('初始化中...', style: TextStyle(color: CupertinoColors.systemGrey)),
          ],
        ),
      ),
    );
  }
}
