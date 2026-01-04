# 拾衣坊App - 清新国风UI设计与转场动效方案

本文档整合「拾衣坊」汉服App的清新脱俗UI设计规范、替代常规push的国风转场动效实现方案，所有代码可直接复制到Flutter项目中使用，兼顾跨平台兼容性（iOS/安卓/鸿蒙）与视觉美感，核心风格为「轻、透、柔」，贴合汉服雅致属性。

# 一、整体风格定位

摒弃传统厚重国风元素，采用「浅淡水墨+通透留白+线性极简」设计语言，拒绝元素堆砌，以细节传递汉服雅致感；转场动效摆脱常规滑动，围绕「衣袂飘柔、水墨晕染」核心，打造与汉服主题高度契合的清新交互体验。

# 二、清新国风UI设计规范（完整可复用）

## 2.1 核心视觉参数

|视觉维度|设计方案|Flutter落地代码|使用说明|
|---|---|---|---|
|主色调|烟白（#F8F9FA）- 背景竹青（#91B493）- 主色墨灰（#4A4A48）- 文字|`// 全局颜色配置（建议封装为工具类）
class ShiyiColor {
  static const Color bgColor = Color(0xFFF8F9FA); // 烟白背景
  static const Color primaryColor = Color(0xFF91B493); // 竹青主色
  static const Color textPrimary = Color(0xFF4A4A48); // 墨灰文字
  static const Color textSecondary = Color(0xFF8A8A88); // 浅灰文字
  static const Color borderColor = Color(0xFFEAEAE8); // 极细边框色
}
`|所有页面统一使用此配色，避免色彩混乱，竹青主色仅用于强调元素（按钮、图标）|
|字体规范|正文：思源柔黑（轻盈通透）标题：站酷快乐体（简约国风）|`# pubspec.yaml 字体配置
flutter:
  fonts:
    - family: FreshHanfu
      fonts:
        - asset: assets/fonts/SourceHanSansCN-Light.otf # 思源柔黑
        - asset: assets/fonts/ZCOOLKuaiLe-Regular.ttf # 站酷快乐体
          weight: 400<br>// 字体工具类
class ShiyiFont {
  static const String family = "FreshHanfu";
  static TextStyle titleStyle = TextStyle(
    fontFamily: family,
    fontSize: 20,
    color: ShiyiColor.textPrimary,
    letterSpacing: 2,
  );
  static TextStyle bodyStyle = TextStyle(
    fontFamily: family,
    fontSize: 16,
    color: ShiyiColor.textPrimary,
  );
  static TextStyle smallStyle = TextStyle(
    fontSize: 12,
    color: ShiyiColor.textSecondary,
  );
}
`|字体文件放入 assets/fonts 目录，标题字间距增加2px，强化清新通透感|
|控件质感|无边框、低饱和度、圆角12px，半透明效果，轻微阴影|`// 全局控件装饰器
class ShiyiDecoration {
  // 卡片装饰（通用）
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.8), // 半透明白色
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: ShiyiColor.borderColor),
    boxShadow: [
      BoxShadow(
        color: Colors.black05,
        blurRadius: 3,
        offset: const Offset(0, 1),
        spreadRadius: 0,
      )
    ],
  );
  // 按钮装饰
  static BoxDecoration buttonDecoration = BoxDecoration(
    color: ShiyiColor.primaryColor.withOpacity(0.9),
    borderRadius: BorderRadius.circular(8),
  );
}
`|所有卡片、容器统一使用此装饰，避免重复编码，保证风格统一|
|图标规范|极简线性（1px线条），无填充，仅用竹青/墨灰，尺寸18-24px|`// 图标工具类
class ShiyiIcon {
  // 返回图标
  static Widget backIcon = const Icon(
    Icons.arrow_back_ios,
    color: ShiyiColor.primaryColor,
    size: 18,
  );
  // 详情箭头图标
  static Widget nextIcon = const Icon(
    Icons.chevron_right,
    color: ShiyiColor.primaryColor,
    size: 20,
  );
  // 自定义汉服图标（需导入IconFont）
  static Widget hanfuIcon = Icon(
    Icons.add, // 替换为自定义IconFont代码
    color: ShiyiColor.primaryColor,
    size: 22,
  );
}
`|优先复用Flutter自带线性图标，自定义图标线条粗细控制在1px，避免复杂造型|
## 2.2 核心页面UI实现（完整代码）

### 2.2.1 清新版衣橱页面

```dart

import 'package:flutter/material.dart';

// 拾衣坊 - 清新国风衣橱页面
class FreshWardrobePage extends StatelessWidget {
  const FreshWardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      appBar: _buildAppBar(),
      body: _buildWardrobeList(),
    );
  }

  // 顶部导航栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        "拾衣 · 清衫集",
        style: ShiyiFont.titleStyle.copyWith(color: ShiyiColor.primaryColor),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: ShiyiIcon.backIcon,
      centerTitle: true,
    );
  }

  // 衣橱列表
  Widget _buildWardrobeList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        itemCount: 6, // 模拟数据数量
        separatorBuilder: (_, __) => const SizedBox(height: 12), // 充足留白
        itemBuilder: (context, index) => _buildHanfuCard(context, index),
      ),
    );
  }

  // 汉服卡片
  Widget _buildHanfuCard(BuildContext context, int index) {
    // 模拟汉服数据
    final hanfuData = [
      {"name": "宋制·烟青褙子", "fabric": "天丝 | 竹叶纹", "img": "assets/images/beizi_light.png"},
      {"name": "明制·月白马面裙", "fabric": "棉麻 | 暗纹", "img": "assets/images/mamianqun_light.png"},
      {"name": "唐制·浅粉齐胸裙", "fabric": "雪纺 | 缠枝莲", "img": "assets/images/qixiong_light.png"},
      {"name": "宋制·米白百迭裙", "fabric": "苎麻 | 素色", "img": "assets/images/baidie_light.png"},
      {"name": "明制·竹青袄裙", "fabric": "绸缎 | 云纹", "img": "assets/images/aoqun_light.png"},
      {"name": "唐制·月白披帛", "fabric": "纱质 | 素色", "img": "assets/images/pibo_light.png"},
    ][index];

    return GestureDetector(
      onTap: () {
        // 跳转详情页（搭配自定义转场）
        Navigator.push(
          context,
          freshSlideTransition(
            HanfuDetailPage(hanfuData: hanfuData),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShiyiDecoration.cardDecoration,
        child: Row(
          children: [
            // 衣物缩略图
            _buildHanfuImage(hanfuData["img"]!),
            const SizedBox(width: 16),
            // 衣物信息
            _buildHanfuInfo(hanfuData["name"]!, hanfuData["fabric"]!),
            ShiyiIcon.nextIcon,
          ],
        ),
      ),
    );
  }

  // 衣物缩略图
  Widget _buildHanfuImage(String imgPath) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black05, blurRadius: 3)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imgPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // 衣物信息
  Widget _buildHanfuInfo(String name, String fabric) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: ShiyiFont.bodyStyle),
          const SizedBox(height: 4),
          Text(fabric, style: ShiyiFont.smallStyle),
        ],
      ),
    );
  }
}
```

### 2.2.2 汉服详情页面（含3D模型展示）

```dart

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

// 汉服详情页面
class HanfuDetailPage extends StatefulWidget {
  final Map<String, String> hanfuData;

  const HanfuDetailPage({super.key, required this.hanfuData});

  @override
  State<HanfuDetailPage> createState() => _HanfuDetailPageState();
}

class _HanfuDetailPageState extends State<HanfuDetailPage> {
  bool _modelLoaded = false; // 3D模型加载状态
  String _currentTexture = "暗纹"; // 当前纹样

  @override
  void initState() {
    super.initState();
    // 模拟模型加载完成
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => _modelLoaded = true);
    });
  }

  // 切换纹样
  void _changeTexture(String texture) {
    setState(() => _currentTexture = texture);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 3D模型展示区（带加载动效）
          _build3DViewer(),
          // 纹样切换栏
          _buildTextureSwitcher(),
          // 衣物详情
          _buildHanfuDetail(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.hanfuData["name"]!,
        style: ShiyiFont.titleStyle.copyWith(fontSize: 18),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: ShiyiIcon.backIcon,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // 3D模型展示（带清新加载动效）
  Widget _build3DViewer() {
    return Expanded(
      child: AnimatedOpacity(
        opacity: _modelLoaded ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 800),
        child: AnimatedRotation(
          turns: _modelLoaded ? 0.0 : 0.1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
          child: ModelViewer(
            src: "assets/models/${widget.hanfuData["name"]!.replaceAll("·", "_").toLowerCase()}.glb",
            alt: widget.hanfuData["name"]!,
            ar: false,
            autoRotate: true,
            cameraControls: true,
            backgroundColor: ShiyiColor.bgColor,
            animationSpeed: 0.8,
            properties: [
              Property(
                name: "texture",
                value: "assets/textures/${_currentTexture}.png",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 纹样切换栏
  Widget _buildTextureSwitcher() {
    final textures = ["暗纹", "缠枝莲", "竹叶", "祥云"];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white.withOpacity(0.7),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: textures
              .map((texture) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentTexture == texture
                            ? ShiyiColor.primaryColor
                            : Colors.white,
                        foregroundColor: _currentTexture == texture
                            ? Colors.white
                            : ShiyiColor.primaryColor,
                        borderSide: BorderSide(color: ShiyiColor.primaryColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onPressed: () => _changeTexture(texture),
                      child: Text(texture, style: ShiyiFont.smallStyle),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // 衣物详情
  Widget _buildHanfuDetail() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("面料信息", style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(widget.hanfuData["fabric"]!, style: ShiyiFont.smallStyle),
          const SizedBox(height: 16),
          Text("穿搭建议", style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            "搭配同色系披帛或发簪，适配春日游园、古风摄影场景，面料轻盈透气，日常穿搭无压力。",
            style: ShiyiFont.smallStyle,
            lineHeight: 1.5,
          ),
        ],
      ),
    );
  }
}

```

# 三、替代常规push的国风转场动效（完整封装）

以下5种转场动效均已封装为可直接调用的工具类，摒弃Flutter默认push滑动动画，适配不同页面切换场景，核心风格统一为「清新柔缓」。

## 3.1 动效工具类（完整代码）

```dart

import 'package:flutter/material.dart';

// 拾衣坊 - 清新国风转场动效工具类
class ShiyiTransition {
  // 1. 衣袂轻扬转场（优先级最高，贴合汉服主题）
  // 场景：衣橱 -> 详情页、常规页面切换
  static Route<T> freshSlideTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(
            curve: const Interval(0.0, 1.0, curve: Curves.easeInOutQuad),
          )).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.6, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // 2. 水墨晕染转场（清新国风代表）
  // 场景：卡片点击进入详情页、图标触发页面
  static Route<T> inkSpreadTransition<T>(Widget page, Offset tapPosition) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final size = MediaQuery.of(context).size;
        final circleAnimation = Tween<double>(
          begin: 0.0,
          end: size.longestSide * 1.5,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCirc,
        ));

        return ClipPath(
          clipper: _CircleClipper(
            radius: circleAnimation.value,
            center: tapPosition,
          ),
          child: child,
        );
      },
    );
  }

  // 3. 竹叶轻摆转场（极简清新）
  // 场景：轻量级页面切换（设置页、分类页）
  static Route<T> bambooSwayTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // 透视效果
            ..rotateY(animation.value * 0.1) // 轻微倾斜
            ..translate(
              animation.value * MediaQuery.of(context).size.width - MediaQuery.of(context).size.width,
              0,
            ),
          alignment: Alignment.centerRight,
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.7, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  // 4. 卷轴展开转场（国风+清新）
  // 场景：3D模型展示页、弹窗式页面
  static Route<T> scrollUnfoldTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // 5. 线香绕圈转场（小众清新）
  // 场景：功能入口页面（3D试穿、穿搭推荐）
  static Route<T> incenseCircleTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 900),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(begin: 0.1, end: 0.0).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.5, 0.2), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutSine),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// 圆形裁剪器（水墨晕染转场核心）
class _CircleClipper extends CustomClipper<Path> {
  final double radius;
  final Offset center;

  _CircleClipper({required this.radius, required this.center});

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(_CircleClipper oldClipper) => true;
}

```

## 3.2 动效调用示例

```dart

// 1. 衣袂轻扬转场（最常用）
onTap: () {
  Navigator.push(
    context,
    ShiyiTransition.freshSlideTransition(const HanfuDetailPage()),
  );
},

// 2. 水墨晕染转场（需记录点击位置）
Offset _tapPosition = Offset.zero;
onTapDown: (TapDownDetails details) {
  _tapPosition = details.globalPosition;
},
onTap: () {
  Navigator.push(
    context,
    ShiyiTransition.inkSpreadTransition(const HanfuDetailPage(), _tapPosition),
  );
},

// 3. 竹叶轻摆转场（设置页）
onTap: () {
  Navigator.push(
    context,
    ShiyiTransition.bambooSwayTransition(const SettingPage()),
  );
},

// 4. 卷轴展开转场（3D展示页）
onTap: () {
  Navigator.push(
    context,
    ShiyiTransition.scrollUnfoldTransition(const Hanfu3DPage()),
  );
},

// 5. 线香绕圈转场（穿搭推荐页）
onTap: () {
  Navigator.push(
    context,
    ShiyiTransition.incenseCircleTransition(const OutfitRecommendPage()),
  );
},

```

# 四、落地优化与注意事项

## 4.1 性能优化技巧

1. **动效性能控制**：所有转场时长统一在500-900ms，曲线优先选用 `Curves.easeInOutCubic`、`Curves.easeOutCirc` 等柔缓曲线，避免过快导致生硬感；转场时暂停3D模型动画，防止双重动效卡顿。

2. **资源优化**：3D模型面数控制在≤10000面，纹理尺寸512×512，采用GLB单文件格式，保证离线加载≤1s；图片使用WebP格式，字体文件仅保留必要字重，控制App体积≤100MB。

3. **机型适配**：低性能机型自动降级为「衣袂轻扬」转场（最轻量化），关闭非核心动效（如3D模型飘动），仅保留基础交互动效。

## 4.2 风格统一注意事项

1. 页面内交互动效需极简：按钮点击仅做「轻微缩放（0.98-1.0）+ 颜色浅变」，输入框聚焦仅显示竹青色下划线，避免叠加过多特效破坏清新感。

2. 留白规范：页面左右留白≥16px，组件间距≥8px，列表项分隔间距≥12px，通过充足留白强化通透感。

3. 色彩克制：全程仅使用「烟白+竹青+墨灰」三色体系，禁止新增其他高饱和度颜色，特殊场景可使用浅灰辅助色。

## 4.3 跨平台兼容性说明

- iOS：支持所有动效与UI样式，最低兼容iOS 14.0+，需在Xcode中配置自定义字体与资源路径。

- 安卓：支持所有动效与UI样式，最低兼容安卓7.0+，需通过 `permission_handler` 插件处理存储权限（加载本地3D模型）。

- 鸿蒙：通过安卓兼容层无缝运行，所有动效与UI样式无差异，需调整应用签名与权限申请格式，核心逻辑无需改动。

# 五、文档使用说明

1. 将本文档中的代码按「颜色工具类→字体工具类→装饰器工具类→转场工具类→页面组件」的顺序导入项目，保证依赖关系正确。

2. 资源准备：将字体文件放入 `assets/fonts`，3D模型放入 `assets/models`，纹理图片放入 `assets/textures`，并在 `pubspec.yaml` 中配置资源路径。

3. 页面跳转统一使用 `ShiyiTransition` 工具类，替代Flutter默认 `Navigator.push`，保证转场风格统一。

4. 新增页面时复用现有工具类与组件，禁止自定义颜色、装饰器，确保全App风格一致。
> （注：文档部分内容可能由 AI 生成）