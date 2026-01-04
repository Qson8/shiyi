import 'package:hive/hive.dart';

part 'knowledge_item.g.dart';

@HiveType(typeId: 0)
class KnowledgeItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category; // 形制科普/历史背景/穿搭指南

  @HiveField(3)
  final String content;

  @HiveField(4)
  final List<String> images;

  @HiveField(5)
  final List<String> tags;

  @HiveField(6)
  bool isFavorite;

  @HiveField(7)
  final DateTime createdAt;

  KnowledgeItem({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    this.images = const [],
    this.tags = const [],
    this.isFavorite = false,
    required this.createdAt,
  });

  KnowledgeItem copyWith({
    String? id,
    String? title,
    String? category,
    String? content,
    List<String>? images,
    List<String>? tags,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return KnowledgeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

