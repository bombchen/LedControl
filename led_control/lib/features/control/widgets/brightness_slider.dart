import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 亮度滑块组件
class BrightnessSlider extends ConsumerStatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;
  final String? deviceIp;

  const BrightnessSlider({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.deviceIp,
  });

  @override
  ConsumerState<BrightnessSlider> createState() => _BrightnessSliderState();
}

class _BrightnessSliderState extends ConsumerState<BrightnessSlider> {
  late int _currentValue;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(BrightnessSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _currentValue = widget.initialValue;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onValueChanged(double value) {
    final intValue = value.round();
    setState(() {
      _currentValue = intValue;
    });

    // 防抖处理：避免频繁发送命令
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged(intValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.sun_min,
                    size: 20,
                    color: CupertinoColors.systemGrey,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '亮度',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_currentValue',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                CupertinoIcons.minus_circle,
                size: 20,
                color: CupertinoColors.systemGrey,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CupertinoSlider(
                    value: _currentValue.toDouble(),
                    min: 0,
                    max: 255,
                    divisions: 255,
                    activeColor: CupertinoColors.systemYellow,
                    thumbColor: CupertinoColors.systemYellow,
                    onChanged: _onValueChanged,
                  ),
                ),
              ),
              const Icon(
                CupertinoIcons.plus_circle,
                size: 20,
                color: CupertinoColors.systemGrey,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickAdjustButton(0),
                _buildQuickAdjustButton(64),
                _buildQuickAdjustButton(128),
                _buildQuickAdjustButton(192),
                _buildQuickAdjustButton(255),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAdjustButton(int value) {
    final isSelected = _currentValue == value;
    return GestureDetector(
      onTap: () => _onValueChanged(value.toDouble()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemYellow
              : CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? CupertinoColors.white : CupertinoColors.systemGrey,
          ),
        ),
      ),
    );
  }
}
