import 'package:flutter/material.dart';
import '../utils/hanfu_animations.dart';
import '../utils/theme.dart';

/// 带汉服动画效果的图标组件
class AnimatedHanfuIcon extends StatefulWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final bool enableFlowAnimation; // 是否启用流动动画
  final bool enableBreathingAnimation; // 是否启用呼吸动画

  const AnimatedHanfuIcon({
    Key? key,
    required this.icon,
    this.size,
    this.color,
    this.enableFlowAnimation = false,
    this.enableBreathingAnimation = false,
  }) : super(key: key);

  @override
  State<AnimatedHanfuIcon> createState() => _AnimatedHanfuIconState();
}

class _AnimatedHanfuIconState extends State<AnimatedHanfuIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.enableFlowAnimation) {
      _controller = AnimationController(
        duration: const Duration(seconds: 2), // 加快速度，更明显
        vsync: this,
      );
      // 确保在下一帧启动
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.repeat(); // 启动循环动画
        }
      });
    } else if (widget.enableBreathingAnimation) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), // 加快速度，更明显（1.5秒）
        vsync: this,
      );
      // 确保在下一帧启动
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.repeat(reverse: true); // 启动呼吸动画（往返循环）
        }
      });
    } else {
      _controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      widget.icon,
      size: widget.size ?? 24,
      color: widget.color ?? AppTheme.primaryColor,
    );

    if (widget.enableFlowAnimation) {
      iconWidget = HanfuAnimations.createFlowAnimation(
        controller: _controller,
        flowColor: widget.color,
        opacity: 0.9, // 大幅增强流动效果可见性
        child: iconWidget,
      );
    } else if (widget.enableBreathingAnimation) {
      iconWidget = HanfuAnimations.createBreathingAnimation(
        controller: _controller,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}

