import 'package:flutter/material.dart';

// 拾衣坊 - 清新国风转场动效工具类
class ShiyiTransition {
  // 1. 衣袂轻扬转场（优先级最高，贴合汉服主题）
  // 场景：衣橱 -> 详情页、常规页面切换
  static Route<T> freshSlideTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(
            curve: const Interval(0.0, 1.0, curve: Curves.easeInOutQuad),
          )).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.6, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // 2. 水墨晕染转场（清新国风代表）
  // 场景：卡片点击进入详情页、图标触发页面
  static Route<T> inkSpreadTransition<T>(Widget page, Offset tapPosition) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final size = MediaQuery.of(context).size;
        final circleAnimation = Tween<double>(
          begin: 0.0,
          end: size.longestSide * 1.5,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCirc,
        ));

        return ClipPath(
          clipper: _CircleClipper(
            radius: circleAnimation.value,
            center: tapPosition,
          ),
          child: child,
        );
      },
    );
  }

  // 3. 竹叶轻摆转场（极简清新）
  // 场景：轻量级页面切换（设置页、分类页）
  static Route<T> bambooSwayTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // 透视效果
            ..rotateY(animation.value * 0.1) // 轻微倾斜
            ..translate(
              animation.value * MediaQuery.of(context).size.width - MediaQuery.of(context).size.width,
              0,
            ),
          alignment: Alignment.centerRight,
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.7, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  // 4. 卷轴展开转场（国风+清新）
  // 场景：3D模型展示页、弹窗式页面
  static Route<T> scrollUnfoldTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // 5. 线香绕圈转场（小众清新）
  // 场景：功能入口页面（3D试穿、穿搭推荐）
  static Route<T> incenseCircleTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 900),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(begin: 0.1, end: 0.0).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.5, 0.2), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutSine),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// 圆形裁剪器（水墨晕染转场核心）
class _CircleClipper extends CustomClipper<Path> {
  final double radius;
  final Offset center;

  _CircleClipper({required this.radius, required this.center});

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(_CircleClipper oldClipper) => true;
}
