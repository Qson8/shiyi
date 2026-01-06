import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/shiyi_color.dart';

/// 水墨流动背景组件
/// 实现文档要求的背景动效全域延伸效果
/// - 水墨粒子从模型中心向全屏扩散
/// - 留白区域粒子密度略低（透明度10%-12%）
/// - 模型区域密度稍高（透明度15%）
class InkWashBackground extends StatefulWidget {
  final Widget child;
  final Size screenSize;
  final Rect modelArea; // 模型区域（用于计算密度渐变）

  const InkWashBackground({
    Key? key,
    required this.child,
    required this.screenSize,
    required this.modelArea,
  }) : super(key: key);

  @override
  State<InkWashBackground> createState() => _InkWashBackgroundState();
}

class _InkWashBackgroundState extends State<InkWashBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // 初始化粒子（模拟水墨流动效果）
    _initializeParticles();
  }

  void _initializeParticles() {
    final random = math.Random();
    final centerX = widget.screenSize.width / 2;
    final centerY = widget.screenSize.height / 2;

    // 创建粒子，从中心向外扩散
    for (int i = 0; i < 30; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = random.nextDouble() * math.min(
        widget.screenSize.width,
        widget.screenSize.height,
      ) * 0.6;
      final x = centerX + math.cos(angle) * distance;
      final y = centerY + math.sin(angle) * distance;

      _particles.add(Particle(
        x: x,
        y: y,
        radius: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.5 + 0.2,
        angle: angle + (random.nextDouble() - 0.5) * 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 计算粒子在当前位置的透明度
  double _getParticleOpacity(double x, double y) {
    // 判断是否在模型区域内
    final inModelArea = widget.modelArea.contains(Offset(x, y));
    
    if (inModelArea) {
      // 模型区域：透明度15%
      return 0.15;
    } else {
      // 留白区域：透明度10%-12%
      return 0.11;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _InkWashPainter(
            particles: _particles,
            animationValue: _controller.value,
            screenSize: widget.screenSize,
            modelArea: widget.modelArea,
            getOpacity: _getParticleOpacity,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double radius;
  double speed;
  double angle;

  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.angle,
  });
}

class _InkWashPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final Size screenSize;
  final Rect modelArea;
  final double Function(double x, double y) getOpacity;

  _InkWashPainter({
    required this.particles,
    required this.animationValue,
    required this.screenSize,
    required this.modelArea,
    required this.getOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = ShiyiColor.primaryColor; // 竹青色

    // 绘制流动的水墨粒子
    for (final particle in particles) {
      // 更新粒子位置（缓慢流动）
      final offsetX = math.cos(particle.angle) * particle.speed * 2;
      final offsetY = math.sin(particle.angle) * particle.speed * 2;
      
      final currentX = particle.x + offsetX * math.sin(animationValue * 2 * math.pi);
      final currentY = particle.y + offsetY * math.cos(animationValue * 2 * math.pi);

      // 计算透明度
      final opacity = getOpacity(currentX, currentY);

      paint.color = ShiyiColor.primaryColor.withOpacity(opacity);
      
      // 绘制粒子（使用模糊效果模拟水墨晕染）
      canvas.drawCircle(
        Offset(currentX, currentY),
        particle.radius,
        paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // 绘制渐变背景（从模型中心向外扩散）
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    final maxRadius = math.max(screenSize.width, screenSize.height);

    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        ShiyiColor.primaryColor.withOpacity(0.15), // 模型区域
        ShiyiColor.primaryColor.withOpacity(0.12), // 过渡区域
        ShiyiColor.primaryColor.withOpacity(0.10), // 留白区域
        ShiyiColor.primaryColor.withOpacity(0.08), // 边缘区域
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: maxRadius,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, screenSize.width, screenSize.height),
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(_InkWashPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

