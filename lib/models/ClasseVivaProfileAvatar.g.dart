// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ClasseVivaProfileAvatar.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClasseVivaProfileAvatarAdapter
    extends TypeAdapter<ClasseVivaProfileAvatar> {
  @override
  final int typeId = 2;

  @override
  ClasseVivaProfileAvatar read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClasseVivaProfileAvatar(
      text: fields[0] as String,
      backgroundColor: fields[1] as Color,
      foregroundColor: fields[2] as Color,
    );
  }

  @override
  void write(BinaryWriter writer, ClasseVivaProfileAvatar obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.backgroundColor)
      ..writeByte(2)
      ..write(obj.foregroundColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClasseVivaProfileAvatarAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
