import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// 配置步骤枚举
enum ConfigStep {
  connectHotspot, // 连接到 LED_Config 热点
  selectWiFi, // 选择家庭 WiFi
  enterPassword, // 输入 WiFi 密码
  configuring, // 配置中
  waitingReboot, // 等待设备重启
  complete, // 完成
}

/// WiFi 配置进度组件
class ConfigProgress extends StatefulWidget {
  final ConfigStep currentStep;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ConfigProgress({
    super.key,
    required this.currentStep,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<ConfigProgress> createState() => _ConfigProgressState();
}

class _ConfigProgressState extends State<ConfigProgress> {
  Timer? _progressTimer;
  double _progressValue = 0.0;

  @override
  void didUpdateWidget(ConfigProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      _resetProgress();
      if (widget.currentStep == ConfigStep.configuring ||
          widget.currentStep == ConfigStep.waitingReboot) {
        _startProgress();
      }
    }
  }

  void _resetProgress() {
    setState(() {
      _progressValue = 0.0;
    });
    _progressTimer?.cancel();
  }

  void _startProgress() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _progressValue += 0.01;
          if (_progressValue >= 1.0) {
            _progressValue = 0.95; // 保持不完全填满，直到真正完成
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Text(
            '配置进度',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // 步骤列表
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = index < steps.indexOf(widget.currentStep);
            final isCurrent = step == widget.currentStep;
            final isPending = index > steps.indexOf(widget.currentStep);

            return _StepIndicator(
              stepNumber: index + 1,
              title: _getStepTitle(step),
              description: _getStepDescription(step),
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isPending: isPending,
              showProgress: isCurrent &&
                  (step == ConfigStep.configuring ||
                      step == ConfigStep.waitingReboot),
              progressValue: _progressValue,
            );
          }).toList(),

          // 错误信息
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CupertinoColors.systemRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.xmark_circle,
                    color: CupertinoColors.systemRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.errorMessage!,
                      style: const TextStyle(
                        color: CupertinoColors.systemRed,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (widget.onRetry != null)
              CupertinoButton.filled(
                onPressed: widget.onRetry,
                child: const Text('重试'),
              ),
          ],
        ],
      ),
    );
  }

  List<ConfigStep> _buildSteps() {
    return ConfigStep.values.where((step) => step != ConfigStep.complete).toList();
  }

  String _getStepTitle(ConfigStep step) {
    switch (step) {
      case ConfigStep.connectHotspot:
        return '连接设备热点';
      case ConfigStep.selectWiFi:
        return '选择 WiFi 网络';
      case ConfigStep.enterPassword:
        return '输入 WiFi 密码';
      case ConfigStep.configuring:
        return '配置设备';
      case ConfigStep.waitingReboot:
        return '等待设备重启';
      case ConfigStep.complete:
        return '配置完成';
    }
  }

  String _getStepDescription(ConfigStep step) {
    switch (step) {
      case ConfigStep.connectHotspot:
        return '连接到 "LED_Config" WiFi 热点';
      case ConfigStep.selectWiFi:
        return '选择您家庭 WiFi 网络';
      case ConfigStep.enterPassword:
        return '输入 WiFi 密码';
      case ConfigStep.configuring:
        return '正在向设备发送配置...';
      case ConfigStep.waitingReboot:
        return '设备正在重启，请稍候...';
      case ConfigStep.complete:
        return '配置已成功完成';
    }
  }
}

/// 步骤指示器
class _StepIndicator extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isCurrent;
  final bool isPending;
  final bool showProgress;
  final double progressValue;

  const _StepIndicator({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isCurrent,
    required this.isPending,
    this.showProgress = false,
    this.progressValue = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 步骤图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? CupertinoColors.systemGreen
                  : isCurrent
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.systemGrey5,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      CupertinoIcons.check_mark,
                      color: CupertinoColors.white,
                      size: 18,
                    )
                  : isCurrent
                      ? const CupertinoActivityIndicator(
                          radius: 10,
                          color: CupertinoColors.white,
                        )
                      : Text(
                          stepNumber.toString(),
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
            ),
          ),

          const SizedBox(width: 12),

          // 步骤信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isPending
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                if (showProgress) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: CupertinoColors.systemGrey5,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        CupertinoColors.systemBlue,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 配置成功动画
class ConfigSuccessAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const ConfigSuccessAnimation({
    super.key,
    this.onComplete,
  });

  @override
  State<ConfigSuccessAnimation> createState() => _ConfigSuccessAnimationState();
}

class _ConfigSuccessAnimationState extends State<ConfigSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();

    // 2秒后自动完成
    Future.delayed(const Duration(seconds: 2), () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGreen.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.check_mark,
                size: 48,
                color: CupertinoColors.systemGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '配置成功',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '设备已连接到 WiFi',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
