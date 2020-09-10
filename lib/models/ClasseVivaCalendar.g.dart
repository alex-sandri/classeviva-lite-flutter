// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ClasseVivaCalendar.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClasseVivaCalendarAdapter extends TypeAdapter<ClasseVivaCalendar> {
  @override
  final int typeId = 3;

  @override
  ClasseVivaCalendar read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClasseVivaCalendar(
      date: fields[0] as DateTime,
      grades: (fields[1] as List)?.cast<ClasseVivaGrade>(),
      lessons: (fields[2] as List)?.cast<ClasseVivaCalendarLesson>(),
      agenda: (fields[3] as List)?.cast<ClasseVivaAgendaItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, ClasseVivaCalendar obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.grades)
      ..writeByte(2)
      ..write(obj.lessons)
      ..writeByte(3)
      ..write(obj.agenda);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClasseVivaCalendarAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
