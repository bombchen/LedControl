import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

/// LED 效果预览动画组件
class EffectPreview extends StatefulWidget {
  final String effect;

  const EffectPreview({
    super.key,
    required this.effect,
  });

  @override
  State<EffectPreview> createState() => _EffectPreviewState();
}

class _EffectPreviewState extends State<EffectPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.systemGrey6,
            CupertinoColors.systemGrey5,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildEffectAnimation(),
    );
  }

  Widget _buildEffectAnimation() {
    switch (widget.effect.toLowerCase()) {
      case 'rainbow':
        return _buildRainbowEffect();
      case 'breathing':
        return _buildBreathingEffect();
      case 'fire':
        return _buildFireEffect();
      case 'starry':
        return _buildStarryEffect();
      case 'wave':
        return _buildWaveEffect();
      case 'chase':
        return _buildChaseEffect();
      case 'flash':
        return _buildFlashEffect();
      case 'snake':
        return _buildSnakeEffect();
      default:
        return _buildDefaultEffect();
    }
  }

  /// 彩虹效果
  Widget _buildRainbowEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RainbowPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }

  /// 呼吸效果
  Widget _buildBreathingEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final brightness = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                CupertinoColors.systemRed.withOpacity(brightness),
                CupertinoColors.systemRed.withOpacity(brightness * 0.5),
                CupertinoColors.systemRed.withOpacity(brightness * 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  /// 火焰效果
  Widget _buildFireEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _FirePainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }

  /// 星空效果
  Widget _buildStarryEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarryPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }

  /// 波浪效果
  Widget _buildWaveEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }

  /// 追逐效果
  Widget _buildChaseEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ChasePainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }

  /// 闪烁效果
  Widget _buildFlashEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = (math.sin(_controller.value * 10 * math.pi) + 1) / 2;
        return Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemYellow.withOpacity(opacity),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              CupertinoIcons.bolt_fill,
              size: 40,
              color: CupertinoColors.white,
            ),
          ),
        );
      },
    );
  }

  /// 贪吃蛇效果
  Widget _buildSnakeEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SnakePainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }

  /// 默认效果
  Widget _buildDefaultEffect() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.lightbulb,
            size: 40,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(height: 8),
          Text(
            '效果预览',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// 彩虹效果绘制器
class _RainbowPainter extends CustomPainter {
  final double animationValue;

  _RainbowPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFF0000),
      const Color(0xFFFF7F00),
      const Color(0xFFFFFF00),
      const Color(0xFF00FF00),
      const Color(0xFF0000FF),
      const Color(0xFF4B0082),
      const Color(0xFF9400D3),
    ];

    final shader = LinearGradient(
      colors: colors,
      stops: List.generate(colors.length, (i) => i / (colors.length - 1)),
      begin: Alignment(-1 + animationValue * 2, -1),
      end: Alignment(1 - animationValue * 2, 1),
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 火焰效果绘制器
class _FirePainter extends CustomPainter {
  final double animationValue;

  _FirePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random();
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height - (random.nextDouble() * size.height * 0.8);
      final radius = 5 + random.nextDouble() * 15;

      final colorValue = (animationValue + i * 0.1) % 1.0;
      final color = Color.lerp(
        const Color(0xFFFF4500),
        const Color(0xFFFFFF00),
        colorValue,
      )!;

      canvas.drawCircle(
        Offset(x, y),
        radius * (0.8 + 0.4 * math.sin(animationValue * 2 * math.pi + i)),
        paint..color = color.withOpacity(0.6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 星空效果绘制器
class _StarryPainter extends CustomPainter {
  final double animationValue;

  _StarryPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // 背景
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1a1a2e),
    );

    // 星星
    final random = math.Random(42);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final baseRadius = 1 + random.nextDouble() * 2;

      final twinkle = (math.sin(animationValue * 4 * math.pi + i * 0.5) + 1) / 2;
      final color = Color.lerp(
        const Color(0xFF4169E1),
        const Color(0xFFFFFFFF),
        twinkle,
      )!;

      canvas.drawCircle(
        Offset(x, y),
        baseRadius * twinkle,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 波浪效果绘制器
class _WavePainter extends CustomPainter {
  final double animationValue;

  _WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      CupertinoColors.systemBlue,
      CupertinoColors.systemPurple,
      CupertinoColors.systemPink,
    ];

    for (int i = 0; i < colors.length; i++) {
      final path = Path();
      final waveOffset = animationValue * 2 * math.pi + i * 0.5;

      path.moveTo(0, size.height);
      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height * 0.5 +
            20 * math.sin(x * 0.02 + waveOffset) +
            10 * math.sin(x * 0.04 + waveOffset * 1.5);
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..color = colors[i].withOpacity(0.5)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 追逐效果绘制器
class _ChasePainter extends CustomPainter {
  final double animationValue;

  _ChasePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      CupertinoColors.systemRed,
      CupertinoColors.systemYellow,
      CupertinoColors.systemGreen,
    ];

    final dotCount = 12;
    final radius = size.width * 0.35;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount * 2 * math.pi) + (animationValue * 2 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.drawCircle(
        Offset(x, y),
        8,
        Paint()..color = colors[i % colors.length],
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 贪吃蛇效果绘制器
class _SnakePainter extends CustomPainter {
  final double animationValue;

  _SnakePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final segmentCount = 15;
    final segmentSize = size.width / (segmentCount + 2);

    for (int i = 0; i < segmentCount; i++) {
      final position = (animationValue + i / segmentCount) % 1.0;
      final x = position * (size.width - segmentSize);
      final y = size.height / 2 + 10 * math.sin(position * 4 * math.pi);

      final color = HSLColor.fromAHSL(
        1.0,
        (animationValue + i * 0.1) % 1.0,
        0.7,
        0.5,
      ).toColor();

      canvas.drawCircle(
        Offset(x + segmentSize / 2, y),
        segmentSize / 2 - 2,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
