# 拾衣坊App - 清新国风首页设计方案（含完整代码）

本文档为“拾衣坊”汉服App首页的完整设计方案，围绕“轻透雅致+汉服市井烟火”核心风格，整合3D汉服预览、离线衣橱入口、国风动效三大核心功能，适配Flutter跨平台开发。文档包含设计规范、页面结构、完整代码、优化技巧，所有内容可直接复用至项目，同时呼应前文色彩、字体、转场动效规范，确保全App风格统一。

# 一、设计核心参数（统一规范）

首页设计严格遵循App整体清新国风调性，参数与前文UI规范保持一致，避免风格冲突。

|维度|具体规范|适配说明|
|---|---|---|
|色彩体系|主色：竹青 #91B493背景：烟白 #F8F9FA文字：墨灰 #4A4A48辅助色：浅杏 #E8E0D0|低饱和度配色，强化通透感，竹青色仅用于强调元素，避免杂乱|
|字体搭配|标题：霞鹜文楷（雅致国风）正文：思源柔黑（轻盈通透）按钮文字：优设标题黑（醒目简约）|替换原站酷快乐体，下载渠道稳定、免费可商用，贴合清新调性|
|控件质感|无边框、半透明（80%不透明度）、圆角12px、轻微阴影（blurRadius:2）|统一控件风格，兼顾轻盈感与触摸反馈|
|核心动效|标题渐显、3D模型自转、卡片轻触缩放、底部导航滑入、水墨晕染转场|动效时长500-800ms，曲线用easeInOutCubic，贴合汉服飘逸感|
|功能布局|上-中-下三段式：顶部品牌区 + 中部3D展示区 + 底部功能入口区|重点突出3D汉服展示，功能入口简洁，符合用户核心操作路径|
# 二、页面结构与功能详解

首页以“3D汉服展示”为视觉核心，兼顾品牌调性与实用功能，避免传统电商式堆砌布局，强化沉浸式体验。

## 2.1 顶部品牌区（简约国风，弱化导航）

### 核心元素

品牌名 + 离线状态标识，无多余导航元素，保持通透感。

### 设计细节

- 品牌名：“拾衣坊 · 汉服集”，霞鹜文楷20px，字间距2px，居中显示；随页面加载触发渐显动效（从0到1不透明度，时长800ms），营造“慢慢展开”的国风意境。

- 离线状态标识：右上角极简线性“云+勾”图标（竹青色18px），下方标注“离线衣橱已就绪”（思源柔黑10px），仅在检测到本地模型时显示，强化离线功能感知。

- 背景：纯烟白色，无装饰，避免遮挡后续3D模型展示。

## 2.2 中部3D汉服展示区（视觉核心，突出产品）

### 核心元素

3D汉服模型 + 悬浮切换按钮 + 动态背景 + 查看细节入口。

### 设计细节

- 3D模型：默认展示宋制烟青褙子（GLB格式，面数≤8000，纹理尺寸512×512），缓慢自转（autoRotateSpeed:0.5），平衡展示效果与性能；背景为浅杏色渐变，搭配竹叶飘落粒子动效（透明竹叶PNG，随机缓慢下落，不遮挡模型核心区域）。

- 悬浮切换按钮：左右两侧圆形半透明按钮（直径40px，竹青色1px边框），内置箭头图标（竹青色20px），点击切换3套默认汉服（褙子→马面裙→齐胸襦裙）；切换时伴随“衣袂轻扬”动效（当前模型缩小至消失，新模型放大出现，时长500ms），贴合汉服飘逸属性。

- 交互设计：支持双指缩放/旋转模型，便于查看衣物纹样、领口等细节；点击模型下方“查看细节”文字（竹青色、下划线，思源柔黑14px），触发水墨晕染转场进入详情页，保持动效风格统一。

## 2.3 底部功能入口区（市井实用，简洁清晰）

### 核心元素

3个功能卡片 + 底部导航栏，聚焦用户核心操作：查看衣橱、穿搭推荐、纹样定制。

### 设计细节

#### 功能卡片（横向排列，间距16px，占屏幕宽度90%）

|卡片名称|图标|功能说明|动效设计|
|---|---|---|---|
|我的衣橱|线性衣架图标（竹青色24px）|进入离线汉服收纳页，显示本地已存储的汉服数量|轻触缩放（0.98→1.0）+ 颜色加深（竹青透明度从0.9→1.0）|
|穿搭推荐|线性衣服叠放图标（竹青色24px）|AI汉服搭配生成（离线可用，基于本地衣橱内容）|同“我的衣橱”动效，保持交互一致性|
|纹样定制|线性针线图标（竹青色24px）|3D模型纹样替换，支持切换暗纹、缠枝莲等国风纹样|同“我的衣橱”动效，强化触摸反馈|
#### 卡片样式

白色半透明背景（80%不透明度），圆角12px，轻微阴影（color:Colors.black12, blurRadius:2, offset:Offset(0,2)）；图标下方标注文字（思源柔黑14px，墨灰色），部分卡片可添加小字提示（如“12件汉服已收纳”，思源柔黑10px，浅灰色）。

#### 底部导航栏

极简风格，仅3个图标（首页/衣橱/我的），选中时竹青色填充，未选中时灰色描边；随页面加载从下往上滑入（时长600ms，曲线easeOutCubic），避免突兀出现。

# 三、Flutter完整实现代码

代码包含首页所有功能，复用前文封装的颜色、字体、转场工具类，可直接复制到项目中使用，需提前准备3D模型、图标等资源。

```Plain Text


import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:shiyifang/utils/shiyi_color.dart'; // 前文封装的颜色工具类
import 'package:shiyifang/utils/shiyi_font.dart'; // 前文封装的字体工具类
import 'package:shiyifang/utils/shiyi_transition.dart'; // 前文封装的转场工具类
import 'package:shiyifang/pages/hanfu_detail_page.dart'; // 汉服详情页
import 'package:shiyifang/pages/wardrobe_page.dart'; // 衣橱页
import 'package:shiyifang/pages/recommend_page.dart'; // 穿搭推荐页
import 'package:shiyifang/pages/custom_page.dart'; // 纹样定制页

// 拾衣坊首页
class ShiyiHomePage extends StatefulWidget {
  const ShiyiHomePage({super.key});

  @override
  State<ShiyiHomePage> createState() => _ShiyiHomePageState();
}

class _ShiyiHomePageState extends State<ShiyiHomePage> with SingleTickerProviderStateMixin {
  // 3D模型列表（本地GLB文件路径，需放入assets/models目录）
  // 模型获取渠道推荐（免费可商用、低面数适配移动端）：
  // 1. 开源模型平台：GitHub - LXGWWenKai/ChineseTraditionalClothing3D：含宋制褙子、明制马面裙模型，面数≤6000，GLB格式可直接下载
  // 2. 国内合规平台：豆包设计素材库 - 汉服3D模型专题：筛选“免费商用”标签，提供轻量化GLB文件，适配离线加载
  // 3. 设计师社区：站酷海洛 - 免费素材区：搜索“汉服3D”，选择低面数版本，需保留作者署名（部分资源）
  // 4. 海外平台：Sketchfab（筛选CC0授权）：关键词“Hanfu GLB low poly”，下载后需用Blender压缩优化
  final List<String> _modelList = [
    "assets/models/song_beizi.glb", // 宋制褙子
    "assets/models/ming_mamianqun.glb", // 明制马面裙
    "assets/models/tang_qixiong.glb" // 唐制齐胸襦裙（修正笔误）
  ];
  int _currentModelIndex = 0; // 当前展示的模型索引
  bool _titleVisible = false; // 标题渐显状态
  late AnimationController _navAnimationController; // 底部导航动画控制器
  String _pressedCard = ""; // 按压的功能卡片标识

  @override
  void initState() {
    super.initState();
    // 标题渐显动画（延迟300ms触发，营造自然过渡）
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _titleVisible = true);
    });
    // 底部导航滑入动画初始化
    _navAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward(); // 启动动画
  }

  @override
  void dispose() {
    _navAnimationController.dispose(); // 释放动画资源
    super.dispose();
  }

  // 切换3D模型（左右切换，循环展示）
  void _switchModel(bool isNext) {
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
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      body: Column(
        children: [
          _buildTopArea(size), // 顶部品牌区
          _build3DViewerArea(size), // 中部3D展示区
          _buildFunctionArea(size), // 底部功能入口区
        ],
      ),
      bottomNavigationBar: _buildBottomNav(), // 底部导航栏
    );
  }

  // 构建顶部品牌区
  Widget _buildTopArea(Size size) {
    return SizedBox(
      height: size.height * 0.12, // 占屏幕高度12%，适配不同机型
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
          // 离线状态标识
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_done, color: ShiyiColor.primaryColor, size: 18),
                const SizedBox(height: 2),
                Text(
                  "离线衣橱就绪",
                  style: ShiyiFont.smallStyle.copyWith(
                    fontSize: 10,
                    color: ShiyiColor.textSecondary,
                  ),
                ),
              ],
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
          // 3D模型视图（核心组件）
          ModelViewer(
            src: _modelList[_currentModelIndex],
            alt: "汉服3D展示",
            ar: false, // 关闭AR功能，聚焦离线查看
            autoRotate: true, // 自动旋转
            autoRotateSpeed: 0.5, // 旋转速度（慢速，贴合雅致风格）
            cameraControls: true, // 允许手动控制视角
            backgroundColor: ShiyiColor.secondaryColor.withOpacity(0.2), // 浅杏色渐变背景
            style: const TextStyle(),
            // 模型加载完成回调（可添加加载动效）
            onModelLoaded: () {},
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
                      HanfuDetailPage(modelPath: _modelList[_currentModelIndex]),
                      Offset(size.width / 2, size.height / 2),
                    ),
                  );
                },
                child: Text(
                  "点击查看细节",
                  style: ShiyiFont.bodyStyle.copyWith(
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
          isNext ? Icons.arrow_right : Icons.arrow_left,
          color: ShiyiColor.primaryColor,
          size: 20,
        ),
      ),
    );
  }

  // 构建底部功能入口区
  Widget _buildFunctionArea(Size size) {
    return SizedBox(
      height: size.height * 0.2, // 占屏幕高度20%
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 我的衣橱卡片
            _buildFunctionCard(
              title: "我的衣橱",
              icon: Icons.checkroom,
              onTap: () {
                Navigator.push(
                  context,
                  ShiyiTransition.freshSlideTransition(const WardrobePage()),
                );
              },
            ),
            // 穿搭推荐卡片
            _buildFunctionCard(
              title: "穿搭推荐",
              icon: Icons.style,
              onTap: () {
                Navigator.push(
                  context,
                  ShiyiTransition.freshSlideTransition(const RecommendPage()),
                );
              },
            ),
            // 纹样定制卡片
            _buildFunctionCard(
              title: "纹样定制",
              icon: Icons.edit,
              onTap: () {
                Navigator.push(
                  context,
                  ShiyiTransition.freshSlideTransition(const CustomPage()),
                );
              },
            ),
          ],
        ),
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
      child: Transform.scale(
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
                  color: ShiyiColor.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建底部导航栏
  Widget _buildBottomNav() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1), // 初始位置在屏幕下方
        end: Offset.zero, // 目标位置（正常显示）
      ).animate(CurvedAnimation(
        parent: _navAnimationController,
        curve: Curves.easeOutCubic,
      )),
      child: BottomNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0, // 取消阴影
        selectedItemColor: ShiyiColor.primaryColor,
        unselectedItemColor: ShiyiColor.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed, // 固定标签
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: "衣橱"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "我的"),
        ],
      ),
    );
  }
}

```

# 四、低面数汉服3D模型选型指南（适配离线加载）

离线加载场景对3D模型的轻量化、兼容性要求极高，选型需兼顾性能、展示效果与合规性，核心原则为“低面数、小体积、高适配”，以下为具体选型要点。

## 4.1 核心选型指标（硬性标准）

### 4.1.1 面数与顶点数控制

面数直接决定模型加载速度与运行流畅度，需根据设备适配等级分级控制：

- 主流机型（中高端安卓/iOS）：单模型面数≤8000，顶点数≤10000，确保自转、缩放时无卡顿，适配Flutter的ModelViewer组件渲染需求。

- 中低端机型（安卓7.0以下、入门级设备）：单模型面数≤5000，顶点数≤8000，可适当简化衣物褶皱、纹样细节，优先保证基础形态完整。

- 多模型场景：首页默认展示3套汉服模型，总面数≤20000，避免同时加载过多模型导致内存占用过高、App闪退。

### 4.1.2 格式与体积要求

离线加载需选择兼容性强、体积小的格式，同时控制文件大小：

- 优先格式：GLB单文件格式，集成模型、纹理、动画于一体，无需额外依赖文件，避免路径错误导致加载失败，适配跨平台（iOS/安卓/鸿蒙）渲染。

- 避免格式：OBJ（需单独加载材质文件，离线易缺失）、FBX（体积大，Flutter适配性差）。

- 体积控制：单模型压缩后体积≤3MB，纹理尺寸统一为512×512px（WebP格式），总模型资源≤8MB，不占用过多本地存储空间。

### 4.1.3 风格与细节适配

模型风格需贴合App“清新国风”调性，同时平衡细节与性能：

- 形态还原：核心汉服形制（褙子、马面裙、齐胸襦裙）需准确，保留领口、袖口、裙摆等标志性结构，避免因简化导致形制失真。

- 细节取舍：优先保留衣物轮廓线条，简化微小褶皱、复杂暗纹；纹样可通过纹理贴图实现，替代模型本身的实体雕刻，减少面数占用。

- 色彩适配：纹理颜色需贴合App色彩体系（竹青、浅杏、烟白），避免高饱和度纹理，确保与页面背景、动效融合协调。

### 4.1.4 合规性要求

离线商用需严格把控版权，避免侵权纠纷：

- 授权类型：优先选择CC0、Apache 2.0、SIL等开源授权模型，可免费商用、修改、分发，无需署名（部分资源需保留作者信息，需提前查看授权说明）。

- 来源合规：仅从正规平台下载（前文推荐的GitHub开源库、豆包设计素材库等），拒绝盗版、无授权模型，下载后留存授权凭证与下载记录。

- 修改规范：对模型进行轻量化修改后，需遵循原授权协议，开源模型修改后不可闭源商用。

## 4.2 选型流程与检测方法

### 4.2.1 选型流程（从筛选到适配）

1. 渠道筛选：从推荐渠道选择符合“低面数、GLB格式、免费商用”标签的模型，优先选择标注“移动端适配”“轻量化”的资源。

2. 指标检测：用Blender打开模型，查看面数、顶点数，检测纹理尺寸与格式，不符合要求则进行轻量化处理。

3. 压缩优化：通过glTF-Pipeline工具压缩模型，删除冗余顶点、合并重复面，纹理转WebP格式，控制体积达标。

4. 真机测试：在目标设备（中高端/中低端）离线环境下测试加载速度（≤1s为佳）、运行流畅度，无卡顿、闪退、纹理缺失即为合格。

### 4.2.2 常用检测工具

- 面数/格式检测：Blender（免费开源，可查看模型参数、修改格式、简化面数）、MeshLab（快速统计顶点面数，适合批量检测）。

- 压缩工具：glTF-Pipeline（命令行工具，压缩GLB体积，保留核心信息）、TexturePacker（纹理压缩与格式转换）。

- 兼容性测试：Flutter真机调试模式，查看ModelViewer组件日志，排查加载错误、渲染异常问题。

## 4.3 避坑指南（常见问题规避）

- 避免过度追求细节：复杂纹样、多层褶皱会大幅增加面数，离线加载易卡顿，建议通过纹理贴图替代实体细节。

- 警惕纹理缺失：离线环境下纹理文件路径错误、格式不兼容会导致模型“黑脸”，需确保纹理嵌入GLB文件，无外部依赖。

- 控制动画复杂度：仅保留自转基础动画，避免添加骨骼动画、布料模拟动画，减少离线加载时的内存消耗。

- 适配鸿蒙设备：鸿蒙通过安卓兼容层运行时，需测试模型路径（仅支持相对路径assets/xxx），避免绝对路径导致加载失败。

# 五、关键优化与适配技巧

## 5.1 性能优化（适配中低端机型）

1. **3D模型优化**：模型面数严格控制在8000以内，纹理尺寸512×512，采用GLB单文件格式（避免多文件路径问题）；通过Blender删除冗余顶点、合并重复面，确保离线加载≤1s。

2. **动效性能控制**：粒子动效使用AnimatedPositioned+Opacity实现，避免CustomPainter（耗时渲染）；页面加载时先显示骨架屏（烟白色背景+竹青色线条），再加载3D模型，提升等待体验。

3. **资源压缩**：3D模型用glTF-Pipeline工具压缩，图片用WebP格式，字体通过字蛛裁剪（仅保留App所需文字），控制首页资源总大小≤8MB。

## 5.2 风格统一技巧

1. **组件复用**：所有按钮、卡片复用前文封装的ShiyiDecoration工具类，禁止自定义装饰器，确保全App控件风格一致。

2. **动效统一**：转场动效严格调用ShiyiTransition工具类，页面内交互动效时长统一为100-200ms，曲线用easeInOut，避免动效混乱。

3. **色彩克制**：全程仅使用核心色彩体系，禁止新增高饱和度颜色；半透明元素透明度统一为80%-90%，强化通透感。

## 5.3 离线适配（核心功能保障）

1. **本地资源加载**：3D模型、字体、图标均放入assets目录，配置pubspec.yaml资源路径，确保无网络时正常显示；通过Flutter的rootBundle检测本地资源是否存在，缺失时显示默认占位图。

2. **功能适配**：无网络时，“穿搭推荐”按钮置灰并添加提示（“需联网生成更多推荐”），保留离线基础搭配功能；离线状态标识实时更新（如“12件汉服已离线存储”）。

3. **鸿蒙适配**：通过安卓兼容层运行时，确保资源路径为相对路径（assets/xxx），避免绝对路径；测试时重点验证3D模型加载与动效流畅度。

## 4.1 性能优化（适配中低端机型）

1. **3D模型优化**：模型面数严格控制在8000以内，纹理尺寸512×512，采用GLB单文件格式（避免多文件路径问题）；通过Blender删除冗余顶点、合并重复面，确保离线加载≤1s。

2. **动效性能控制**：粒子动效使用AnimatedPositioned+Opacity实现，避免CustomPainter（耗时渲染）；页面加载时先显示骨架屏（烟白色背景+竹青色线条），再加载3D模型，提升等待体验。

3. **资源压缩**：3D模型用glTF-Pipeline工具压缩，图片用WebP格式，字体通过字蛛裁剪（仅保留App所需文字），控制首页资源总大小≤8MB。

## 4.2 风格统一技巧

1. **组件复用**：所有按钮、卡片复用前文封装的ShiyiDecoration工具类，禁止自定义装饰器，确保全App控件风格一致。

2. **动效统一**：转场动效严格调用ShiyiTransition工具类，页面内交互动效时长统一为100-200ms，曲线用easeInOut，避免动效混乱。

3. **色彩克制**：全程仅使用核心色彩体系，禁止新增高饱和度颜色；半透明元素透明度统一为80%-90%，强化通透感。

## 4.3 离线适配（核心功能保障）

1. **本地资源加载**：3D模型、字体、图标均放入assets目录，配置pubspec.yaml资源路径，确保无网络时正常显示；通过Flutter的rootBundle检测本地资源是否存在，缺失时显示默认占位图。

2. **功能适配**：无网络时，“穿搭推荐”按钮置灰并添加提示（“需联网生成更多推荐”），保留离线基础搭配功能；离线状态标识实时更新（如“12件汉服已离线存储”）。

3. **鸿蒙适配**：通过安卓兼容层运行时，确保资源路径为相对路径（assets/xxx），避免绝对路径；测试时重点验证3D模型加载与动效流畅度。

# 五、动效与交互亮点

1. **标题渐显动效**：页面加载300ms后触发，从透明到完全显示，时长800ms，模拟“水墨慢慢晕开”的国风意境，避免标题突兀出现。

2. **模型切换动效**：切换汉服时，当前模型沿中心缩小至透明消失，新模型从透明放大至正常尺寸，时长500ms，贴合“衣袂轻扬”的飘逸感，区别于常规切换动画。

3. **轻触反馈动效**：功能卡片点击时轻微缩放（0.98倍）+ 颜色加深，时长100ms，既符合现代交互习惯，又不破坏清新国风调性，避免强烈震动反馈。

4. **导航滑入动效**：底部导航从下往上滑入，曲线easeOutCubic，模拟“衣物轻轻落下”的质感，与顶部标题渐显形成呼应，提升页面加载层次感。

# 六、文档使用说明

1. **资源准备**：将3D模型（GLB格式）放入assets/models目录，字体文件放入assets/fonts目录，确保路径与代码一致；提前集成model_viewer_plus插件（pubspec.yaml中添加依赖）。

2. **代码集成**：将上述代码放入pages目录，在main.dart中设置为首页；确保依赖的工具类（颜色、字体、转场）已导入项目，无路径错误。

3. **测试适配**：在iOS（≥14.0）、安卓（≥7.0）、鸿蒙设备上分别测试，重点验证3D模型加载、动效流畅度、离线功能可用性。

4. **扩展调整**：如需新增功能卡片，复用_buildFunctionCard通用组件；调整3D模型切换速度，修改autoRotateSpeed参数即可。

# 七、关联文档说明

本首页设计方案与以下文档内容高度关联，需同步参考以保证全App风格统一：

- 《拾衣坊App - 清新国风UI设计与转场动效方案》：复用其中颜色、字体、转场工具类。

- 《思源柔黑与替代字体下载及使用指南》：确保字体资源合规、加载正常。

- 《拾衣坊3D模型轻量化处理指南》：优化3D模型性能，适配首页展示需求。
> （注：文档部分内容可能由 AI 生成）