import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../model/app_settings.dart';
import '../model/qr_history_item.dart';

class HiveHelper {
  static final HiveHelper _instance = HiveHelper._internal();
  factory HiveHelper() => _instance;
  HiveHelper._internal();

  late Box<QrHistoryItem> _historyBox;
  late Box<AppSettings> _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(QrHistoryItemAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    _historyBox = await Hive.openBox<QrHistoryItem>('historyBox');
    _settingsBox = await Hive.openBox<AppSettings>('settingsBox');

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

  // ==================== UTILS ====================

  String generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
  }
}
