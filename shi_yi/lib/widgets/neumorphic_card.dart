import 'package:flutter/material.dart';

/// 新拟态风格卡片组件
class NeumorphicCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool isPressed;

  const NeumorphicCard({
    Key? key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.isPressed = false,
  }) : super(key: key);

  @override
  State<NeumorphicCard> createState() => _NeumorphicCardState();
}

class _NeumorphicCardState extends State<NeumorphicCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
      // 直接调用onTap，因为已经移除了InkWell的onTap
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  // 根据卡片宽度生成阴影效果
  List<BoxShadow> _generateShadows(double cardWidth, double screenWidth, bool isPressed) {
    final isLargeCard = cardWidth > screenWidth * 0.5;
    
    if (isPressed) {
      // 按下时：内凹效果（使用较小的阴影）
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 2,
          offset: const Offset(1.5, 1.5),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.75),
          blurRadius: 2,
          offset: const Offset(-1.5, -1.5),
        ),
      ];
    }
    
    if (isLargeCard) {
      // 大卡片：使用更柔和、更平衡的阴影
      return [
        // 主阴影：更柔和，减少右侧视觉重量
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(4, 4),
          spreadRadius: -2, // 负值使阴影更柔和
        ),
        // 高光：增强左侧亮度，平衡视觉
        BoxShadow(
          color: Colors.white.withOpacity(0.95),
          blurRadius: 12,
          offset: const Offset(-4, -4),
          spreadRadius: -2,
        ),
        // 额外的柔和阴影：增强整体立体感
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
    } else {
      // 小卡片：使用标准阴影
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(5, 5),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.9),
          blurRadius: 10,
          offset: const Offset(-5, -5),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPressed = widget.isPressed || _isPressed;
    final bgColor = widget.backgroundColor ?? Colors.white;
    final borderRadius = widget.borderRadius ?? 20.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 获取屏幕宽度
              final screenWidth = MediaQuery.of(context).size.width;
              // 计算卡片宽度（减去margin）
              final margin = widget.margin ?? const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              );
              final cardWidth = constraints.maxWidth - margin.horizontal;
              
              return Container(
                margin: margin,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: _generateShadows(cardWidth, screenWidth, isPressed),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    // 移除onTap，只使用onTapUp来触发，避免重复调用
                    onTapDown: _handleTapDown,
                    onTapUp: _handleTapUp,
                    onTapCancel: _handleTapCancel,
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Padding(
                      padding: widget.padding ?? const EdgeInsets.all(20),
                      child: widget.child,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// 新拟态风格按钮
class NeumorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsets? padding;

  const NeumorphicButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? const Color(0xFFF5F5F5);
    final textColor = widget.textColor ?? Colors.black87;
    final borderRadius = widget.borderRadius ?? 16.0;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = true);
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onPressed?.call();
        }
      },
      onTapCancel: () {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: _isPressed
                    ? [
                        // 按下时：内凹效果（使用较小的阴影）
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 2,
                          offset: const Offset(1.5, 1.5),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.75),
                          blurRadius: 2,
                          offset: const Offset(-1.5, -1.5),
                        ),
                      ]
                    : [
                        // 正常状态：凸起效果（优化后的阴影）
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(4, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 10,
                          offset: const Offset(-4, -4),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
