import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/animated_hanfu_card.dart';
import '../../widgets/animated_hanfu_icon.dart';
import '../../widgets/simple_animated_card.dart';
import 'animation_test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            // 可以添加侧边栏
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.animation_rounded),
            onPressed: () {
              context.push('/animation-test');
            },
            tooltip: '动画测试',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 欢迎卡片 - 新拟态风格
            _buildWelcomeCard(context),
            const SizedBox(height: 24),
            
            // 功能入口 - 新拟态风格 + 汉服动画
            _buildFeatureCard(
              context,
              icon: Icons.menu_book_rounded,
              title: '知识库',
              subtitle: '了解汉服形制和历史',
              iconColor: const Color(0xFF2196F3),
              onTap: () => context.push('/knowledge'),
              index: 1,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              icon: Icons.checkroom_rounded,
              title: '我的衣橱',
              subtitle: '管理你的汉服收藏',
              iconColor: const Color(0xFF9C27B0),
              onTap: () => context.push('/wardrobe'),
              index: 2,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              icon: Icons.view_in_ar_rounded,
              title: '3D展示',
              subtitle: '360°查看汉服效果',
              iconColor: const Color(0xFFFF9800),
              onTap: () => context.push('/viewer'),
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    // 使用简单动画卡片确保动画可见
    return SimpleAnimatedCard(
      index: 0,
      child: AnimatedHanfuCard(
        index: 0,
        enableEntranceAnimation: false, // 禁用内部动画，使用外层动画
        padding: const EdgeInsets.all(24),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AnimatedHanfuIcon(
                  icon: Icons.auto_awesome_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                  enableBreathingAnimation: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '欢迎使用${AppConstants.appName}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '拾取汉服之美，记录穿搭之趣',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
    required int index,
  }) {
    // 使用简单动画卡片确保动画可见
    return SimpleAnimatedCard(
      index: index,
      child: AnimatedHanfuCard(
        index: index,
        enableEntranceAnimation: false, // 禁用内部动画，使用外层动画
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: AnimatedHanfuIcon(
              icon: icon,
              color: iconColor,
              size: 28,
              enableFlowAnimation: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
        ),
      ),
    );
  }
}
