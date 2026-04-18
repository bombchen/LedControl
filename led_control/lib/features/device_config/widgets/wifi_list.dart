import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// WiFi 网络信息模型
class WiFiNetwork {
  final String ssid;
 final int signalStrength; // 0-100
  final bool isSecured;
  final String? bssid;

  WiFiNetwork({
    required this.ssid,
    required this.signalStrength,
    this.isSecured = true,
    this.bssid,
  });

  /// 信号强度图标
  String get signalIcon {
    if (signalStrength >= 80) return '📶';
    if (signalStrength >= 60) return '📶';
    if (signalStrength >= 40) return '📶';
    if (signalStrength >= 20) return '📶';
    return '📶';
  }

  /// 信号强度颜色
  CupertinoDynamicColor get signalColor {
    if (signalStrength >= 80) return CupertinoColors.systemGreen;
    if (signalStrength >= 60) return CupertinoColors.systemGreen;
    if (signalStrength >= 40) return CupertinoColors.systemYellow;
    if (signalStrength >= 20) return CupertinoColors.systemOrange;
    return CupertinoColors.systemRed;
  }
}

/// WiFi 网络列表组件
class WiFiList extends StatefulWidget {
  final ValueChanged<WiFiNetwork>? onNetworkSelected;
  final String? selectedSSID;

  const WiFiList({
    super.key,
    this.onNetworkSelected,
    this.selectedSSID,
  });

  @override
  State<WiFiList> createState() => _WiFiListState();
}

class _WiFiListState extends State<WiFiList> {
  bool _isScanning = false;
  List<WiFiNetwork> _networks = [];
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _networks = [];
    });

    // 模拟扫描过程
    await Future.delayed(const Duration(seconds: 2));

    // 模拟扫描到的网络
    final mockNetworks = [
      WiFiNetwork(
        ssid: 'Home_WiFi_5G',
        signalStrength: 95,
        isSecured: true,
      ),
      WiFiNetwork(
        ssid: 'Home_WiFi_2.4G',
        signalStrength: 88,
        isSecured: true,
      ),
      WiFiNetwork(
        ssid: 'Neighbor_Network',
        signalStrength: 65,
        isSecured: true,
      ),
      WiFiNetwork(
        ssid: 'Guest_Network',
        signalStrength: 45,
        isSecured: true,
      ),
      WiFiNetwork(
        ssid: 'Open_Network',
        signalStrength: 30,
        isSecured: false,
      ),
    ];

    setState(() {
      _isScanning = false;
      _networks = mockNetworks;
    });
  }

  void _refreshScan() {
    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(milliseconds: 500), _startScan);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 扫描按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.wifi,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isScanning ? '正在扫描 WiFi 网络...' : '发现 ${_networks.length} 个网络',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!_isScanning)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  onPressed: _refreshScan,
                  child: const Row(
                    children: [
                      Icon(CupertinoIcons.refresh, size: 16),
                      SizedBox(width: 4),
                      Text('刷新', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),

        // 网络列表
        if (_isScanning)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                CupertinoActivityIndicator(radius: 16),
                SizedBox(height: 16),
                Text('正在扫描附近的 WiFi 网络...'),
              ],
            ),
          )
        else if (_networks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.wifi_slash,
                  size: 48,
                  color: CupertinoColors.systemGrey,
                ),
                SizedBox(height: 16),
                Text('未发现 WiFi 网络'),
                SizedBox(height: 8),
                Text(
                  '请检查 WiFi 是否已开启',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _networks.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 68,
            ),
            itemBuilder: (context, index) {
              final network = _networks[index];
              final isSelected = network.ssid == widget.selectedSSID;

              return _WiFiListItem(
                network: network,
                isSelected: isSelected,
                onTap: () {
                  widget.onNetworkSelected?.call(network);
                },
              );
            },
          ),
      ],
    );
  }
}

/// WiFi 列表项
class _WiFiListItem extends StatelessWidget {
  final WiFiNetwork network;
  final bool isSelected;
  final VoidCallback onTap;

  const _WiFiListItem({
    required this.network,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isSelected
            ? CupertinoColors.systemBlue.withOpacity(0.1)
            : CupertinoColors.systemBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 信号强度图标
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: network.signalColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  network.signalIcon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 网络信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          network.ssid,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? CupertinoColors.systemBlue
                                : CupertinoColors.label,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (network.isSecured) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          CupertinoIcons.lock_fill,
                          size: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '信号: ${network.signalStrength}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 80,
                        height: 4,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey5,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: network.signalStrength / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: network.signalColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 选中指示器
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: CupertinoColors.systemBlue,
                size: 20,
              )
            else
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: CupertinoColors.systemGrey3,
              ),
          ],
        ),
      ),
    );
  }
}
