// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KnowledgeItemAdapter extends TypeAdapter<KnowledgeItem> {
  @override
  final int typeId = 0;

  @override
  KnowledgeItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KnowledgeItem(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as String,
      content: fields[3] as String,
      images: (fields[4] as List).cast<String>(),
      tags: (fields[5] as List).cast<String>(),
      isFavorite: fields[6] as bool,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, KnowledgeItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.images)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
