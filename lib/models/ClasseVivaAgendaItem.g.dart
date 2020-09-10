// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ClasseVivaAgendaItem.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClasseVivaAgendaItemAdapter extends TypeAdapter<ClasseVivaAgendaItem> {
  @override
  final int typeId = 5;

  @override
  ClasseVivaAgendaItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClasseVivaAgendaItem(
      id: fields[0] as String,
      title: fields[1] as String,
      start: fields[2] as DateTime,
      end: fields[3] as DateTime,
      allDay: fields[4] as bool,
      data_inserimento: fields[5] as String,
      nota_2: fields[6] as String,
      master_id: fields[7] as String,
      classe_id: fields[8] as String,
      classe_desc: fields[9] as String,
      gruppo: fields[10] as int,
      autore_desc: fields[11] as String,
      autore_id: fields[12] as String,
      tipo: fields[13] as String,
      materia_desc: fields[14] as String,
      materia_id: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClasseVivaAgendaItem obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.start)
      ..writeByte(3)
      ..write(obj.end)
      ..writeByte(4)
      ..write(obj.allDay)
      ..writeByte(5)
      ..write(obj.data_inserimento)
      ..writeByte(6)
      ..write(obj.nota_2)
      ..writeByte(7)
      ..write(obj.master_id)
      ..writeByte(8)
      ..write(obj.classe_id)
      ..writeByte(9)
      ..write(obj.classe_desc)
      ..writeByte(10)
      ..write(obj.gruppo)
      ..writeByte(11)
      ..write(obj.autore_desc)
      ..writeByte(12)
      ..write(obj.autore_id)
      ..writeByte(13)
      ..write(obj.tipo)
      ..writeByte(14)
      ..write(obj.materia_desc)
      ..writeByte(15)
      ..write(obj.materia_id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClasseVivaAgendaItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
