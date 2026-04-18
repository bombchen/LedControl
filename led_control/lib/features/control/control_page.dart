import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/providers/device_provider.dart';
import 'package:led_control/core/providers/control_provider.dart';
import 'package:led_control/core/models/led_effect.dart';
import 'package:led_control/features/control/widgets/effect_preview.dart';
import 'package:led_control/features/control/widgets/brightness_slider.dart';
import 'package:led_control/features/control/widgets/effect_grid.dart';

/// LED 控制主页面
class ControlPage extends ConsumerStatefulWidget {
  const ControlPage({super.key});

  @override
  ConsumerState<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends ConsumerState<ControlPage> {
  late LEDEffect _currentEffect;
  late int _currentBrightness;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentEffect = LEDEffect.rainbow;
    _currentBrightness = 128;
  }

  Future<void> _setEffect(LEDEffect effect) async {
    final device = ref.read(deviceProvider).valueOrNull?.first;
    if (device == null) return;

    setState(() {
      _currentEffect = effect;
    });

    final result = await ref.read(lEDControlProvider.notifier).setEffect(
          ipAddress: device.ipAddress,
          effect: effect,
          port: device.port,
        );

    if (!mounted) return;

    if (result.isSuccess) {
      _showSuccessSnackBar('已切换到 ${effect.displayName}效果');
    } else {
      _showErrorSnackBar(result.error ?? '切换效果失败');
    }
  }

  Future<void> _setBrightness(int brightness) async {
    final device = ref.read(deviceProvider).valueOrNull?.first;
    if (device == null) return;

    setState(() {
      _currentBrightness = brightness;
    });

    final result = await ref.read(lEDControlProvider.notifier).setBrightness(
          ipAddress: device.ipAddress,
          brightness: brightness,
          port: device.port,
        );

    if (!mounted) return;

    if (!result.isSuccess) {
      _showErrorSnackBar(result.error ?? '设置亮度失败');
    }
  }

  void _showSuccessSnackBar(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.check_mark_circled,
              color: CupertinoColors.systemGreen,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.xmark_circle,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
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
    final devicesAsync = ref.watch(deviceProvider);

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            label: '效果',
            icon: Icon(CupertinoIcons.sparkles),
            activeIcon: Icon(CupertinoIcons.sparkles),
          ),
          BottomNavigationBarItem(
            label: '设置',
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings),
          ),
          BottomNavigationBarItem(
            label: '设备',
            icon: Icon(CupertinoIcons.device_phone_portrait),
            activeIcon: Icon(CupertinoIcons.device_phone_portrait),
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return _buildEffectTab(devicesAsync);
          case 1:
            return _buildSettingsTab(devicesAsync);
          case 2:
            return _buildDeviceTab(devicesAsync);
          default:
            return _buildEffectTab(devicesAsync);
        }
      },
    );
  }

  /// 效果 Tab
  Widget _buildEffectTab(AsyncValue<List<dynamic>> devicesAsync) {
    return CupertinoTabView(
      builder: (context) {
        return devicesAsync.when(
          loading: () => const _LoadingState(),
          error: (error, stack) => _ErrorState(
            error: error.toString(),
            onRetry: () {
              ref.read(deviceProvider.notifier).refresh();
            },
          ),
          data: (devices) {
            if (devices.isEmpty) {
              return const _EmptyDevicesState();
            }

            return CupertinoPageScaffold(
              navigationBar: const CupertinoNavigationBar(
                middle: Text('效果控制'),
              ),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 设备信息
                    _buildDeviceInfo(devices.first),
                    const SizedBox(height: 16),

                    // 效果预览
                    EffectPreview(effect: _currentEffect.commandValue),
                    const SizedBox(height: 16),

                    // 亮度控制
                    BrightnessSlider(
                      initialValue: _currentBrightness,
                      onChanged: _setBrightness,
                      deviceIp: devices.first.ipAddress,
                    ),
                    const SizedBox(height: 24),

                    // 效果选择
                    const Text(
                      '选择效果',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EffectGrid(
                      currentEffect: _currentEffect,
                      onEffectSelected: _setEffect,
                    ),
                    const SizedBox(height: 24),

                    // 快捷操作
                    _buildQuickActions(devices.first),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 设置 Tab
  Widget _buildSettingsTab(AsyncValue<List<dynamic>> devicesAsync) {
    return CupertinoTabView(
      builder: (context) {
        return devicesAsync.when(
          loading: () => const _LoadingState(),
          error: (error, stack) => _ErrorState(
            error: error.toString(),
            onRetry: () {
              ref.read(deviceProvider.notifier).refresh();
            },
          ),
          data: (devices) {
            if (devices.isEmpty) {
              return const _EmptyDevicesState();
            }

            return CupertinoPageScaffold(
              navigationBar: const CupertinoNavigationBar(
                middle: Text('高级设置'),
              ),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 设备信息
                    _buildDeviceInfo(devices.first),
                    const SizedBox(height: 24),

                    // 当前状态
                    _buildCurrentStatus(),
                    const SizedBox(height: 24),

                    // 高级选项
                    _buildAdvancedOptions(devices.first),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 设备 Tab
  Widget _buildDeviceTab(AsyncValue<List<dynamic>> devicesAsync) {
    return CupertinoTabView(
      builder: (context) {
        return devicesAsync.when(
          loading: () => const _LoadingState(),
          error: (error, stack) => _ErrorState(
            error: error.toString(),
            onRetry: () {
              ref.read(deviceProvider.notifier).refresh();
            },
          ),
          data: (devices) {
            return CupertinoPageScaffold(
              navigationBar: const CupertinoNavigationBar(
                middle: Text('设备管理'),
              ),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      '已保存的设备',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...devices.map((device) => _buildDeviceCard(device)),
                    const SizedBox(height: 24),
                    _buildAddDeviceButton(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// �建设备信息卡片
  Widget _buildDeviceInfo(dynamic device) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.device_phone_portrait,
            size: 28,
            color: CupertinoColors.systemBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.ipAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusIndicator(device.isOnline),
        ],
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator(bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline
            ? CupertinoColors.systemGreen.withOpacity(0.2)
            : CupertinoColors.systemGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemGrey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? '在线' : '离线',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建当前状态
  Widget _buildCurrentStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '当前状态',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('效果'),
                  Text(_currentEffect.displayName),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('亮度'),
                  Text('$_currentBrightness'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建高级选项
  Widget _buildAdvancedOptions(dynamic device) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '高级选项',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildOptionTile(
          icon: CupertinoIcons.refresh,
          title: '刷新状态',
          onTap: () async {
            final result = await ref
                .read(lEDControlProvider.notifier)
                .getStatus(device.ipAddress, port: device.port);
            if (!mounted) return;
            if (result.isSuccess) {
              _showSuccessSnackBar('状态已刷新');
            } else {
              _showErrorSnackBar('刷新失败');
            }
          },
        ),
        _buildOptionTile(
          icon: CupertinoIcons.settings_solid,
          title: '更多设置',
          onTap: () {
            // TODO: 导航到更多设置页面
          },
        ),
      ],
    );
  }

  /// 构建选项列表项
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return CupertinoListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }

  /// 构建设备卡片
  Widget _buildDeviceCard(dynamic device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.lightbulb,
            size: 32,
            color: CupertinoColors.systemYellow,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.ipAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusIndicator(device.isOnline),
        ],
      ),
    );
  }

  /// 构建添加设备按钮
  Widget _buildAddDeviceButton() {
    return CupertinoButton.filled(
      onPressed: () {
        // TODO: 导航到添加设备页面
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.add),
          SizedBox(width: 8),
          Text('添加设备'),
        ],
      ),
    );
  }

  /// 构建快捷操作
  Widget _buildQuickActions(dynamic device) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快捷操作',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: CupertinoIcons.forward_end,
                label: '下一个',
                onTap: () async {
                  final result = await ref
                      .read(lEDControlProvider.notifier)
                      .nextEffect(device.ipAddress, port: device.port);
                  if (!mounted) return;
                  if (result.isSuccess) {
                    final currentIndex = LEDEffect.values.indexOf(_currentEffect);
                    final nextIndex = (currentIndex + 1) % LEDEffect.values.length;
                    setState(() {
                      _currentEffect = LEDEffect.values[nextIndex];
                    });
                  } else {
                    _showErrorSnackBar(result.error ?? '切换失败');
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: CupertinoIcons.backward_end,
                label: '上一个',
                onTap: () async {
                  final result = await ref
                      .read(lEDControlProvider.notifier)
                      .previousEffect(device.ipAddress, port: device.port);
                  if (!mounted) return;
                  if (result.isSuccess) {
                    final currentIndex = LEDEffect.values.indexOf(_currentEffect);
                    final prevIndex =
                        (currentIndex - 1 + LEDEffect.values.length) % LEDEffect.values.length;
                    setState(() {
                      _currentEffect = LEDEffect.values[prevIndex];
                    });
                  } else {
                    _showErrorSnackBar(result.error ?? '切换失败');
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建快捷操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      onPressed: onTap,
      color: CupertinoColors.systemGrey5,
      padding: const EdgeInsets.symmetric(vertical: 12),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// 加载状态
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: 16),
          SizedBox(height: 16),
          Text('加载中...'),
        ],
      ),
    );
  }
}

/// 错误状态
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.xmark_circle,
            size: 64,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(height: 16),
          Text(error),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            onPressed: onRetry,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}

/// 空设备状态
class _EmptyDevicesState extends StatelessWidget {
  const _EmptyDevicesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.device_phone_portrait,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无设备',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text('请先添加 LED 设备'),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () {
              // TODO: 导航到添加设备页面
            },
            child: const Text('添加设备'),
          ),
        ],
      ),
    );
  }
}
