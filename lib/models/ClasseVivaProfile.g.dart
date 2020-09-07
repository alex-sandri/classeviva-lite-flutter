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
      name: fields[0] as String,
      school: fields[1] as String,
      profilePicUrl: fields[2] as String,
      avatar: fields[3] as ClasseVivaProfileAvatar,
    );
  }

  @override
  void write(BinaryWriter writer, ClasseVivaProfile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.school)
      ..writeByte(2)
      ..write(obj.profilePicUrl)
      ..writeByte(3)
      ..write(obj.avatar);
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
