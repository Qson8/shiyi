import 'dart:convert';
import 'package:flutter/services.dart';

/// 3D模型数据模型
class ModelItem {
  final String id;
  final String name;
  final String dynasty;
  final String type;
  final String path;
  final String description;
  final String? thumbnail;
  final List<String> tags;

  ModelItem({
    required this.id,
    required this.name,
    required this.dynasty,
    required this.type,
    required this.path,
    required this.description,
    this.thumbnail,
    this.tags = const [],
  });

  factory ModelItem.fromJson(Map<String, dynamic> json) {
    return ModelItem(
      id: json['id'] as String,
      name: json['name'] as String,
      dynasty: json['dynasty'] as String,
      type: json['type'] as String,
      path: json['path'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dynasty': dynasty,
      'type': type,
      'path': path,
      'description': description,
      'thumbnail': thumbnail,
      'tags': tags,
    };
  }
}

/// 3D模型数据仓库
class ModelRepository {
  static List<ModelItem>? _cachedModels;
  static bool _isLoading = false;

  /// 从JSON文件加载模型数据
  static Future<List<ModelItem>> loadFromJson({bool forceReload = false}) async {
    if (_isLoading) {
      // 如果正在加载，等待完成
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _cachedModels ?? [];
    }

    if (!forceReload && _cachedModels != null && _cachedModels!.isNotEmpty) {
      return _cachedModels!;
    }

    _isLoading = true;

    try {
      // 读取JSON文件
      final String jsonString = await rootBundle.loadString('assets/data/models.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> modelsJson = jsonData['models'] as List<dynamic>;

      // 转换为ModelItem列表
      _cachedModels = modelsJson.map((json) => ModelItem.fromJson(json as Map<String, dynamic>)).toList();

      print('成功加载 ${_cachedModels!.length} 个3D模型数据');
      return _cachedModels!;
    } catch (e) {
      print('加载模型数据失败: $e');
      // 如果加载失败，返回空列表或默认数据
      _cachedModels = getDefaultModels();
      return _cachedModels!;
    } finally {
      _isLoading = false;
    }
  }

  /// 获取所有模型
  static Future<List<ModelItem>> getAll() async {
    if (_cachedModels == null || _cachedModels!.isEmpty) {
      return await loadFromJson();
    }
    return _cachedModels!;
  }

  /// 根据ID获取模型
  static Future<ModelItem?> getById(String id) async {
    final models = await getAll();
    try {
      return models.firstWhere((model) => model.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 根据朝代筛选
  static Future<List<ModelItem>> getByDynasty(String dynasty) async {
    final models = await getAll();
    return models.where((model) => model.dynasty == dynasty).toList();
  }

  /// 根据类型筛选
  static Future<List<ModelItem>> getByType(String type) async {
    final models = await getAll();
    return models.where((model) => model.type == type).toList();
  }

  /// 搜索模型
  static Future<List<ModelItem>> search(String keyword) async {
    final lowerKeyword = keyword.toLowerCase();
    final models = await getAll();
    return models.where((model) {
      return model.name.toLowerCase().contains(lowerKeyword) ||
          model.dynasty.contains(keyword) ||
          model.type.contains(keyword) ||
          model.description.toLowerCase().contains(lowerKeyword) ||
          model.tags.any((tag) => tag.toLowerCase().contains(lowerKeyword));
    }).toList();
  }

  /// 获取默认模型（备用方案）
  static List<ModelItem> getDefaultModels() {
    return [
      ModelItem(
        id: 'hanfu-model-1',
        name: '宋制烟青褙子',
        dynasty: '宋代',
        type: '褙子',
        path: 'assets/models/hanfu-model-1.glb',
        description: '宋代流行的外衣，形制简洁优雅',
        tags: ['宋代', '褙子', '外衣'],
      ),
      ModelItem(
        id: 'hanfu-model-2',
        name: '明制马面裙',
        dynasty: '明代',
        type: '马面裙',
        path: 'assets/models/hanfu-model-2.glb',
        description: '明代最具代表性的女装下裳',
        tags: ['明代', '马面裙', '下裳'],
      ),
    ];
  }
}

