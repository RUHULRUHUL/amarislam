import 'package:hive/hive.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 3)
class Bookmark {
  @HiveField(0)
  final int surahNumber;
  @HiveField(1)
  final String surahName;
  @HiveField(2)
  final int ayahNumber;
  @HiveField(3)
  final DateTime timestamp;

  Bookmark({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.timestamp,
  });
}
