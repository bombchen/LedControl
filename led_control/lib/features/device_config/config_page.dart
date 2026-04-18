import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/features/device_config/widgets/wifi_list.dart';
import 'package:led_control/features/device_config/widgets/password_input.dart';
import 'package:led_control/features/device_config/widgets/config_progress.dart';

/// WiFi 配置页面
class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends ConsumerState<ConfigPage> {
  ConfigStep _currentStep = ConfigStep.connectHotspot;
  WiFiNetwork? _selectedNetwork;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 检查是否已连接到 LED_Config 热点
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    // 模拟检查连接
    await Future.delayed(const Duration(seconds: 1));
    // 这里可以添加实际的 WiFi 状态检查逻辑
    // 暂时直接进入选择 WiFi 步骤
    setState(() {
      _currentStep = ConfigStep.selectWiFi;
    });
  }

  void _handleNetworkSelected(WiFiNetwork network) {
    setState(() {
      _selectedNetwork = network;
      _currentStep = ConfigStep.enterPassword;
    });
  }

  Future<void> _handlePasswordSubmitted(String password) async {
    setState(() {
      _currentStep = ConfigStep.configuring;
      _errorMessage = null;
    });

    try {
      // 模拟配置过程
      await Future.delayed(const Duration(seconds: 2));

      // 模拟发送配置到设备
      await Future.delayed(const Duration(seconds: 1));

      // 模拟等待设备重启
      setState(() {
        _currentStep = ConfigStep.waitingReboot;
      });

      await Future.delayed(const Duration(seconds: 3));

      // 配置完成
      setState(() {
        _currentStep = ConfigStep.complete;
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '配置失败: $e';
        _currentStep = ConfigStep.selectWiFi;
      });
    }
  }

  void _handleRetry() {
    setState(() {
      _errorMessage = null;
      _currentStep = ConfigStep.selectWiFi;
    });
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfigSuccessAnimation(
        onComplete: () {
          Navigator.of(context).pop(); // 关闭动画对话框
          Navigator.of(context).pop(); // 返回到上一页
        },
      ),
    );
  }

  void _resetConfiguration() {
    setState(() {
      _currentStep = ConfigStep.connectHotspot;
      _selectedNetwork = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('WiFi 配置'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: _currentStep != ConfigStep.connectHotspot
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('重置'),
                onPressed: _resetConfiguration,
              )
            : null,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 配置进度
            ConfigProgress(
              currentStep: _currentStep,
              errorMessage: _errorMessage,
              onRetry: _handleRetry,
            ),

            const SizedBox(height: 24),

            // 步骤内容
            _buildStepContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case ConfigStep.connectHotspot:
        return _buildConnectHotspotStep();
      case ConfigStep.selectWiFi:
        return _buildSelectWiFiStep();
      case ConfigStep.enterPassword:
        if (_selectedNetwork != null) {
          return PasswordInput(
            ssid: _selectedNetwork!.ssid,
            onSubmit: _handlePasswordSubmitted,
          );
        }
        return const SizedBox.shrink();
      case ConfigStep.configuring:
      case ConfigStep.waitingReboot:
        return _buildWaitingStep();
      case ConfigStep.complete:
        return _buildCompleteStep();
    }
  }

  /// 步骤 1: 连接到设备热点
  Widget _buildConnectHotspotStep() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  CupertinoIcons.wifi,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '连接到设备热点',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '请连接到 LED 设备的配置热点',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '操作步骤：',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStepItem('1', '打开手机的 WiFi 设置'),
                _buildStepItem('2', '找到并连接到 "LED_Config" 热点'),
                _buildStepItem('3', '返回此应用继续配置'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        CupertinoIcons.info_circle,
                        size: 16,
                        color: CupertinoColors.systemBlue,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '默认密码通常是 "12345678"',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            onPressed: () {
              setState(() {
                _currentStep = ConfigStep.selectWiFi;
              });
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('已连接，继续'),
                SizedBox(width: 8),
                Icon(CupertinoIcons.right_chevron, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 步骤 2: 选择 WiFi 网络
  Widget _buildSelectWiFiStep() {
    return WiFiList(
      onNetworkSelected: _handleNetworkSelected,
      selectedSSID: _selectedNetwork?.ssid,
    );
  }

  /// 等待步骤
  Widget _buildWaitingStep() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(radius: 20),
          const SizedBox(height: 24),
          Text(
            _currentStep == ConfigStep.configuring
                ? '正在配置设备...'
                : '设备正在重启...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '请稍候，此过程可能需要 1-2 分钟',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  /// 完成步骤
  Widget _buildCompleteStep() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.check_mark_circled,
            size: 64,
            color: CupertinoColors.systemGreen,
          ),
          SizedBox(height: 24),
          Text(
            '配置完成',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '设备已成功连接到 WiFi',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// WiFi 配置入口按钮
class WiFiConfigButton extends StatelessWidget {
  const WiFiConfigButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const ConfigPage(),
          ),
        );
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.wifi),
          SizedBox(width: 8),
          Text('配置 WiFi'),
        ],
      ),
    );
  }
}
