import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/providers/provisioning_provider.dart';

class PasswordEntryPage extends ConsumerStatefulWidget {
  const PasswordEntryPage({super.key});

  @override
  ConsumerState<PasswordEntryPage> createState() => _PasswordEntryPageState();
}

class _PasswordEntryPageState extends ConsumerState<PasswordEntryPage> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSsid = ref.watch(provisioningProvider).selectedSsid ?? '未选择';

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('密码输入'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Text('SSID: $selectedSsid'),
            CupertinoTextField(controller: _passwordController, placeholder: '请输入 Wi‑Fi 密码'),
            CupertinoButton.filled(
              onPressed: () => ref.read(provisioningProvider.notifier).submitPassword(
                    ipAddress: '192.168.4.1',
                    password: _passwordController.text,
                  ),
              child: const Text('连接'),
            ),
          ],
        ),
      ),
    );
  }
}
