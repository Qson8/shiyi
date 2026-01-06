import 'package:flutter/material.dart';

// 拾衣坊 - 清新国风转场动效工具类
class ShiyiTransition {
  // 1. 衣袂轻扬转场（优先级最高，贴合汉服主题）
  // 场景：衣橱 -> 详情页、常规页面切换
  // 使用简单的淡入淡出转场，稳定流畅
  static Route<T> freshSlideTransition<T>(Widget page) {
    return _CustomPageRoute<T>(
      page: page,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 只使用淡入淡出，去掉滑动动画，避免闪烁
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
          child: child,
        );
      },
    );
  }

  // 2. 水墨晕染转场（清新国风代表）
  // 场景：卡片点击进入详情页、图标触发页面
  static Route<T> inkSpreadTransition<T>(Widget page, Offset tapPosition) {
    return _CustomPageRoute<T>(
      page: page,
      transitionDuration: const Duration(milliseconds: 700),
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
    return _CustomPageRoute<T>(
      page: page,
      transitionDuration: const Duration(milliseconds: 500),
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
    return _CustomPageRoute<T>(
      page: page,
      transitionDuration: const Duration(milliseconds: 800),
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
    return _CustomPageRoute<T>(
      page: page,
      transitionDuration: const Duration(milliseconds: 900),
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

// 自定义页面路由 - 支持手势返回
class _CustomPageRoute<T> extends PageRoute<T> {
  final Widget page;
  final Duration _transitionDuration;
  final Duration _reverseTransitionDuration;
  final Widget Function(BuildContext, Animation<double>, Animation<double>, Widget) transitionsBuilder;

  _CustomPageRoute({
    required this.page,
    required Duration transitionDuration,
    Duration? reverseTransitionDuration,
    required this.transitionsBuilder,
  })  : _transitionDuration = transitionDuration,
        _reverseTransitionDuration = reverseTransitionDuration ?? const Duration(milliseconds: 300);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Duration get reverseTransitionDuration => _reverseTransitionDuration;

  @override
  bool get opaque => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return transitionsBuilder(context, animation, secondaryAnimation, child);
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
