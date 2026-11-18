import 'dart:math';

import 'package:amarislam/models/bookmark_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/app_settings.dart';
import '../model/qr_history_item.dart';

class HiveHelper {
  static final HiveHelper _instance = HiveHelper._internal();
  factory HiveHelper() => _instance;
  HiveHelper._internal();

  late Box<QrHistoryItem> _historyBox;
  late Box<AppSettings> _settingsBox;
  late Box<Bookmark> _bookmarkBox;
  late Box _miscBox;

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(QrHistoryItemAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(BookmarkAdapter());

    _historyBox = await Hive.openBox<QrHistoryItem>('historyBox');
    _settingsBox = await Hive.openBox<AppSettings>('settingsBox');
    _bookmarkBox = await Hive.openBox<Bookmark>('bookmarkBox');
    _miscBox = await Hive.openBox('miscBox');

    // Initialize default settings if empty
    if (_settingsBox.isEmpty) {
      await _settingsBox.put('appSettings', AppSettings());
    }
  }

  // ==================== HISTORY ====================

  Future<void> addHistory(QrHistoryItem item) async {
    await _historyBox.put(item.id, item);
  }

  List<QrHistoryItem> getAllHistory() {
    return _historyBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<QrHistoryItem> getHistoryByType(String type) {
    return _historyBox.values
        .where((item) => item.type == type)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deleteHistory(String id) async {
    await _historyBox.delete(id);
  }

  Future<void> clearAllHistory() async {
    await _historyBox.clear();
  }

  int get historyCount => _historyBox.length;

  // ==================== SETTINGS ====================

  AppSettings getSettings() {
    return _settingsBox.get('appSettings') ?? AppSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _settingsBox.put('appSettings', settings);
  }

  Future<void> setVibrate(bool value) async {
    final settings = getSettings();
    settings.vibrateOnScan = value;
    await updateSettings(settings);
  }

  Future<void> setBeep(bool value) async {
    final settings = getSettings();
    settings.beepOnScan = value;
    await updateSettings(settings);
  }

  bool get vibrateOnScan => getSettings().vibrateOnScan;
  bool get beepOnScan => getSettings().beepOnScan;

  // ==================== BOOKMARKS ====================

  Future<void> addBookmark(Bookmark bookmark) async {
    final key = "${bookmark.surahNumber}_${bookmark.ayahNumber}";
    await _bookmarkBox.put(key, bookmark);
  }

  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    final key = "${surahNumber}_${ayahNumber}";
    await _bookmarkBox.delete(key);
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    final key = "${surahNumber}_${ayahNumber}";
    return _bookmarkBox.containsKey(key);
  }

  List<Bookmark> getAllBookmarks() {
    return _bookmarkBox.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> saveLastRead(int surahNumber, int ayahNumber) async {
    await _miscBox.put('lastReadSurah', surahNumber);
    await _miscBox.put('lastReadAyah', ayahNumber);
  }

  Map<String, int?> getLastRead() {
    return {
      'surah': _miscBox.get('lastReadSurah') as int?,
      'ayah': _miscBox.get('lastReadAyah') as int?,
    };
  }

  // ==================== UTILS ====================

  String generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
  }
}
