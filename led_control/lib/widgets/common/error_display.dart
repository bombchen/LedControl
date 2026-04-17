import 'package:flutter/material.dart';

/// 错误显示组件
class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.icon,
  });

  final String error;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 小型错误显示（用于卡片等）
class SmallErrorDisplay extends StatelessWidget {
  const SmallErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
  });

  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

/// 网络错误显示
class NetworkErrorDisplay extends StatelessWidget {
  const NetworkErrorDisplay({
    super.key,
    this.onRetry,
  }) : error = '网络连接失败，请检查网络设置';

  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      error: error,
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

/// 超时错误显示
class TimeoutErrorDisplay extends StatelessWidget {
  const TimeoutErrorDisplay({
    super.key,
    this.onRetry,
  }) : error = '请求超时，请稍后重试';

  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      error: error,
      icon: Icons.access_time,
      onRetry: onRetry,
    );
  }
}
