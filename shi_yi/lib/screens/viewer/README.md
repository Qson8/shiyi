# 3D模型查看器

## 功能说明

3D模型查看器支持多种渲染方案，自动选择最适合的方式：

### 支持的方案

1. **ModelViewer (推荐)**
   - 使用 `model_viewer_plus` 包
   - 原生渲染，性能更好
   - 支持 AR、自动旋转、相机控制
   - 兼容性最好

2. **WebView + Three.js (降级方案)**
   - 当 ModelViewer 不可用时自动切换
   - 使用 WebView 加载 Three.js 渲染
   - 支持交互式3D查看

3. **占位视图 (最后方案)**
   - 当所有3D方案都不可用时显示
   - 显示模型信息和错误提示
   - 提供重试和切换方案选项

## 使用方法

```dart
ModelViewerScreen(
  modelName: '汉服测试模型',
  modelPath: null, // 如果为 null，会从 assets/models/hanfu-test.glb 加载
)
```

## 自动降级机制

查看器会按以下顺序尝试：

1. 首先尝试 ModelViewer（如果可用）
2. 如果 ModelViewer 失败，自动切换到 WebView 方案
3. 如果 WebView 也失败，显示占位视图

## 手动切换方案

用户可以通过右上角菜单手动切换：
- 使用 ModelViewer
- 使用 WebView
- 占位视图

## 平台兼容性

- ✅ Android: 完全支持
- ✅ iOS: 完全支持
- ✅ macOS: 完全支持
- ✅ Web: 支持（WebView 方案）
- ⚠️ 鸿蒙: ModelViewer 可能受限，会自动降级到 WebView

## 注意事项

1. 模型文件需要是 GLB 格式
2. 确保模型文件在 `assets/models/` 目录下
3. 在鸿蒙平台上，如果 ModelViewer 不可用，会自动使用 WebView 方案

