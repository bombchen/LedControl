import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:led_control/core/models/led_effect.dart';

/// 效果网格组件 - 2x4 布局显示 8 种效果
class EffectGrid extends StatelessWidget {
  final LEDEffect currentEffect;
  final ValueChanged<LEDEffect> onEffectSelected;

  const EffectGrid({
    super.key,
    required this.currentEffect,
    required this.onEffectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: LEDEffect.values.map((effect) {
        final isSelected = effect == currentEffect;
        return _EffectGridItem(
          effect: effect,
          isSelected: isSelected,
          onTap: () => onEffectSelected(effect),
        );
      }).toList(),
    );
  }
}

/// 效果网格项
class _EffectGridItem extends StatelessWidget {
  final LEDEffect effect;
  final bool isSelected;
  final VoidCallback onTap;

  const _EffectGridItem({
    required this.effect,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemBlue.withOpacity(0.1)
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.systemBlue
                : CupertinoColors.systemGrey4,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.systemBlue.withOpacity(0.2)
                    : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  effect.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 名称
            Text(
              effect.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.label,
              ),
            ),
            // 选中指示器
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 效果列表视图（用于设置页面）
class EffectList extends StatelessWidget {
  final LEDEffect currentEffect;
  final ValueChanged<LEDEffect> onEffectSelected;

  const EffectList({
    super.key,
    required this.currentEffect,
    required this.onEffectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: LEDEffect.values.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 60,
      ),
      itemBuilder: (context, index) {
        final effect = LEDEffect.values[index];
        final isSelected = effect == currentEffect;

        return _EffectListItem(
          effect: effect,
          isSelected: isSelected,
          onTap: () => onEffectSelected(effect),
        );
      },
    );
  }
}

/// 效果列表项
class _EffectListItem extends StatelessWidget {
  final LEDEffect effect;
  final bool isSelected;
  final VoidCallback onTap;

  const _EffectListItem({
    required this.effect,
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
            // 图标
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.systemBlue.withOpacity(0.2)
                    : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  effect.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 名称
            Expanded(
              child: Text(
                effect.displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.label,
                ),
              ),
            ),
            // 选中指示器
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
