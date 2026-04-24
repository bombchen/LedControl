import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/providers/provisioning_provider.dart';
import 'package:led_control/features/provisioning/provisioning_wait_page.dart';

class PasswordEntryPage extends ConsumerStatefulWidget {
  const PasswordEntryPage({super.key});

  @override
  ConsumerState<PasswordEntryPage> createState() => _PasswordEntryPageState();
}

class _PasswordEntryPageState extends ConsumerState<PasswordEntryPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _localError;

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
            CupertinoTextField(
              controller: _passwordController,
              placeholder: '请输入 Wi‑Fi 密码',
              obscureText: _obscurePassword,
            ),
            CupertinoButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              child: Text(_obscurePassword ? '显示密码' : '隐藏密码'),
            ),
            if (_localError != null)
              Text(
                _localError!,
                style: const TextStyle(color: CupertinoColors.systemRed),
              ),
            CupertinoButton.filled(
              onPressed: () async {
                if (selectedSsid == '未选择' || _passwordController.text.trim().isEmpty) {
                  setState(() {
                    _localError = '请先选择 Wi‑Fi 并输入密码';
                  });
                  return;
                }

                setState(() {
                  _localError = null;
                });

                await ref.read(provisioningProvider.notifier).submitPassword(
                      ipAddress: '192.168.4.1',
                      password: _passwordController.text,
                    );
                if (!mounted) return;
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (context) => const ProvisioningWaitPage(),
                  ),
                );
              },
              child: const Text('连接'),
            ),
          ],
        ),
      ),
    );
  }
}
