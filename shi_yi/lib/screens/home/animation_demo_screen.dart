import 'package:flutter/material.dart';
import '../../utils/hanfu_animations.dart';
import '../../utils/theme.dart';
import '../../widgets/animated_hanfu_card.dart';
import '../../widgets/animated_hanfu_icon.dart';
import '../../widgets/hanfu_loading_indicator.dart';

/// 汉服动画演示页面
/// 展示所有汉服主题动画效果
class AnimationDemoScreen extends StatefulWidget {
  const AnimationDemoScreen({Key? key}) : super(key: key);

  @override
  State<AnimationDemoScreen> createState() => _AnimationDemoScreenState();
}

class _AnimationDemoScreenState extends State<AnimationDemoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _flowController;
  late AnimationController _ribbonController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _flowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _ribbonController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _flowController.dispose();
    _ribbonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('汉服动画演示'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. 卡片进入动画'),
            const SizedBox(height: 12),
            ...List.generate(3, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedHanfuCard(
                    index: index,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.checkroom_rounded,
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            '汉服卡片 ${index + 1}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 32),
            _buildSectionTitle('2. 图标动画效果'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const AnimatedHanfuIcon(
                      icon: Icons.auto_awesome_rounded,
                      size: 48,
                      enableBreathingAnimation: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '呼吸效果',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  children: [
                    const AnimatedHanfuIcon(
                      icon: Icons.checkroom_rounded,
                      size: 48,
                      enableFlowAnimation: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '流动效果',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('3. 加载动画'),
            const SizedBox(height: 12),
            const HanfuLoadingIndicator(
              message: '加载中...',
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('4. 飘带动画'),
            const SizedBox(height: 12),
            Center(
              child: HanfuAnimations.createRibbonAnimation(
                controller: _ribbonController,
                child: Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('5. 纹理渐变效果'),
            const SizedBox(height: 12),
            HanfuAnimations.createTextureLoadingAnimation(
              controller: _flowController,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '汉服纹理渐变',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
    );
  }
}

