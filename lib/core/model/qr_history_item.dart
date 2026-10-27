import 'package:hive/hive.dart';

class QrHistoryItem extends HiveObject {
  String id;
  String content;
  String type; // "scan" | "generate"
  String qrType; // "web" | "wifi" | "text" | "contact" | etc.
  DateTime timestamp;
  String? title; // optional display title

  QrHistoryItem({
    required this.id,
    required this.content,
    required this.type,
    required this.qrType,
    required this.timestamp,
    this.title,
  });
}

class QrHistoryItemAdapter extends TypeAdapter<QrHistoryItem> {
  @override
  final int typeId = 0;

  @override
  QrHistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QrHistoryItem(
      id: fields[0] as String,
      content: fields[1] as String,
      type: fields[2] as String,
      qrType: fields[3] as String,
      timestamp: fields[4] as DateTime,
      title: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QrHistoryItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.qrType)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrHistoryItemAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
