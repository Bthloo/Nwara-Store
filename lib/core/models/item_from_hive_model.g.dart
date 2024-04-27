// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_from_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemFromHiveAdapter extends TypeAdapter<ItemFromHive> {
  @override
  final int typeId = 4;

  @override
  ItemFromHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemFromHive(
      itemModel: fields[0] as ItemModel,
      key: fields[1] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, ItemFromHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.itemModel)
      ..writeByte(1)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemFromHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
