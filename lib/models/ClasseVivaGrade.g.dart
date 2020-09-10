// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ClasseVivaGrade.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClasseVivaGradeAdapter extends TypeAdapter<ClasseVivaGrade> {
  @override
  final int typeId = 4;

  @override
  ClasseVivaGrade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClasseVivaGrade(
      subject: fields[0] as String,
      grade: fields[1] as String,
      type: fields[2] as String,
      description: fields[3] as String,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ClasseVivaGrade obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.subject)
      ..writeByte(1)
      ..write(obj.grade)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClasseVivaGradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
