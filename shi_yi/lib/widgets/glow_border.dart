import 'package:flutter/material.dart';
import '../utils/shiyi_color.dart';

/// 竹青色轮廓辉光组件
/// 实现文档要求的辉光边界虚化处理
/// - 基础宽度2px
/// - 边缘虚化范围1-2px
/// - 透明度从模型边缘的100%降至留白边缘的20%
class GlowBorder extends StatelessWidget {
  final Widget child;

  const GlowBorder({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // 辉光层（绘制在模型区域边缘）
        Positioned.fill(
          child: CustomPaint(
            painter: _GlowBorderPainter(),
          ),
        ),
      ],
    );
  }
}

class _GlowBorderPainter extends CustomPainter {
  _GlowBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 计算模型区域的边界（相对于当前绘制区域）
    final left = 0.0;
    final top = 0.0;
    final right = size.width;
    final bottom = size.height;

    // 竹青色 (#91B493)
    final glowColor = ShiyiColor.primaryColor;

    // 绘制四边的辉光效果
    // 上边
    _drawGlowEdge(
      canvas,
      Offset(left, top),
      Offset(right, top),
      glowColor,
      true,
    );
    // 下边
    _drawGlowEdge(
      canvas,
      Offset(left, bottom),
      Offset(right, bottom),
      glowColor,
      true,
    );
    // 左边
    _drawGlowEdge(
      canvas,
      Offset(left, top),
      Offset(left, bottom),
      glowColor,
      false,
    );
    // 右边
    _drawGlowEdge(
      canvas,
      Offset(right, top),
      Offset(right, bottom),
      glowColor,
      false,
    );
  }

  void _drawGlowEdge(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    bool isHorizontal,
  ) {
    // 基础宽度2px，虚化范围1-2px
    final baseWidth = 2.0;
    final blurRange = 2.0;

    // 创建渐变画笔（从100%透明度到20%透明度）
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseWidth;

    // 绘制多层辉光实现虚化效果
    for (int i = 0; i < 3; i++) {
      final distance = i * 0.5;
      final opacity = 1.0 - (i * 0.3); // 从1.0到0.4
      
      paint.color = color.withOpacity(opacity);
      paint.maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        blurRange * (1 - i * 0.3),
      );

      if (isHorizontal) {
        // 水平边：向上和向下延伸
        canvas.drawLine(
          Offset(start.dx, start.dy - distance),
          Offset(end.dx, end.dy - distance),
          paint,
        );
        canvas.drawLine(
          Offset(start.dx, start.dy + distance),
          Offset(end.dx, end.dy + distance),
          paint,
        );
      } else {
        // 垂直边：向左和向右延伸
        canvas.drawLine(
          Offset(start.dx - distance, start.dy),
          Offset(end.dx - distance, end.dy),
          paint,
        );
        canvas.drawLine(
          Offset(start.dx + distance, start.dy),
          Offset(end.dx + distance, end.dy),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GlowBorderPainter oldDelegate) {
    return false; // 静态绘制，不需要重绘
  }
}

