import 'package:flutter/material.dart';
import '../utils/hanfu_animations.dart';
import 'neumorphic_card.dart';

/// 带汉服动画效果的卡片组件
class AnimatedHanfuCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final int index; // 用于层次动画
  final bool enableEntranceAnimation; // 是否启用进入动画

  const AnimatedHanfuCard({
    Key? key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.index = 0,
    this.enableEntranceAnimation = true,
  }) : super(key: key);

  @override
  State<AnimatedHanfuCard> createState() => _AnimatedHanfuCardState();
}

class _AnimatedHanfuCardState extends State<AnimatedHanfuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: HanfuAnimations.normal,
      vsync: this,
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: HanfuAnimations.gentleCurve,
    );

    if (widget.enableEntranceAnimation) {
      // 立即启动动画
      // 使用 SchedulerBinding 确保在下一帧启动
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // 根据index设置很小的延迟，创建层次感
          final delay = widget.index * 50;
          if (delay == 0) {
            // index为0时立即启动
            _entranceController.forward();
          } else {
            Future.delayed(Duration(milliseconds: delay), () {
              if (mounted) {
                _entranceController.forward();
              }
            });
          }
        }
      });
    } else {
      _entranceController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HanfuAnimations.createLayeredAnimation(
      animation: _entranceAnimation,
      index: widget.index,
      child: NeumorphicCard(
        onTap: widget.onTap,
        margin: widget.margin,
        padding: widget.padding,
        backgroundColor: widget.backgroundColor,
        borderRadius: widget.borderRadius,
        child: widget.child,
      ),
    );
  }
}

