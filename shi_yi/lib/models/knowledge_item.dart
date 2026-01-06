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

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'images': images,
      'tags': tags,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory KnowledgeItem.fromJson(Map<String, dynamic> json) {
    return KnowledgeItem(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      content: json['content'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      tags: List<String>.from(json['tags'] as List? ?? []),
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

