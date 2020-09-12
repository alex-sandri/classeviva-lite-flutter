// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ClasseVivaGradesPeriod.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClasseVivaGradesPeriodAdapter
    extends TypeAdapter<ClasseVivaGradesPeriod> {
  @override
  final int typeId = 7;

  @override
  ClasseVivaGradesPeriod read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClasseVivaGradesPeriod(
      name: fields[0] as String,
      grades: (fields[1] as List)?.cast<ClasseVivaGrade>(),
    );
  }

  @override
  void write(BinaryWriter writer, ClasseVivaGradesPeriod obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.grades);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClasseVivaGradesPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
