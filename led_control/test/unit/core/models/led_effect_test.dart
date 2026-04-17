import 'package:flutter_test/flutter_test.dart';
import 'package:led_control/core/models/led_effect.dart';

void main() {
  group('LEDEffect', () {
    test('应该有8种效果', () {
      expect(LEDEffect.values.length, 8);
    });

    test('每种效果应该有正确的显示名称', () {
      expect(LEDEffect.rainbow.displayName, '彩虹');
      expect(LEDEffect.breathing.displayName, '呼吸');
      expect(LEDEffect.fire.displayName, '火焰');
      expect(LEDEffect.starry.displayName, '星空');
      expect(LEDEffect.wave.displayName, '波浪');
      expect(LEDEffect.chase.displayName, '追逐');
      expect(LEDEffect.flash.displayName, '闪烁');
      expect(LEDEffect.snake.displayName, '贪吃蛇');
    });

    test('每种效果应该有正确的命令值', () {
      expect(LEDEffect.rainbow.commandValue, 'rainbow');
      expect(LEDEffect.breathing.commandValue, 'breathing');
      expect(LEDEffect.fire.commandValue, 'fire');
      expect(LEDEffect.starry.commandValue, 'starry');
      expect(LEDEffect.wave.commandValue, 'wave');
      expect(LEDEffect.chase.commandValue, 'chase');
      expect(LEDEffect.flash.commandValue, 'flash');
      expect(LEDEffect.snake.commandValue, 'snake');
    });

    test('应该能从命令值解析效果', () {
      expect(LEDEffect.fromCommandValue('rainbow'), LEDEffect.rainbow);
      expect(LEDEffect.fromCommandValue('breathing'), LEDEffect.breathing);
      expect(LEDEffect.fromCommandValue('fire'), LEDEffect.fire);
      expect(LEDEffect.fromCommandValue('starry'), LEDEffect.starry);
      expect(LEDEffect.fromCommandValue('wave'), LEDEffect.wave);
      expect(LEDEffect.fromCommandValue('chase'), LEDEffect.chase);
      expect(LEDEffect.fromCommandValue('flash'), LEDEffect.flash);
      expect(LEDEffect.fromCommandValue('snake'), LEDEffect.snake);
    });

    test('未知命令值应该返回彩虹效果作为默认', () {
      expect(LEDEffect.fromCommandValue('unknown'), LEDEffect.rainbow);
    });
  });
}
