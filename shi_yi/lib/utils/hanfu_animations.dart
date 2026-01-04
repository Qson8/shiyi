import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';

/// 汉服主题动画工具类
/// 结合汉服元素设计的动画效果
class HanfuAnimations {
  // 动画时长常量
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration verySlow = Duration(milliseconds: 1000);

  // 动画曲线 - 汉服风格的柔和曲线
  static const Curve hanfuCurve = Curves.easeOutCubic; // 如汉服衣袖的飘逸
  static const Curve gentleCurve = Curves.easeInOut; // 如汉服展开的柔和
  static const Curve flowCurve = Curves.easeInOutSine; // 如汉服纹理的流动

  /// 1. 汉服衣袖飘动效果 - 用于页面转场
  /// 模拟汉服衣袖从一侧飘入的效果
  static Route<T> createSleeveTransition<T extends Object?>(
    Widget page, {
    Duration duration = normal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 主动画：从右侧滑入（如衣袖飘入）
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: hanfuCurve,
        ));

        // 淡入效果
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ));

        // 轻微缩放效果（如衣袖展开）
        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: gentleCurve,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// 2. 汉服展开效果 - 用于卡片进入动画
  /// 模拟汉服从中心展开的效果
  static Widget createExpandAnimation({
    required Widget child,
    required Animation<double> animation,
    Duration delay = Duration.zero,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // 从中心展开
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: gentleCurve,
        ));

        // 淡入
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
        ));

        // 轻微上移（如汉服展开时的上升感）
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: hanfuCurve,
        ));

        return FadeTransition(
          opacity: AlwaysStoppedAnimation(fadeAnimation.value),
          child: SlideTransition(
            position: AlwaysStoppedAnimation(slideAnimation.value),
            child: Transform.scale(
              scale: scaleAnimation.value,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  /// 3. 汉服纹理流动效果 - 用于图标动画
  /// 模拟汉服上纹理流动的视觉效果
  static Widget createFlowAnimation({
    required Widget child,
    required AnimationController controller,
    Color? flowColor,
    double opacity = 0.8, // 大幅增强流动效果的可见性
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // 创建流动的渐变遮罩
        // 直接使用controller.value，从-1.0到1.0循环
        final gradientValue = (controller.value * 2) - 1.0; // -1.0 到 1.0

        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(gradientValue - 0.5, 0),
              end: Alignment(gradientValue + 0.5, 0),
              colors: [
                Colors.transparent,
                (flowColor ?? AppTheme.primaryColor).withOpacity(opacity),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: child,
    );
  }

  /// 4. 汉服卷轴展开效果 - 用于页面切换
  /// 模拟古代卷轴展开的动画
  static Route<T> createScrollTransition<T extends Object?>(
    Widget page, {
    Duration duration = slow,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 从下往上展开（如卷轴展开）
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: gentleCurve,
        ));

        // 淡入
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// 5. 汉服纹理渐变加载动画
  /// 模拟汉服纹理逐渐显现的效果
  static Widget createTextureLoadingAnimation({
    required AnimationController controller,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ));

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (primaryColor ?? AppTheme.primaryColor).withOpacity(0.1 + animation.value * 0.2),
                (secondaryColor ?? AppTheme.primaryColor.withOpacity(0.5))
                    .withOpacity(0.1 + animation.value * 0.3),
                (primaryColor ?? AppTheme.primaryColor).withOpacity(0.1 + animation.value * 0.2),
              ],
              stops: [
                0.0,
                0.5 + animation.value * 0.2,
                1.0,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        );
      },
    );
  }

  /// 6. 汉服图案呼吸效果
  /// 模拟汉服图案的呼吸感（轻微缩放和透明度变化）
  static Widget createBreathingAnimation({
    required Widget child,
    required AnimationController controller,
    double minScale = 0.85, // 进一步增强缩放效果
    double maxScale = 1.0,
    double minOpacity = 0.5, // 进一步增强透明度变化
    double maxOpacity = 1.0,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // 使用正弦波创建呼吸效果
        final value = math.sin(controller.value * 2 * math.pi);
        final normalizedValue = (value + 1) / 2; // 归一化到 0-1

        final scale = minScale + (maxScale - minScale) * normalizedValue;
        final opacity = minOpacity + (maxOpacity - minOpacity) * normalizedValue;

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// 7. 汉服飘带效果 - 用于装饰性元素
  /// 模拟汉服飘带的飘动效果
  static Widget createRibbonAnimation({
    required Widget child,
    required AnimationController controller,
    double maxOffset = 5.0,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // 创建飘动的偏移
        final angle = controller.value * 2 * math.pi;
        final offsetX = math.sin(angle) * maxOffset;
        final offsetY = math.cos(angle) * maxOffset * 0.5;

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: Transform.rotate(
            angle: math.sin(angle) * 0.1,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// 8. 汉服层次展开效果 - 用于列表项
  /// 模拟汉服多层次的展开效果
  static Widget createLayeredAnimation({
    required Widget child,
    required Animation<double> animation,
    int index = 0,
    Duration delayPerItem = const Duration(milliseconds: 100),
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // 直接使用animation.value，确保动画立即生效
        // 增强动画效果，使其更明显
        final scale = 0.7 + (0.3 * animation.value); // 从0.7到1.0，更明显的缩放
        final opacity = animation.value;
        final slide = Offset(0, 40 * (1 - animation.value)); // 增加滑动距离到40

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: slide,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// 扩展方法：为AnimationController添加汉服动画
extension HanfuAnimationControllerExtension on AnimationController {
  /// 启动呼吸动画（循环）
  void startBreathing({Duration duration = const Duration(seconds: 2)}) {
    repeat(reverse: true);
  }

  /// 启动流动动画（循环）
  void startFlowing({Duration duration = const Duration(seconds: 3)}) {
    this.duration = duration;
    repeat();
  }

  /// 启动飘带动画（循环）
  void startRibbon({Duration duration = const Duration(seconds: 4)}) {
    this.duration = duration;
    repeat(reverse: true);
  }
}

