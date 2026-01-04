import 'package:hive/hive.dart';

part 'hanfu_item.g.dart';

@HiveType(typeId: 1)
class HanfuItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dynasty; // 唐/宋/明/清/其他

  @HiveField(3)
  final String type; // 上装/下装/配饰/套装

  @HiveField(4)
  final Map<String, double> sizes; // 胸围/腰围/衣长等

  @HiveField(5)
  final List<String> imagePaths;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  String? notes; // 备注

  HanfuItem({
    required this.id,
    required this.name,
    required this.dynasty,
    required this.type,
    this.sizes = const {},
    this.imagePaths = const [],
    this.tags = const [],
    required this.createdAt,
    this.notes,
  });

  HanfuItem copyWith({
    String? id,
    String? name,
    String? dynasty,
    String? type,
    Map<String, double>? sizes,
    List<String>? imagePaths,
    List<String>? tags,
    DateTime? createdAt,
    String? notes,
  }) {
    return HanfuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      dynasty: dynasty ?? this.dynasty,
      type: type ?? this.type,
      sizes: sizes ?? this.sizes,
      imagePaths: imagePaths ?? this.imagePaths,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}

