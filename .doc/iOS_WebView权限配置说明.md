# iOS WebView 权限配置说明

## 问题描述

在 iOS 17+ 上使用 WebView 时，可能会出现以下错误：
```
Error acquiring assertion: <Error Domain=RBSServiceErrorDomain Code=1 
"((target is not running or doesn't have entitlement 
com.apple.developer.web-browser-engine.rendering AND ...))"
```

这是因为 iOS 17+ 要求应用明确声明 WebView 相关的权限。

## 解决方案

### 方法1：在 Xcode 中手动配置（推荐）

1. **打开 Xcode 项目**
   ```bash
   cd shi_yi/ios
   open Runner.xcworkspace
   ```

2. **选择 Runner target**
   - 在左侧项目导航器中，选择 `Runner` 项目
   - 选择 `Runner` target
   - 切换到 `Signing & Capabilities` 标签

3. **添加 Web Browser Engine 权限**
   - 点击 `+ Capability` 按钮
   - 搜索并添加以下权限：
     - `Web Browser Engine - Rendering`
     - `Web Browser Engine - Networking`
     - `Web Browser Engine - Web Content`

4. **或者直接编辑 entitlements 文件**
   - 在项目导航器中找到 `Runner.entitlements` 文件（如果不存在，需要创建）
   - 添加以下内容：
   ```xml
   <key>com.apple.developer.web-browser-engine.rendering</key>
   <true/>
   <key>com.apple.developer.web-browser-engine.networking</key>
   <true/>
   <key>com.apple.developer.web-browser-engine.webcontent</key>
   <true/>
   ```

5. **在 Build Settings 中链接 entitlements**
   - 选择 `Runner` target
   - 切换到 `Build Settings` 标签
   - 搜索 `Code Signing Entitlements`
   - 设置为 `Runner/Runner.entitlements`

### 方法2：使用命令行配置（如果 Xcode 不可用）

1. **确保 entitlements 文件存在**
   - 文件路径：`ios/Runner/Runner.entitlements`
   - 内容已在项目中创建

2. **更新 Xcode 项目配置**
   - 需要在 Xcode 中手动添加文件引用
   - 或者在 `project.pbxproj` 中添加相应配置

### 方法3：临时解决方案（仅用于开发测试）

如果上述方法不可行，可以尝试：

1. **降级 webview_flutter 版本**
   ```yaml
   webview_flutter: ^4.0.0  # 使用较旧版本
   ```

2. **或者使用不同的 WebView 实现**
   - 考虑使用 `flutter_inappwebview` 等替代方案

## 注意事项

1. **App Store 审核**
   - 这些权限在提交到 App Store 时可能需要说明用途
   - 确保在 App Store Connect 中说明使用 WebView 的原因

2. **仅开发环境**
   - 如果只是开发测试，可以暂时忽略这些警告
   - 但生产环境必须正确配置

3. **iOS 版本要求**
   - 这些权限要求主要影响 iOS 17+
   - iOS 16 及以下版本可能不需要

## 验证配置

配置完成后，重新运行应用：
```bash
flutter clean
flutter pub get
flutter run
```

如果配置正确，错误应该消失。

## 已完成的配置

✅ 已创建 `ios/Runner/Runner.entitlements` 文件
✅ 已添加必要的权限配置
✅ 已更新 `Info.plist` 添加网络权限

⚠️ **需要在 Xcode 中手动链接 entitlements 文件到项目配置**

