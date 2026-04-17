/// LED 灯效枚举
enum LEDEffect {
  /// 彩虹色彩循环
  rainbow,

  /// 红色呼吸脉冲
  breathing,

  /// 随机闪烁火焰效果
  fire,

  /// 白色/蓝色星光闪烁
  starry,

  /// 正弦波颜色渐变
  wave,

  /// 三色追逐点
  chase,

  /// 随机多彩闪烁
  flash,

  /// 贪吃蛇动画
  snake;

  /// 获取效果的显示名称
  String get displayName {
    switch (this) {
      case LEDEffect.rainbow:
        return '彩虹';
      case LEDEffect.breathing:
        return '呼吸';
      case LEDEffect.fire:
        return '火焰';
      case LEDEffect.starry:
        return '星空';
      case LEDEffect.wave:
        return '波浪';
      case LEDEffect.chase:
        return '追逐';
      case LEDEffect.flash:
        return '闪烁';
      case LEDEffect.snake:
        return '贪吃蛇';
    }
  }

  /// 获取效果的命令值（用于 UDP 通信）
  String get commandValue {
    switch (this) {
      case LEDEffect.rainbow:
        return 'rainbow';
      case LEDEffect.breathing:
        return 'breathing';
      case LEDEffect.fire:
        return 'fire';
      case LEDEffect.starry:
        return 'starry';
      case LEDEffect.wave:
        return 'wave';
      case LEDEffect.chase:
        return 'chase';
      case LEDEffect.flash:
        return 'flash';
      case LEDEffect.snake:
        return 'snake';
    }
  }

  /// 从命令值解析效果
  static LEDEffect fromCommandValue(String value) {
    return LEDEffect.values.firstWhere(
      (effect) => effect.commandValue == value,
      orElse: () => LEDEffect.rainbow,
    );
  }

  /// 获取效果的图标
  String get icon {
    switch (this) {
      case LEDEffect.rainbow:
        return '🌈';
      case LEDEffect.breathing:
        return '💨';
      case LEDEffect.fire:
        return '🔥';
      case LEDEffect.starry:
        return '⭐';
      case LEDEffect.wave:
        return '🌊';
      case LEDEffect.chase:
        return '💫';
      case LEDEffect.flash:
        return '✨';
      case LEDEffect.snake:
        return '🐍';
    }
  }
}
