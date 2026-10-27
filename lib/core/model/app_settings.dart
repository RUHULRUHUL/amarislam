import 'package:hive/hive.dart';

class AppSettings extends HiveObject {
  bool vibrateOnScan;
  bool beepOnScan;

  AppSettings({
    this.vibrateOnScan = false,
    this.beepOnScan = false,
  });
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 1;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      vibrateOnScan: fields[0] as bool,
      beepOnScan: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.vibrateOnScan)
      ..writeByte(1)
      ..write(obj.beepOnScan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
