import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/knowledge_item.dart';
import 'database_service.dart';

class KnowledgeRepository {
  final Box<KnowledgeItem> _box = DatabaseService.knowledgeBox;
  List<KnowledgeItem>? _cachedItems;
  bool _isLoading = false;

  // 获取所有知识库条目（去重）
  List<KnowledgeItem> getAll() {
    List<KnowledgeItem> items;
    if (_cachedItems != null && _cachedItems!.isNotEmpty) {
      items = _cachedItems!;
    } else {
      items = _box.values.toList();
    }
    
    // 去重：根据ID去重
    final seenIds = <String>{};
    return items.where((item) {
      if (seenIds.contains(item.id)) {
        return false;
      }
      seenIds.add(item.id);
      return true;
    }).toList();
  }

  // 根据ID获取
  KnowledgeItem? getById(String id) {
    if (_cachedItems != null) {
      try {
        return _cachedItems!.firstWhere((item) => item.id == id);
      } catch (e) {
        return _box.get(id);
      }
    }
    return _box.get(id);
  }

  // 根据分类获取
  List<KnowledgeItem> getByCategory(String category) {
    final allItems = getAll();
    return allItems
        .where((item) => item.category == category)
        .toList();
  }

  // 搜索
  List<KnowledgeItem> search(String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    final allItems = getAll();
    return allItems.where((item) {
      return item.title.toLowerCase().contains(lowerKeyword) ||
          item.content.toLowerCase().contains(lowerKeyword) ||
          item.tags.any((tag) => tag.toLowerCase().contains(lowerKeyword));
    }).toList();
  }

  // 获取收藏的条目
  List<KnowledgeItem> getFavorites() {
    final allItems = getAll();
    return allItems.where((item) => item.isFavorite).toList();
  }

  // 添加或更新
  Future<void> save(KnowledgeItem item) async {
    await _box.put(item.id, item);
    // 更新缓存
    if (_cachedItems != null) {
      final index = _cachedItems!.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        _cachedItems![index] = item;
      } else {
        _cachedItems!.add(item);
      }
    }
  }

  // 切换收藏状态
  Future<void> toggleFavorite(String id) async {
    final item = getById(id);
    if (item != null) {
      item.isFavorite = !item.isFavorite;
      await _box.put(id, item);
      // 更新缓存
      if (_cachedItems != null) {
        final index = _cachedItems!.indexWhere((i) => i.id == id);
        if (index >= 0) {
          _cachedItems![index] = item;
        }
      }
    }
  }

  // 删除
  Future<void> delete(String id) async {
    await _box.delete(id);
    // 更新缓存
    if (_cachedItems != null) {
      _cachedItems!.removeWhere((item) => item.id == id);
    }
  }

  // 从JSON文件加载数据
  Future<void> loadFromJson({bool forceReload = false}) async {
    if (_isLoading) return;
    if (!forceReload && _cachedItems != null && _cachedItems!.isNotEmpty) {
      // 如果已经加载过且不强制重载，直接返回
      return;
    }
    _isLoading = true;

    try {
      // 读取JSON文件
      final String jsonString = await rootBundle.loadString('assets/data/knowledge_base.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> itemsJson = jsonData['items'] as List<dynamic>;

      // 转换为KnowledgeItem列表，并去重
      final seenIds = <String>{};
      final seenTitles = <String>{};
      _cachedItems = itemsJson.map((json) {
        return KnowledgeItem(
          id: json['id'] as String,
          title: json['title'] as String,
          category: json['category'] as String,
          content: json['content'] as String,
          images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          isFavorite: json['isFavorite'] as bool? ?? false,
          createdAt: DateTime.parse(json['createdAt'] as String),
        );
      }).where((item) {
        // 去重：根据ID和标题去重，只保留第一次出现的
        if (seenIds.contains(item.id) || seenTitles.contains(item.title)) {
          return false;
        }
        seenIds.add(item.id);
        seenTitles.add(item.title);
        return true;
      }).toList();

      // 如果强制重载，先清空Hive中不在JSON中的数据
      if (forceReload) {
        final jsonIds = seenIds.toSet();
        final hiveIds = _box.keys.cast<String>().toSet();
        final idsToDelete = hiveIds.difference(jsonIds);
        for (final id in idsToDelete) {
          await _box.delete(id);
        }
      }

      // 保存到Hive（用于收藏状态持久化），同时去重
      for (final item in _cachedItems!) {
        final existing = _box.get(item.id);
        if (existing != null) {
          // 保留收藏状态
          item.isFavorite = existing.isFavorite;
        }
        await _box.put(item.id, item);
      }

      print('成功加载 ${_cachedItems!.length} 条知识库数据（已去重，唯一标题数：${seenTitles.length}）');
    } catch (e) {
      print('加载JSON数据失败: $e');
      // 如果加载失败，使用默认数据
      await initDefaultData();
    } finally {
      _isLoading = false;
    }
  }

  // 初始化默认数据（备用方案）
  Future<void> initDefaultData() async {
    if (_box.isEmpty) {
      final defaultItems = _getDefaultKnowledgeItems();
      for (final item in defaultItems) {
        await _box.put(item.id, item);
      }
    }
  }

  List<KnowledgeItem> _getDefaultKnowledgeItems() {
    return [
      KnowledgeItem(
        id: 'tang-qixiong',
        title: '唐制齐胸襦裙',
        category: '形制科普',
        content: '齐胸襦裙是唐代流行的女装款式，特点是裙头位置在胸部，通过系带固定。上身为对襟或交领短襦，下身为高腰长裙，整体造型优雅飘逸，体现了唐代女性的雍容华贵。',
        tags: ['唐代', '女装', '襦裙'],
        createdAt: DateTime.now(),
      ),
    ];
  }
}
