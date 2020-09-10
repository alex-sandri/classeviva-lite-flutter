// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ClasseVivaCalendarLesson.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClasseVivaCalendarLessonAdapter
    extends TypeAdapter<ClasseVivaCalendarLesson> {
  @override
  final int typeId = 6;

  @override
  ClasseVivaCalendarLesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClasseVivaCalendarLesson(
      teacher: fields[0] as String,
      subject: fields[1] as String,
      type: fields[2] as String,
      description: fields[3] as String,
      hour: fields[4] as int,
      duration: fields[5] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, ClasseVivaCalendarLesson obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.teacher)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.hour)
      ..writeByte(5)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClasseVivaCalendarLessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
