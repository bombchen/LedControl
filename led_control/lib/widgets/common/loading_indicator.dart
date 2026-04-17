import 'package:flutter/material.dart';

/// 加载指示器组件
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.message = '加载中...',
    this.size = 40.0,
  });

  final String message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 小型加载指示器（用于列表等）
class SmallLoadingIndicator extends StatelessWidget {
  const SmallLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

/// 带背景的加载指示器
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    this.message = '加载中...',
    this.isBarrierDismissible = false,
  });

  final String message;
  final bool isBarrierDismissible;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
