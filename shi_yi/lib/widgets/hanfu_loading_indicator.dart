import 'package:flutter/material.dart';
import '../utils/hanfu_animations.dart';
import '../utils/theme.dart';

/// 汉服主题的加载指示器
class HanfuLoadingIndicator extends StatefulWidget {
  final String? message;
  final Color? color;
  final double size;

  const HanfuLoadingIndicator({
    Key? key,
    this.message,
    this.color,
    this.size = 50.0,
  }) : super(key: key);

  @override
  State<HanfuLoadingIndicator> createState() => _HanfuLoadingIndicatorState();
}

class _HanfuLoadingIndicatorState extends State<HanfuLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 汉服纹理渐变加载动画
        HanfuAnimations.createTextureLoadingAnimation(
          controller: _controller,
          primaryColor: widget.color ?? AppTheme.primaryColor,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (widget.color ?? AppTheme.primaryColor).withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: widget.color ?? AppTheme.primaryColor,
                size: widget.size * 0.5,
              ),
            ),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              color: widget.color ?? AppTheme.primaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

