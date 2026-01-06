import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'database_service.dart';
import '../models/hanfu_item.dart';
import '../models/knowledge_item.dart';

/// 设置服务 - 管理应用设置和用户偏好
class SettingsService {
  static const String _keyAutoRotate = 'auto_rotate';
  static const String _keyRenderQuality = 'render_quality';
  static const String _keyFontSize = 'font_size';
  static const String _keyTheme = 'theme';

  static SharedPreferences? _prefs;

  /// 初始化设置服务
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 获取自动旋转设置
  static bool getAutoRotate() {
    return _prefs?.getBool(_keyAutoRotate) ?? true;
  }

  /// 设置自动旋转
  static Future<void> setAutoRotate(bool value) async {
    await _prefs?.setBool(_keyAutoRotate, value);
  }

  /// 获取渲染质量 (low, medium, high)
  static String getRenderQuality() {
    return _prefs?.getString(_keyRenderQuality) ?? 'medium';
  }

  /// 设置渲染质量
  static Future<void> setRenderQuality(String quality) async {
    await _prefs?.setString(_keyRenderQuality, quality);
  }

  /// 获取字体大小倍数 (0.8, 0.9, 1.0, 1.1, 1.2)
  static double getFontSize() {
    return _prefs?.getDouble(_keyFontSize) ?? 1.0;
  }

  /// 设置字体大小
  static Future<void> setFontSize(double size) async {
    await _prefs?.setDouble(_keyFontSize, size);
  }

  /// 获取主题设置
  static String getTheme() {
    return _prefs?.getString(_keyTheme) ?? 'light';
  }

  /// 设置主题
  static Future<void> setTheme(String theme) async {
    await _prefs?.setString(_keyTheme, theme);
  }

  /// 获取数据库大小(字节)
  static Future<int> getDatabaseSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final hivePath = directory.path;
      
      int totalSize = 0;
      
      // 计算Hive数据库文件大小
      final knowledgeFile = File('$hivePath/knowledge.hive');
      final wardrobeFile = File('$hivePath/wardrobe.hive');
      
      if (await knowledgeFile.exists()) {
        totalSize += await knowledgeFile.length();
      }
      if (await wardrobeFile.exists()) {
        totalSize += await wardrobeFile.length();
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  /// 获取缓存信息
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      int imageCacheSize = 0;
      int tempFileSize = 0;
      int totalCacheSize = 0;
      
      // 计算图片缓存大小
      final imageDir = Directory('${directory.path}/wardrobe_images');
      if (await imageDir.exists()) {
        await for (final entity in imageDir.list(recursive: true)) {
          if (entity is File) {
            imageCacheSize += await entity.length();
          }
        }
      }
      
      // 计算临时文件大小（3D模型临时文件等）
      final tempDir = Directory('${directory.path}/temp');
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list(recursive: true)) {
          if (entity is File) {
            tempFileSize += await entity.length();
          }
        }
      }
      
      totalCacheSize = imageCacheSize + tempFileSize;
      
      return {
        'imageCache': imageCacheSize,
        'tempFiles': tempFileSize,
        'total': totalCacheSize,
      };
    } catch (e) {
      return {
        'imageCache': 0,
        'tempFiles': 0,
        'total': 0,
      };
    }
  }

  /// 清理缓存
  static Future<Map<String, dynamic>> clearCache({
    bool clearImageCache = true,
    bool clearTempFiles = true,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      int clearedImageCache = 0;
      int clearedTempFiles = 0;
      
      // 清理图片缓存
      if (clearImageCache) {
        final imageDir = Directory('${directory.path}/wardrobe_images');
        if (await imageDir.exists()) {
          await for (final entity in imageDir.list(recursive: true)) {
            if (entity is File) {
              clearedImageCache += await entity.length();
              await entity.delete();
            }
          }
        }
      }
      
      // 清理临时文件
      if (clearTempFiles) {
        final tempDir = Directory('${directory.path}/temp');
        if (await tempDir.exists()) {
          await for (final entity in tempDir.list(recursive: true)) {
            if (entity is File) {
              clearedTempFiles += await entity.length();
              await entity.delete();
            }
          }
        }
      }
      
      return {
        'success': true,
        'clearedImageCache': clearedImageCache,
        'clearedTempFiles': clearedTempFiles,
        'totalCleared': clearedImageCache + clearedTempFiles,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'clearedImageCache': 0,
        'clearedTempFiles': 0,
        'totalCleared': 0,
      };
    }
  }

  /// 导出数据为JSON
  static Future<String?> exportData() async {
    try {
      final wardrobeRepo = DatabaseService.wardrobeBox;
      final knowledgeRepo = DatabaseService.knowledgeBox;
      
      final wardrobeData = wardrobeRepo.values.map((item) => item.toJson()).toList();
      final knowledgeData = knowledgeRepo.values.map((item) => item.toJson()).toList();
      
      final exportData = {
        'wardrobe': wardrobeData,
        'knowledge': knowledgeData,
        'exportTime': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
      
      return jsonEncode(exportData);
    } catch (e) {
      return null;
    }
  }

  /// 从JSON导入数据
  static Future<Map<String, dynamic>> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final wardrobeRepo = DatabaseService.wardrobeBox;
      final knowledgeRepo = DatabaseService.knowledgeBox;
      
      int wardrobeCount = 0;
      int knowledgeCount = 0;
      
      // 导入衣橱数据
      if (data.containsKey('wardrobe')) {
        final wardrobeList = data['wardrobe'] as List;
        for (var item in wardrobeList) {
          try {
            final hanfuItem = HanfuItem.fromJson(item as Map<String, dynamic>);
            await wardrobeRepo.put(hanfuItem.id, hanfuItem);
            wardrobeCount++;
          } catch (e) {
            // 跳过无效数据
          }
        }
      }
      
      // 导入知识库数据
      if (data.containsKey('knowledge')) {
        final knowledgeList = data['knowledge'] as List;
        for (var item in knowledgeList) {
          try {
            final knowledgeItem = KnowledgeItem.fromJson(item as Map<String, dynamic>);
            await knowledgeRepo.put(knowledgeItem.id, knowledgeItem);
            knowledgeCount++;
          } catch (e) {
            // 跳过无效数据
          }
        }
      }
      
      return {
        'success': true,
        'wardrobeCount': wardrobeCount,
        'knowledgeCount': knowledgeCount,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 清除所有数据(危险操作)
  static Future<bool> clearAllData() async {
    try {
      final wardrobeRepo = DatabaseService.wardrobeBox;
      final knowledgeRepo = DatabaseService.knowledgeBox;
      
      await wardrobeRepo.clear();
      await knowledgeRepo.clear();
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

