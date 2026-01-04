import 'package:flutter/material.dart';
import '../../utils/hanfu_animations.dart';
import '../../utils/theme.dart';
import '../../widgets/animated_hanfu_card.dart';
import '../../widgets/animated_hanfu_icon.dart';

/// 动画测试页面 - 用于验证动画效果
class AnimationTestScreen extends StatefulWidget {
  const AnimationTestScreen({Key? key}) : super(key: key);

  @override
  State<AnimationTestScreen> createState() => _AnimationTestScreenState();
}

class _AnimationTestScreenState extends State<AnimationTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动画效果测试'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '卡片进入动画测试',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 测试卡片动画
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
                        Text(
                          '测试卡片 ${index + 1}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 32),
            const Text(
              '图标动画测试',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const AnimatedHanfuIcon(
                        icon: Icons.auto_awesome_rounded,
                        size: 48,
                        color: AppTheme.primaryColor,
                        enableBreathingAnimation: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('呼吸动画'),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const AnimatedHanfuIcon(
                        icon: Icons.checkroom_rounded,
                        size: 48,
                        color: AppTheme.primaryColor,
                        enableFlowAnimation: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('流动动画'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              '对比：无动画',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.checkroom_rounded,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 16),
                  Text('无动画图标'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

