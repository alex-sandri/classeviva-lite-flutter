// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ClasseVivaAbsence.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClasseVivaAbsenceTypeAdapter extends TypeAdapter<ClasseVivaAbsenceType> {
  @override
  final int typeId = 9;

  @override
  ClasseVivaAbsenceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ClasseVivaAbsenceType.Absence;
      case 1:
        return ClasseVivaAbsenceType.Late;
      case 2:
        return ClasseVivaAbsenceType.ShortDelay;
      case 3:
        return ClasseVivaAbsenceType.EarlyExit;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, ClasseVivaAbsenceType obj) {
    switch (obj) {
      case ClasseVivaAbsenceType.Absence:
        writer.writeByte(0);
        break;
      case ClasseVivaAbsenceType.Late:
        writer.writeByte(1);
        break;
      case ClasseVivaAbsenceType.ShortDelay:
        writer.writeByte(2);
        break;
      case ClasseVivaAbsenceType.EarlyExit:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClasseVivaAbsenceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClasseVivaAbsenceStatusAdapter
    extends TypeAdapter<ClasseVivaAbsenceStatus> {
  @override
  final int typeId = 10;

  @override
  ClasseVivaAbsenceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ClasseVivaAbsenceStatus.Justified;
      case 1:
        return ClasseVivaAbsenceStatus.NotJustified;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, ClasseVivaAbsenceStatus obj) {
    switch (obj) {
      case ClasseVivaAbsenceStatus.Justified:
        writer.writeByte(0);
        break;
      case ClasseVivaAbsenceStatus.NotJustified:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClasseVivaAbsenceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClasseVivaAbsenceAdapter extends TypeAdapter<ClasseVivaAbsence> {
  @override
  final int typeId = 8;

  @override
  ClasseVivaAbsence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClasseVivaAbsence(
      from: fields[0] as DateTime,
      to: fields[1] as DateTime,
      description: fields[2] as String,
      type: fields[3] as ClasseVivaAbsenceType,
      status: fields[4] as ClasseVivaAbsenceStatus,
    );
  }

  @override
  void write(BinaryWriter writer, ClasseVivaAbsence obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClasseVivaAbsenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
