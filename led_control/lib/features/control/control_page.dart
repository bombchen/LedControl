import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_control/core/models/device.dart';
import 'package:led_control/core/models/led_effect.dart';
import 'package:led_control/core/providers/control_provider.dart';
import 'package:led_control/core/providers/device_provider.dart';
import 'package:led_control/features/control/widgets/brightness_slider.dart';
import 'package:led_control/features/control/widgets/effect_grid.dart';
import 'package:led_control/features/control/widgets/effect_preview.dart';
import 'package:led_control/features/device/device_settings_page.dart';

/// LED 控制主页面
class ControlPage extends ConsumerStatefulWidget {
  const ControlPage({super.key});

  @override
  ConsumerState<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends ConsumerState<ControlPage> {
  int _currentIndex = 0;
  bool _didRefreshStatus = false;

  Device? _currentDevice() {
    final devices = ref.read(deviceProvider).valueOrNull;
    if (devices == null || devices.isEmpty) return null;

    return devices.firstWhere(
      (device) => device.isSelected,
      orElse: () => devices.first,
    );
  }

  Future<void> _setEffect(LEDEffect effect) async {
    final device = _currentDevice();
    if (device == null) return;

    final result = await ref.read(lEDControlProvider.notifier).setEffect(
          ipAddress: device.ipAddress,
          effect: effect,
          port: device.port,
        );

    if (!mounted) return;

    if (result.isSuccess) {
      _showSuccessDialog('已切换到 ${effect.displayName} 效果');
    } else {
      _showErrorDialog(result.error ?? '切换效果失败');
    }
  }

  Future<void> _setBrightness(int brightness) async {
    final device = _currentDevice();
    if (device == null) return;

    final result = await ref.read(lEDControlProvider.notifier).setBrightness(
          ipAddress: device.ipAddress,
          brightness: brightness,
          port: device.port,
        );

    if (!mounted) return;

    if (!result.isSuccess) {
      _showErrorDialog(result.error ?? '设置亮度失败');
    }
  }

  Future<void> _refreshStatus(Device device) async {
    final result = await ref
        .read(lEDControlProvider.notifier)
        .getStatus(device.ipAddress, port: device.port);

    if (!mounted) return;

    if (result.isSuccess) {
      _showSuccessDialog('状态已刷新');
    } else {
      _showErrorDialog(result.error ?? '刷新失败');
    }
  }

  Future<void> _nextEffect(Device device) async {
    final result = await ref
        .read(lEDControlProvider.notifier)
        .nextEffect(device.ipAddress, port: device.port);

    if (!mounted) return;

    if (result.isSuccess) {
      _showSuccessDialog('已切换到下一个效果');
    } else {
      _showErrorDialog(result.error ?? '切换失败');
    }
  }

  Future<void> _previousEffect(Device device) async {
    final result = await ref
        .read(lEDControlProvider.notifier)
        .previousEffect(device.ipAddress, port: device.port);

    if (!mounted) return;

    if (result.isSuccess) {
      _showSuccessDialog('已切换到上一个效果');
    } else {
      _showErrorDialog(result.error ?? '切换失败');
    }
  }

  Future<void> _openAddDeviceSheet() async {
    final nameController = TextEditingController();
    final ipController = TextEditingController();
    final portController = TextEditingController(text: '8888');

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemBackground,
          child: SafeArea(
            child: CupertinoFormSection.insetGrouped(
              header: const Text('手动添加设备'),
              children: [
                CupertinoFormRow(
                  prefix: const Text('名称'),
                  child: CupertinoTextField(
                    controller: nameController,
                    placeholder: '例如：客厅灯带',
                    textInputAction: TextInputAction.next,
                  ),
                ),
                CupertinoFormRow(
                  prefix: const Text('IP 地址'),
                  child: CupertinoTextField(
                    controller: ipController,
                    placeholder: '192.168.1.100',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                CupertinoFormRow(
                  prefix: const Text('端口'),
                  child: CupertinoTextField(
                    controller: portController,
                    placeholder: '8888',
                    keyboardType: TextInputType.number,
                  ),
                ),
                CupertinoButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final ipAddress = ipController.text.trim();
                    final port = int.tryParse(portController.text.trim()) ?? 8888;

                    if (name.isEmpty || ipAddress.isEmpty) {
                      _showErrorDialog('请先填写设备名称和 IP 地址');
                      return;
                    }

                    final device = Device(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      ipAddress: ipAddress,
                      port: port,
                      lastSeen: DateTime.now(),
                      isOnline: false,
                    );

                    await ref.read(deviceProvider.notifier).addDevice(device);
                    if (!mounted) return;
                    Navigator.pop(context);
                    _showSuccessDialog('已添加设备');
                  },
                  child: const Text('保存'),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
              ],
            ),
          ),
        );
      },
    );

    nameController.dispose();
    ipController.dispose();
    portController.dispose();
  }

  void _showSuccessDialog(String message) {
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

  void _showErrorDialog(String message) {
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didRefreshStatus) return;

    final device = _currentDevice();
    if (device == null) return;

    _didRefreshStatus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshStatus(device);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controlState = ref.watch(lEDControlProvider);

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
            return _buildEffectTab(controlState);
          case 1:
            return _buildSettingsTab(controlState);
          case 2:
            return _buildDeviceTab();
          default:
            return _buildEffectTab(controlState);
        }
      },
    );
  }

  /// 效果 Tab
  Widget _buildEffectTab(ControlState controlState) {
    return CupertinoTabView(
      builder: (context) {
        final deviceIp = _currentDevice()?.ipAddress;

        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('效果控制'),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                EffectPreview(
                  effect: controlState.currentEffect?.commandValue ??
                      LEDEffect.rainbow.commandValue,
                ),
                const SizedBox(height: 16),
                BrightnessSlider(
                  initialValue: controlState.currentBrightness ?? 128,
                  onChanged: _setBrightness,
                  deviceIp: deviceIp,
                ),
                const SizedBox(height: 24),
                const Text(
                  '选择效果',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                EffectGrid(
                  currentEffect: controlState.currentEffect ?? LEDEffect.rainbow,
                  onEffectSelected: _setEffect,
                ),
                if (deviceIp != null) ...[
                  const SizedBox(height: 24),
                  _buildQuickActionsForIp(deviceIp),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// 设置 Tab
  Widget _buildSettingsTab(ControlState controlState) {
    return CupertinoTabView(
      builder: (context) {
        final devicesAsync = ref.watch(deviceProvider);

        return devicesAsync.when(
          loading: () => const _LoadingState(message: '正在加载设备数据...'),
          error: (error, stack) => _ErrorState(
            title: '设备数据暂不可用',
            description: '请稍后重试；如果一直停留在这里，可以尝试重启应用。',
            onRetry: () {
              ref.read(deviceProvider.notifier).refresh();
            },
          ),
          data: (devices) {
            final device = devices.isEmpty
                ? null
                : devices.firstWhere(
                    (device) => device.isSelected,
                    orElse: () => devices.first,
                  );

            if (device == null) {
              return const _EmptyDevicesState();
            }

            return DeviceSettingsPage(device: device);
          },
        );
      },
    );
  }

  /// 设备 Tab
  Widget _buildDeviceTab() {
    return CupertinoTabView(
      builder: (context) {
        final devicesAsync = ref.watch(deviceProvider);

        return devicesAsync.when(
          loading: () => const _LoadingState(message: '正在加载设备数据...'),
          error: (error, stack) => _ErrorState(
            title: '设备数据暂不可用',
            description: '请稍后重试；如果一直停留在这里，可以尝试重启应用。',
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
                    ...devices.map(_buildDeviceCard),
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

  /// 设备信息卡片
  Widget _buildDeviceInfo(Device device) {
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
  Widget _buildStatusSection(ControlState controlState) {
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
                  Text(controlState.currentEffect?.displayName ?? '未知'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('亮度'),
                  Text('${controlState.currentBrightness ?? 0}'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建高级选项
  Widget _buildAdvancedOptions(Device device) {
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
          onTap: () => _refreshStatus(device),
        ),
        _buildOptionTile(
          icon: CupertinoIcons.forward_end,
          title: '下一个效果',
          onTap: () => _nextEffect(device),
        ),
        _buildOptionTile(
          icon: CupertinoIcons.backward_end,
          title: '上一个效果',
          onTap: () => _previousEffect(device),
        ),
      ],
    );
  }

  Widget _buildQuickActionsForIp(String ipAddress) {
    final actions = [
      _QuickEffectAction('彩虹', LEDEffect.rainbow, CupertinoIcons.sparkles),
      _QuickEffectAction('呼吸', LEDEffect.breathing, CupertinoIcons.wind),
      _QuickEffectAction('火焰', LEDEffect.fire, CupertinoIcons.flame),
      _QuickEffectAction('星空', LEDEffect.starry, CupertinoIcons.star),
      _QuickEffectAction('波浪', LEDEffect.wave, CupertinoIcons.waveform),
      _QuickEffectAction('追逐', LEDEffect.chase, CupertinoIcons.arrow_right_circle),
      _QuickEffectAction('闪烁', LEDEffect.flash, CupertinoIcons.bolt),
      _QuickEffectAction('贪吃蛇', LEDEffect.snake, CupertinoIcons.gamecontroller),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快捷效果',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: actions
              .map(
                (action) => _buildQuickActionButton(
                  icon: action.icon,
                  label: action.label,
                  onTap: () async {
                    final result = await ref
                        .read(lEDControlProvider.notifier)
                        .setEffect(ipAddress: ipAddress, effect: action.effect);
                    if (!mounted) return;
                    if (result.isSuccess) {
                      _showSuccessDialog('已切换到${action.label}效果');
                    } else {
                      _showErrorDialog(result.error ?? '切换失败');
                    }
                  },
                ),
              )
              .toList(),
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
  Widget _buildDeviceCard(Device device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: device.isSelected
            ? CupertinoColors.systemBlue.withOpacity(0.08)
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: device.isSelected
            ? Border.all(color: CupertinoColors.systemBlue)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: device.isSelected
                      ? null
                      : () async {
                          await ref.read(deviceProvider.notifier).selectDevice(device.id);
                        },
                  child: Text(device.isSelected ? '当前设备' : '设为当前设备'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建添加设备按钮
  Widget _buildAddDeviceButton() {
    return CupertinoButton.filled(
      onPressed: _openAddDeviceSheet,
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

class _QuickEffectAction {
  const _QuickEffectAction(this.label, this.effect, this.icon);

  final String label;
  final LEDEffect effect;
  final IconData icon;
}

/// 加载状态
class _LoadingState extends StatelessWidget {
  final String message;

  const _LoadingState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(radius: 16),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

/// 错误状态
class _ErrorState extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.title,
    required this.description,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.info_circle,
            size: 64,
            color: CupertinoColors.systemOrange,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              description,
              textAlign: TextAlign.center,
            ),
          ),
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
            onPressed: () {},
            child: const Text('添加设备'),
          ),
        ],
      ),
    );
  }
}
