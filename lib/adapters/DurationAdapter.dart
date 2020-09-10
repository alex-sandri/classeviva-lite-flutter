import 'package:hive/hive.dart';

class DurationAdapter extends TypeAdapter<Duration> {
  @override
  Duration read(BinaryReader reader) {
    final durationValue = reader.readString();
    return Duration(
      hours: int.parse(durationValue.split(":").first),
      minutes: int.parse(durationValue.split(":")[1]),
      seconds: int.parse(durationValue.split(":").last.split(".").first),
      microseconds: int.parse(durationValue.split(":").last.split(".").last),
    );
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeString(obj.toString());
  }

  @override
  int get typeId => 201;
}