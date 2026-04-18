import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WiFi 密码输入组件
class PasswordInput extends ConsumerStatefulWidget {
  final String ssid;
  final ValueChanged<String>? onSubmit;

  const PasswordInput({
    super.key,
    required this.ssid,
    this.onSubmit,
  });

  @override
  ConsumerState<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends ConsumerState<PasswordInput> {
  late TextEditingController _controller;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _handleSubmit() {
    if (_controller.text.isEmpty) {
      _showError('请输入 WiFi 密码');
      return;
    }

    if (_controller.text.length < 8) {
      _showError('密码长度至少 8 位');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 模拟提交延迟
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
      widget.onSubmit?.call(_controller.text);
    });
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 网络名称
          Row(
            children: [
              const Icon(
                CupertinoIcons.wifi,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '连接到',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      widget.ssid,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 密码输入
          const Text(
            '输入密码',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _controller,
                    placeholder: 'WiFi 密码',
                    obscureText: !_isPasswordVisible,
                    clearButtonMode: OverlayVisibilityMode.editing,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                ),
                // 显示/隐藏密码按钮
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: _togglePasswordVisibility,
                  child: Icon(
                    _isPasswordVisible
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 提示信息
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.info_circle,
                  size: 16,
                  color: CupertinoColors.systemBlue,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '密码将被安全发送到 LED 设备，不会保存在应用中',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  color: CupertinoColors.systemGrey5,
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  color: CupertinoColors.systemBlue,
                  child: _isLoading
                      ? const CupertinoActivityIndicator()
                      : const Text('连接'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// WiFi 密码强度指示器
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  int get _strength {
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength.clamp(0, 4);
  }

  String get _strengthText {
    switch (_strength) {
      case 0:
        return '';
      case 1:
        return '弱';
      case 2:
        return '一般';
      case 3:
        return '强';
      case 4:
        return '很强';
      default:
        return '';
    }
  }

  CupertinoDynamicColor get _strengthColor {
    switch (_strength) {
      case 1:
        return CupertinoColors.systemRed;
      case 2:
        return CupertinoColors.systemOrange;
      case 3:
        return CupertinoColors.systemYellow;
      case 4:
        return CupertinoColors.systemGreen;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '密码强度: $_strengthText',
              style: TextStyle(
                fontSize: 12,
                color: _strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            ...List.generate(4, (index) {
              return Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: index < _strength
                      ? _strengthColor
                      : CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
