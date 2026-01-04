import 'package:hive/hive.dart';
import '../models/hanfu_item.dart';
import 'database_service.dart';

class WardrobeRepository {
  final Box<HanfuItem> _box = DatabaseService.wardrobeBox;

  // 获取所有汉服
  List<HanfuItem> getAll() {
    return _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 根据ID获取
  HanfuItem? getById(String id) {
    return _box.get(id);
  }

  // 根据朝代筛选
  List<HanfuItem> getByDynasty(String dynasty) {
    return _box.values
        .where((item) => item.dynasty == dynasty)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 根据类型筛选
  List<HanfuItem> getByType(String type) {
    return _box.values
        .where((item) => item.type == type)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 搜索
  List<HanfuItem> search(String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    return _box.values.where((item) {
      return item.name.toLowerCase().contains(lowerKeyword) ||
          item.dynasty.contains(keyword) ||
          item.type.contains(keyword) ||
          item.tags.any((tag) => tag.toLowerCase().contains(lowerKeyword));
    }).toList();
  }

  // 添加或更新
  Future<void> save(HanfuItem item) async {
    await _box.put(item.id, item);
  }

  // 删除
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  // 获取统计信息
  Map<String, int> getStatistics() {
    final items = _box.values.toList();
    return {
      'total': items.length,
      'tang': items.where((i) => i.dynasty == '唐').length,
      'song': items.where((i) => i.dynasty == '宋').length,
      'ming': items.where((i) => i.dynasty == '明').length,
    };
  }
}

