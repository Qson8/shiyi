import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_transition.dart';
import '../../screens/viewer/model_viewer_screen.dart';
import '../../screens/wardrobe/wardrobe_list_screen.dart';
import '../../screens/knowledge/knowledge_list_screen.dart';

/// 拾衣坊首页 - 清新国风设计
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 3D模型列表（本地GLB文件路径，需放入assets/models目录）
  final List<String> _modelList = [
    "assets/models/hanfu-test.glb", // 默认模型
    "assets/models/hanfu-test.glb", // 暂时使用同一个模型，后续可替换
    "assets/models/hanfu-test.glb" // 暂时使用同一个模型，后续可替换
  ];
  
  final List<String> _modelNames = [
    "宋制烟青褙子",
    "明制马面裙",
    "唐制齐胸襦裙"
  ];
  
  int _currentModelIndex = 0; // 当前展示的模型索引
  bool _titleVisible = false; // 标题渐显状态
  bool _modelViewerReady = false; // ModelViewer是否准备就绪（延迟加载优化）
  String _pressedCard = ""; // 按压的功能卡片标识

  @override
  void initState() {
    super.initState();
    // 确保在主线程设置沉浸式状态栏（避免iOS线程警告）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        );
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // 透明状态栏
            statusBarIconBrightness: Brightness.dark, // 深色图标（适配浅色背景）
            statusBarBrightness: Brightness.light, // iOS 状态栏样式
          ),
        );
      }
    });
    // 标题渐显动画（延迟300ms触发，营造自然过渡）
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _titleVisible = true);
      }
    });
    // 延迟加载ModelViewer，优化首屏性能（避免Hang检测）
    // 使用SchedulerBinding确保在UI渲染完成后再加载3D模型
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _modelViewerReady = true);
        }
      });
    });
  }

  @override
  void dispose() {
    // 恢复系统UI样式（可选，如果其他页面也需要沉浸式可以不移除）
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  // 切换3D模型（左右切换，循环展示）
  void _switchModel(bool isNext) {
    if (!_modelViewerReady) return; // 如果ModelViewer未就绪，不执行切换
    setState(() {
      if (isNext) {
        _currentModelIndex = (_currentModelIndex + 1) % _modelList.length;
      } else {
        _currentModelIndex = (_currentModelIndex - 1 + _modelList.length) % _modelList.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // 屏幕尺寸
    final padding = MediaQuery.of(context).padding; // 获取安全区域
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      // 使用RepaintBoundary优化性能，减少返回时的重绘
      body: RepaintBoundary(
        child: Column(
          children: [
            _buildTopArea(size, padding), // 顶部品牌区（沉浸式）
            _build3DViewerArea(size), // 中部3D展示区
            _buildFunctionArea(size), // 底部功能入口区
          ],
        ),
      ),
    );
  }

  // 构建顶部品牌区（沉浸式）
  Widget _buildTopArea(Size size, EdgeInsets padding) {
    return Container(
      padding: EdgeInsets.only(
        top: padding.top + 12, // 状态栏高度 + 额外间距
        bottom: 12,
        left: 20,
        right: 20,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 品牌标题（渐显动画）
          AnimatedOpacity(
            opacity: _titleVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            child: Text(
              "拾衣坊 · 汉服集",
              style: ShiyiFont.titleStyle.copyWith(
                fontSize: 20,
                letterSpacing: 2,
                color: ShiyiColor.textPrimary,
              ),
            ),
          ),
          // 离线状态标识（仅显示图标，减少干扰）
          Positioned(
            top: padding.top + 8, // 与状态栏对齐
            right: 0,
            child: Icon(
              Icons.cloud_done,
              color: ShiyiColor.primaryColor.withOpacity(0.6),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // 构建中部3D展示区
  Widget _build3DViewerArea(Size size) {
    return SizedBox(
      height: size.height * 0.5, // 占屏幕高度50%，突出核心内容
      child: Stack(
        children: [
          // 3D模型视图（核心组件）- 使用RepaintBoundary优化返回时的性能
          RepaintBoundary(
            child: _modelViewerReady
                ? ModelViewer(
                    src: _modelList[_currentModelIndex],
                    alt: "汉服3D展示",
                    ar: false, // 关闭AR功能，聚焦离线查看
                    autoRotate: true, // 自动旋转
                    cameraControls: true, // 允许手动控制视角
                    backgroundColor: ShiyiColor.secondaryColor.withOpacity(0.2), // 浅杏色渐变背景
                  )
                : Container(
                    color: ShiyiColor.secondaryColor.withOpacity(0.2),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
          ),
          // 左侧模型切换按钮
          Positioned(
            left: 20,
            top: size.height * 0.25 - 20, // 垂直居中
            child: _buildSwitchButton(false),
          ),
          // 右侧模型切换按钮
          Positioned(
            right: 20,
            top: size.height * 0.25 - 20, // 垂直居中
            child: _buildSwitchButton(true),
          ),
          // 查看细节入口
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // 水墨晕染转场进入详情页（从屏幕中心扩散）
                  Navigator.push(
                    context,
                    ShiyiTransition.inkSpreadTransition(
                      ModelViewerScreen(
                        modelName: _modelNames[_currentModelIndex],
                        modelPath: _modelList[_currentModelIndex],
                      ),
                      Offset(size.width / 2, size.height / 2),
                    ),
                  );
                },
                child: Text(
                  "点击查看细节",
                  style: ShiyiFont.bodyStyle.copyWith(
                    fontSize: 14,
                    color: ShiyiColor.primaryColor,
                    decoration: TextDecoration.underline,
                    decorationColor: ShiyiColor.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建模型切换按钮
  Widget _buildSwitchButton(bool isNext) {
    return GestureDetector(
      onTap: () => _switchModel(isNext),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8), // 半透明白色
          borderRadius: BorderRadius.circular(20), // 圆形按钮
          border: Border.all(color: ShiyiColor.primaryColor, width: 1), // 竹青色边框
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 1, offset: Offset(0, 1))
          ],
        ),
        child: Icon(
          isNext ? Icons.arrow_forward : Icons.arrow_back,
          color: ShiyiColor.primaryColor,
          size: 20,
        ),
      ),
    );
  }

  // 构建底部功能入口区（仅第一版本功能）
  Widget _buildFunctionArea(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 我的衣橱
          _buildFunctionCard(
            title: "我的衣橱",
            icon: Icons.checkroom,
            onTap: () {
              Navigator.push(
                context,
                ShiyiTransition.freshSlideTransition(const WardrobeListScreen()),
              );
            },
          ),
          // 知识库
          _buildFunctionCard(
            title: "知识库",
            icon: Icons.menu_book,
            onTap: () {
              Navigator.push(
                context,
                ShiyiTransition.freshSlideTransition(const KnowledgeListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // 构建功能卡片（通用组件）
  Widget _buildFunctionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isPressed = _pressedCard == title;
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => setState(() => _pressedCard = title),
      onTapUp: (_) => setState(() => _pressedCard = ""),
      onTapCancel: () => setState(() => _pressedCard = ""),
      child: AnimatedScale(
        scale: isPressed ? 0.98 : 1.0, // 轻触缩放动效
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPressed 
                    ? ShiyiColor.primaryColor 
                    : ShiyiColor.primaryColor.withOpacity(0.9),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: ShiyiFont.bodyStyle.copyWith(
                  fontSize: 14,
                  color: ShiyiColor.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
