import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_decoration.dart';
import '../../utils/shiyi_icon.dart';
import '../../utils/shiyi_transition.dart';
import '../../screens/knowledge/knowledge_list_screen.dart';
import '../../screens/wardrobe/wardrobe_list_screen.dart';
import '../../screens/viewer/model_list_screen.dart';
import '../../widgets/animated_hanfu_card.dart';
import '../../widgets/animated_hanfu_icon.dart';
import '../../widgets/simple_animated_card.dart';
import 'animation_test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: ShiyiFont.titleStyle.copyWith(color: ShiyiColor.primaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: ShiyiIcon.hanfuIcon,
          onPressed: () {
            // 可以添加侧边栏
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.animation_rounded, color: ShiyiColor.primaryColor),
            onPressed: () {
              // 使用竹叶轻摆转场
              Navigator.push(
                context,
                ShiyiTransition.bambooSwayTransition(const AnimationTestScreen()),
              );
            },
            tooltip: '动画测试',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 欢迎卡片 - 清新国风风格
            _buildWelcomeCard(context),
            const SizedBox(height: 24),

            // 功能入口 - 清新国风风格
            _buildFeatureCard(
              context,
              icon: ShiyiIcon.knowledgeIcon,
              title: '拾衣 · 知识',
              subtitle: '了解汉服形制和历史',
              onTap: () => Navigator.push(
                context,
                ShiyiTransition.freshSlideTransition(_buildKnowledgeScreen()),
              ),
              index: 1,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              icon: ShiyiIcon.hanfuIcon,
              title: '拾衣 · 衣橱',
              subtitle: '管理你的汉服收藏',
              onTap: () => Navigator.push(
                context,
                ShiyiTransition.freshSlideTransition(_buildWardrobeScreen()),
              ),
              index: 2,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              icon: ShiyiIcon.viewerIcon,
              title: '拾衣 · 观览',
              subtitle: '360°查看汉服效果',
              onTap: () => Navigator.push(
                context,
                ShiyiTransition.scrollUnfoldTransition(_buildViewerScreen()),
              ),
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    // 使用清新国风设计
    return SimpleAnimatedCard(
      index: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: ShiyiDecoration.cardDecoration,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ShiyiColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AnimatedHanfuIcon(
                  icon: Icons.auto_awesome_rounded,
                  color: Color(0xFF91B493),
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
                      style: ShiyiFont.titleStyle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '拾取汉服之美，记录穿搭之趣',
                      style: ShiyiFont.smallStyle,
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
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int index,
  }) {
    // 使用清新国风设计
    return SimpleAnimatedCard(
      index: index,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: ShiyiDecoration.cardDecoration,
          child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ShiyiColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: icon,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: ShiyiFont.smallStyle,
                  ),
                ],
              ),
            ),
            ShiyiIcon.nextIcon,
          ],
          ),
        ),
      ),
    );
  }

  // 构建各个页面的方法（为了使用转场动画）
  Widget _buildKnowledgeScreen() {
    return const KnowledgeListScreen();
  }

  Widget _buildWardrobeScreen() {
    return const WardrobeListScreen();
  }

  Widget _buildViewerScreen() {
    return const ModelListScreen();
  }
}
