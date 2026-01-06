import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_transition.dart';
import '../../screens/viewer/model_viewer_screen.dart';
import '../../screens/viewer/model_list_screen.dart';
import '../../screens/wardrobe/wardrobe_list_screen.dart';
import '../../screens/knowledge/knowledge_list_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../widgets/ink_wash_background.dart';
import '../../services/model_repository.dart';

/// 拾衣坊首页 - 清新国风设计
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 3D模型列表（从JSON文件加载）
  List<ModelItem> _models = [];
  int _currentModelIndex = 0; // 当前展示的模型索引
  bool _titleVisible = false; // 标题渐显状态
  bool _modelViewerReady = false; // ModelViewer是否准备就绪（延迟加载优化）
  String _pressedCard = ""; // 按压的功能卡片标识
  int _modelViewerKey = 0; // ModelViewer的key，用于刷新和复位
  bool _isLoadingModels = true; // 模型加载状态
  bool _modelsLoadFailed = false; // 模型加载是否失败
  String _loadingStatus = '正在加载模型...'; // 加载状态文字
  bool _functionCardsVisible = false; // 功能卡片入场动画状态

  @override
  void initState() {
    super.initState();
    // 加载模型数据
    _loadModels();
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
    // 功能卡片入场动画（延迟800ms触发，在标题之后）
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _functionCardsVisible = true);
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

  Future<void> _loadModels() async {
    if (mounted) {
      setState(() {
        _isLoadingModels = true;
        _modelsLoadFailed = false;
        _loadingStatus = '正在加载模型...';
      });
    }
    
    try {
      List<ModelItem> models = await ModelRepository.loadFromJson();
      
      if (mounted) {
        setState(() {
          _models = models;
          // 如果模型列表为空，使用默认模型
          if (_models.isEmpty) {
            _models = ModelRepository.getDefaultModels();
          }
          
          // 如果仍然为空，说明加载失败
          if (_models.isEmpty) {
            _modelsLoadFailed = true;
            _loadingStatus = '模型加载失败';
          } else {
            _loadingStatus = '模型加载完成';
          }
          
          _isLoadingModels = false;
        });
      }
    } catch (e) {
      // 加载失败，尝试使用默认模型
      if (mounted) {
        setState(() {
          _models = ModelRepository.getDefaultModels();
          if (_models.isEmpty) {
            _modelsLoadFailed = true;
            _loadingStatus = '模型加载失败';
          } else {
            _loadingStatus = '使用默认模型';
          }
          _isLoadingModels = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // 恢复系统UI样式（可选，如果其他页面也需要沉浸式可以不移除）
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  // 检查是否有多个不同的模型（用于决定是否显示切换按钮）
  bool _hasMultipleModels() {
    if (_models.length <= 1) return false;
    // 检查是否有不同的模型路径
    final uniqueModels = _models.map((m) => m.path).toSet();
    return uniqueModels.length > 1;
  }

  // 切换3D模型（左右切换，循环展示）
  void _switchModel(bool isNext) {
    if (!_modelViewerReady) return; // 如果ModelViewer未就绪，不执行切换
    if (!_hasMultipleModels()) return; // 如果只有一个模型，不执行切换
    if (_models.isEmpty) return; // 如果模型列表为空，不执行切换
    setState(() {
      if (isNext) {
        _currentModelIndex = (_currentModelIndex + 1) % _models.length;
      } else {
        _currentModelIndex = (_currentModelIndex - 1 + _models.length) % _models.length;
      }
      _modelViewerKey++; // 更新key以刷新模型
    });
  }

  // 刷新3D模型（重新加载模型）
  void _refreshModel() {
    if (!_modelViewerReady) return;
    setState(() {
      _modelViewerKey++; // 改变key强制重建ModelViewer，重新加载模型
    });
  }


  // 计算8%自适应留白（根据文档要求）
  // 留白值 = 屏幕宽/高 × 8%（取最小值，避免宽屏/竖屏留白失衡）
  double _calculateAdaptivePadding(Size size) {
    final widthPadding = size.width * 0.08;
    final heightPadding = size.height * 0.08;
    return widthPadding < heightPadding ? widthPadding : heightPadding;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // 屏幕尺寸
    final padding = MediaQuery.of(context).padding; // 获取安全区域
    final adaptivePadding = _calculateAdaptivePadding(size); // 8%自适应留白
    
    // 计算模型区域（用于视觉补偿效果）
    final modelAreaHeight = size.height * 0.5;
    final modelArea = Rect.fromLTWH(
      adaptivePadding,
      size.height * 0.15, // 顶部区域后的起始位置
      size.width - adaptivePadding * 2,
      modelAreaHeight - adaptivePadding * 2,
    );

    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      // 使用RepaintBoundary优化性能，减少返回时的重绘
      body: RepaintBoundary(
        child: Stack(
          children: [
            InkWashBackground(
              screenSize: size,
              modelArea: modelArea,
              child: Column(
                children: [
                  _buildTopArea(size, padding), // 顶部品牌区（沉浸式）
                  Expanded(
                    child: _build3DViewerArea(size, adaptivePadding, modelArea), // 中部3D展示区（应用留白）
                  ),
                  _buildFunctionArea(size), // 底部功能入口区
                ],
              ),
            ),
            // 设置按钮（屏幕右上角）
            Positioned(
              top: padding.top + 12, // 状态栏高度 + 间距
              right: 20, // 距离右边缘20
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    ShiyiTransition.freshSlideTransition(const SettingsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ShiyiColor.primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ShiyiColor.primaryColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.settings,
                    color: ShiyiColor.primaryColor.withOpacity(0.9),
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建顶部品牌区（沉浸式，优雅设计）
  Widget _buildTopArea(Size size, EdgeInsets padding) {
    return Container(
      padding: EdgeInsets.only(
        top: padding.top + 16, // 状态栏高度 + 额外间距
        bottom: 16,
        left: 20,
        right: 20,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 品牌标题（优雅设计，渐显动画）
          AnimatedOpacity(
            opacity: _titleVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 主标题
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 左侧装饰点
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: ShiyiColor.primaryColor.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 主标题文字
                    Text(
                      "拾衣坊",
                      style: ShiyiFont.titleStyle.copyWith(
                        fontSize: 24,
                        letterSpacing: 3,
                        color: ShiyiColor.textPrimary,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 右侧装饰点
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: ShiyiColor.primaryColor.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 副标题（优雅分隔）
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 1,
                      color: ShiyiColor.primaryColor.withOpacity(0.3),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "汉服集",
                        style: ShiyiFont.bodyStyle.copyWith(
                          fontSize: 14,
                          letterSpacing: 4,
                          color: ShiyiColor.textSecondary,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 1,
                      color: ShiyiColor.primaryColor.withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建中部3D展示区（应用8%自适应留白和视觉补偿效果）
  Widget _build3DViewerArea(Size size, double adaptivePadding, Rect modelArea) {
    return SizedBox(
      height: size.height * 0.5, // 占屏幕高度50%，突出核心内容
      child: Stack(
        children: [
          // 应用留白的3D模型容器（无边框，更沉浸式）
          Padding(
            padding: EdgeInsets.all(adaptivePadding),
            child: RepaintBoundary(
              child: _buildModelViewerContent(),
            ),
          ),
          // 左侧模型切换按钮（仅在有多个模型时显示）
          if (_hasMultipleModels())
            Positioned(
              left: adaptivePadding + 10,
              top: size.height * 0.25 - 20, // 垂直居中
              child: _buildSwitchButton(false),
            ),
          // 右侧模型切换按钮（仅在有多个模型时显示）
          if (_hasMultipleModels())
            Positioned(
              right: adaptivePadding + 10,
              top: size.height * 0.25 - 20, // 垂直居中
              child: _buildSwitchButton(true),
            ),
          // 刷新和复位按钮（右上角，在切换按钮下方）
          if (_modelViewerReady)
            Positioned(
              top: adaptivePadding + 60, // 在切换按钮下方
              right: adaptivePadding + 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlButton(
                    icon: Icons.refresh,
                    tooltip: "刷新",
                    onTap: _refreshModel,
                  ),
                  const SizedBox(height: 8),
                  // 更多3D模型按钮
                  _buildControlButton(
                    icon: Icons.view_in_ar,
                    tooltip: "更多3D模型",
                    onTap: () {
                      Navigator.push(
                        context,
                        ShiyiTransition.freshSlideTransition(const ModelListScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          // 查看细节入口（仅在模型加载成功时显示）
          if (_models.isNotEmpty && !_isLoadingModels && !_modelsLoadFailed)
            Positioned(
              bottom: adaptivePadding + 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // 淡入淡出转场进入详情页（简洁流畅，不打断沉浸感）
                    Navigator.push(
                      context,
                      ShiyiTransition.freshSlideTransition(
                        ModelViewerScreen(
                          modelName: _models[_currentModelIndex].name,
                          modelPath: _models[_currentModelIndex].path,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "点击查看细节",
                        style: ShiyiFont.bodyStyle.copyWith(
                          fontSize: 14,
                          color: ShiyiColor.primaryColor.withOpacity(0.6), // 降低文字透明度
                          decoration: TextDecoration.underline,
                          decorationColor: ShiyiColor.primaryColor.withOpacity(0.6), // 降低下划线透明度
                        ),
                      ),
                      if (_models.length > 1) ...[
                        const SizedBox(height: 4),
                        Text(
                          "${_currentModelIndex + 1} / ${_models.length}",
                          style: ShiyiFont.smallStyle.copyWith(
                            color: ShiyiColor.textSecondary.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建模型查看器内容
  Widget _buildModelViewerContent() {
    // 如果模型加载失败，显示友好提示
    if (_modelsLoadFailed || (_models.isEmpty && !_isLoadingModels)) {
      return Container(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.view_in_ar_outlined,
                size: 64,
                color: ShiyiColor.primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '暂无3D模型',
                style: ShiyiFont.bodyStyle.copyWith(
                  color: ShiyiColor.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '请前往"更多3D模型"查看',
                style: ShiyiFont.smallStyle.copyWith(
                  color: ShiyiColor.textSecondary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    ShiyiTransition.freshSlideTransition(const ModelListScreen()),
                  );
                },
                icon: const Icon(Icons.view_in_ar, size: 18),
                label: const Text('查看模型列表'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShiyiColor.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // 如果正在加载，显示加载状态
    if (_isLoadingModels || !_modelViewerReady) {
      return Container(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ShiyiColor.primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                _loadingStatus,
                style: ShiyiFont.smallStyle.copyWith(
                  color: ShiyiColor.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // 如果模型列表为空但不在加载中，显示提示
    if (_models.isEmpty) {
      return Container(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.view_in_ar_outlined,
                size: 64,
                color: ShiyiColor.primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '暂无3D模型',
                style: ShiyiFont.bodyStyle.copyWith(
                  color: ShiyiColor.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '请前往"更多3D模型"查看',
                style: ShiyiFont.smallStyle.copyWith(
                  color: ShiyiColor.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // 正常显示模型
    return ModelViewer(
      key: ValueKey('home_model_${_currentModelIndex}_$_modelViewerKey'), // 使用key控制刷新
      src: _models[_currentModelIndex].path,
      alt: "汉服3D展示",
      ar: false, // 关闭AR功能，聚焦离线查看
      autoRotate: true, // 自动旋转
      cameraControls: true, // 允许手动控制视角
      backgroundColor: Colors.transparent, // 透明背景，让水墨背景显示
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
          color: Colors.white.withOpacity(0.4), // 降低透明度，更不显眼
          borderRadius: BorderRadius.circular(20), // 圆形按钮
          border: Border.all(
            color: ShiyiColor.primaryColor.withOpacity(0.5), // 降低边框透明度
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // 降低阴影透明度
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          isNext ? Icons.arrow_forward : Icons.arrow_back,
          color: ShiyiColor.primaryColor.withOpacity(0.7), // 降低图标透明度
          size: 20,
        ),
      ),
    );
  }

  // 构建控制按钮（刷新、复位）
  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4), // 降低透明度，更不显眼
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: ShiyiColor.primaryColor.withOpacity(0.5), // 降低边框透明度
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: ShiyiColor.primaryColor.withOpacity(0.08), // 降低阴影透明度
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // 降低阴影透明度
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: ShiyiColor.primaryColor.withOpacity(0.7), // 降低图标透明度
            size: 20,
          ),
        ),
      ),
    );
  }

  // 构建底部功能入口区（优化版 - 单行布局，防止溢出）
  Widget _buildFunctionArea(Size size) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      // 移除背景装饰，保持简洁
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 装饰性分隔线
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          ShiyiColor.primaryColor.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ShiyiColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "功能入口",
                    style: ShiyiFont.bodyStyle.copyWith(
                      fontSize: 11,
                      color: ShiyiColor.primaryColor.withOpacity(0.7),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          ShiyiColor.primaryColor.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 功能卡片单行布局（只保留我的衣橱和知识库）
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 我的衣橱
              Expanded(
                child: _buildAnimatedFunctionCard(
                  key: const ValueKey("wardrobe"),
                  title: "我的衣橱",
                  icon: Icons.checkroom,
                  subtitle: "收藏管理",
                  delay: 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      ShiyiTransition.freshSlideTransition(const WardrobeListScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // 知识库
              Expanded(
                child: _buildAnimatedFunctionCard(
                  key: const ValueKey("knowledge"),
                  title: "知识库",
                  icon: Icons.menu_book,
                  subtitle: "汉服文化",
                  delay: 150,
                  onTap: () {
                    Navigator.push(
                      context,
                      ShiyiTransition.freshSlideTransition(const KnowledgeListScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建功能卡片（通用组件 - 保留用于兼容）
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

  // 构建增强版功能卡片（优化版 - 更丰富的视觉效果和交互）
  Widget _buildEnhancedFunctionCard({
    required Key key,
    required String title,
    required IconData icon,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cardKey = key.toString();
    final isPressed = _pressedCard == cardKey;
    
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => setState(() => _pressedCard = cardKey),
      onTapUp: (_) => setState(() => _pressedCard = ""),
      onTapCancel: () => setState(() => _pressedCard = ""),
      child: AnimatedScale(
        scale: isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // 使用淡雅的白色背景，更符合国风风格
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            // 使用淡雅的边框，类似水墨画的淡墨效果
            border: Border.all(
              color: isPressed
                  ? ShiyiColor.primaryColor.withOpacity(0.25)
                  : ShiyiColor.borderColor,
              width: isPressed ? 1.0 : 0.5,
            ),
            // 使用更柔和的阴影，类似纸张的轻微阴影效果
            boxShadow: [
              BoxShadow(
                color: ShiyiColor.primaryColor.withOpacity(isPressed ? 0.08 : 0.04),
                blurRadius: isPressed ? 10 : 6,
                offset: Offset(0, isPressed ? 3 : 1),
                spreadRadius: 0,
              ),
              // 添加一层极淡的阴影，营造纸张质感
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标容器（带背景装饰，更淡雅的风格）
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  // 使用极淡的竹青色背景，更符合国风
                  color: ShiyiColor.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                  // 移除阴影，保持简洁
                ),
                child: Icon(
                  icon,
                  color: ShiyiColor.primaryColor.withOpacity(0.85),
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              // 主标题
              Text(
                title,
                style: ShiyiFont.bodyStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ShiyiColor.textPrimary,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // 副标题
              Text(
                subtitle,
                style: ShiyiFont.bodyStyle.copyWith(
                  fontSize: 11,
                  color: ShiyiColor.textSecondary,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建带动画的功能卡片（入场动效）
  Widget _buildAnimatedFunctionCard({
    required Key key,
    required String title,
    required IconData icon,
    required String subtitle,
    required int delay,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0.0,
        end: _functionCardsVisible ? 1.0 : 0.0,
      ),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)), // 从下往上滑入
          child: Opacity(
            opacity: value, // 淡入
            child: Transform.scale(
              scale: 0.8 + (0.2 * value), // 从0.8缩放到1.0
              child: _buildEnhancedFunctionCard(
                key: key,
                title: title,
                icon: icon,
                subtitle: subtitle,
                onTap: onTap,
              ),
            ),
          ),
        );
      },
    );
  }
}
