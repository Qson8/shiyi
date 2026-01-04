// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hanfu_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HanfuItemAdapter extends TypeAdapter<HanfuItem> {
  @override
  final int typeId = 1;

  @override
  HanfuItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HanfuItem(
      id: fields[0] as String,
      name: fields[1] as String,
      dynasty: fields[2] as String,
      type: fields[3] as String,
      sizes: (fields[4] as Map).cast<String, double>(),
      imagePaths: (fields[5] as List).cast<String>(),
      tags: (fields[6] as List).cast<String>(),
      createdAt: fields[7] as DateTime,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HanfuItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dynasty)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.sizes)
      ..writeByte(5)
      ..write(obj.imagePaths)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HanfuItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
