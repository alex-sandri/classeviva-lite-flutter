// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ClasseVivaProfile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClasseVivaProfileAdapter extends TypeAdapter<ClasseVivaProfile> {
  @override
  final int typeId = 1;

  @override
  ClasseVivaProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClasseVivaProfile(
      profilePic: fields[2] as CircleAvatar,
      avatar: fields[3] as CircleAvatar,
    );
  }

  @override
  void write(BinaryWriter writer, ClasseVivaProfile obj) {
    writer
      ..writeByte(4)
      ..writeByte(2)
      ..write(obj.profilePic)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.school);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClasseVivaProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
