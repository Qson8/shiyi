# 拾衣坊（Shiyi）

汉服离线识别与穿搭管理App - MVP第一版本

## 功能特性

### ✅ 已实现功能

1. **知识库功能**
   - 汉服形制科普（8种基础形制）
   - 历史背景介绍
   - 搜索和收藏功能
   - 分类筛选

2. **衣橱管理功能**
   - 添加/编辑/删除汉服
   - 按朝代和类型筛选
   - 尺码记录（胸围、腰围、衣长等）
   - 网格/列表视图切换

3. **3D展示功能**
   - 3D模型列表
   - 模型加载（hanfu-test.glb）
   - 基础展示页面（后续可集成3D渲染引擎）

4. **基础功能**
   - 本地数据存储（Hive）
   - 主题配置（中国传统色）
   - 路由导航

## 技术栈

- **框架**: Flutter
- **状态管理**: Provider
- **本地存储**: Hive
- **路由**: GoRouter
- **3D模型**: GLB格式（hanfu-test.glb）

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── knowledge_item.dart
│   └── hanfu_item.dart
├── services/                 # 服务层
│   ├── database_service.dart
│   ├── knowledge_repository.dart
│   └── wardrobe_repository.dart
├── screens/                  # 页面
│   ├── home/                # 首页
│   ├── knowledge/           # 知识库
│   ├── wardrobe/            # 衣橱管理
│   └── viewer/              # 3D展示
├── widgets/                  # 通用组件
│   ├── app_card.dart
│   ├── loading_indicator.dart
│   └── empty_state.dart
└── utils/                    # 工具类
    ├── theme.dart
    └── constants.dart
```

## 安装和运行

### 前置要求

- Flutter SDK (>=3.4.0) - 支持鸿蒙平台需要 Flutter ohos 版本
- Dart SDK
- Android Studio / Xcode (用于移动端开发)
- DevEco Studio (用于鸿蒙开发，可选)

### 安装步骤

1. **克隆项目**
```bash
cd shi_yi
```

2. **安装依赖**
```bash
flutter pub get
```

3. **生成Hive适配器**（如果修改了模型）
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **启用鸿蒙平台支持**（如需要）
```bash
flutter config --enable-ohos
```

5. **运行应用**
```bash
# 使用脚本运行（推荐）
./run.sh macos    # macOS
./run.sh ios      # iOS
./run.sh android  # Android
./run.sh ohos     # 鸿蒙设备
./run.sh chrome   # Chrome

# 或直接使用 flutter run
flutter run                    # 自动选择设备
flutter run -d macos           # macOS
flutter run -d ios             # iOS
flutter run -d android         # Android
flutter run -d 127.0.0.1:5555  # 鸿蒙设备（使用设备ID）

# 查看可用设备
flutter devices
```

## 功能说明

### 知识库

- 浏览8种汉服形制介绍
- 搜索知识库内容
- 收藏喜欢的条目
- 按分类筛选（形制科普/历史背景/穿搭指南）

### 衣橱管理

- 添加汉服到衣橱
- 记录尺码信息（胸围、腰围、衣长等）
- 按朝代和类型筛选
- 网格/列表视图切换
- 编辑和删除功能

### 3D展示

- 查看3D模型列表
- 加载和显示GLB格式模型
- 支持多种渲染方案（ModelViewer / WebView / 占位视图）
- 自动降级机制，确保在不同平台上都能使用
- 支持360°旋转查看、缩放、AR等功能
- 兼容鸿蒙、Android、iOS、macOS等平台

## 数据初始化

应用首次启动时会自动初始化知识库数据，包含：
- 唐制齐胸襦裙
- 唐制齐腰襦裙
- 宋制褙子
- 宋制百迭裙
- 明制马面裙
- 明制袄裙
- 道袍
- 汉服历史演变

## 3D模型

当前使用 `hanfu-test.glb` 作为测试模型，位于：
```
assets/models/hanfu-test.glb
```

后续版本将支持：
- 更多3D模型
- 360°旋转查看
- 缩放和交互
- 模型分类管理

## 开发计划

### MVP版本（当前）
- ✅ 知识库功能
- ✅ 衣橱管理功能
- ✅ 3D展示基础

### 后续版本
- [ ] AI形制识别
- [ ] AI穿搭推荐
- ✅ 完整的3D渲染（360°旋转）- 已实现
- [ ] 更多3D模型
- [ ] 数据导出/导入
- [ ] 云端同步（可选）

## 注意事项

1. **Hive适配器**: 如果修改了数据模型，需要重新运行 `build_runner` 生成适配器
2. **3D模型**: 
   - 支持 GLB 格式的3D模型
   - 使用多种渲染方案（ModelViewer / WebView / 占位视图），自动选择最适合的方式
   - 在鸿蒙平台上会自动降级到 WebView 方案
   - 如果所有方案都不可用，会显示占位视图
   - 支持手动切换渲染方案
3. **数据存储**: 所有数据存储在本地，不会上传到云端

## 问题反馈

如有问题或建议，请提交Issue。

---

**拾衣坊（Shiyi）** - 让汉服管理更简单，让穿搭更有趣
