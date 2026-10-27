import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:adhan/adhan.dart';

import '../core/model/PrayerItem.dart';

class HomeController extends GetxController {
  // User information
  final userName = 'User Name'.obs;
  final profileImage = RxnString();
  var currentDate = ''.obs;

  // Demo location: Dhaka
  final Coordinates coordinates = Coordinates(23.8103, 90.4125);
  final prayerList = <PrayerItem>[].obs;
  final nextPrayerName = ''.obs;
  final nextPrayerTime = Rxn<DateTime>();
  final countdown = 'Loading...'.obs;

  Timer? _timer;
  DateTime? _loadedDate;

  @override
  void onInit() {
    super.onInit();
    getUserName();
    getCurrentDate();
    loadPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Date change হলে prayer times আবার calculate করো
      final now = DateTime.now();

      if (_loadedDate == null ||
          now.year != _loadedDate!.year ||
          now.month != _loadedDate!.month ||
          now.day != _loadedDate!.day) {
        loadPrayerTimes();
      } else {
        updateNextPrayer();
      }
    });
  }

  Future<void> getUserName() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('user_name') ?? 'User';
    final profile = prefs.getString('profile_image_path');

    userName.value = name;
    profileImage.value = profile;
  }

  void loadPrayerTimes() {
    final now = DateTime.now();

    final params = CalculationMethod.karachi.getParameters();

    params.madhab = Madhab.hanafi;

    final todayTimes = PrayerTimes.today(coordinates, params);

    prayerList.assignAll([
      PrayerItem(name: 'ফজর (Fajr)', time: todayTimes.fajr),
      PrayerItem(name: 'যোহর (Dhuhr)', time: todayTimes.dhuhr),
      PrayerItem(name: 'আসর (Asr)', time: todayTimes.asr),
      PrayerItem(name: 'মাগরিব (Maghrib)', time: todayTimes.maghrib),
      PrayerItem(name: 'এশা (Isha)', time: todayTimes.isha),
    ]);

    _loadedDate = DateTime(now.year, now.month, now.day);

    updateNextPrayer();
  }

  void updateNextPrayer() {
    final now = DateTime.now();

    // আজকের যে নামাজের সময় এখনো আসেনি, সেটি খুঁজবে
    PrayerItem? next;

    for (final prayer in prayerList) {
      if (prayer.time.isAfter(now)) {
        next = prayer;
        break;
      }
    }

    // আজকের সব নামাজের সময় চলে গেলে আগামীকালের ফজর
    if (next == null) {
      final tomorrow = now.add(const Duration(days: 1));

      final params = CalculationMethod.karachi.getParameters();

      params.madhab = Madhab.hanafi;

      final tomorrowTimes = PrayerTimes(
        coordinates,
        DateComponents.from(tomorrow),
        params,
      );

      next = PrayerItem(name: 'ফজর (Fajr)', time: tomorrowTimes.fajr);
    }

    nextPrayerName.value = next.name;
    nextPrayerTime.value = next.time;

    final remaining = next.time.difference(now);

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    countdown.value =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  void getCurrentDate() {
    DateTime now = DateTime.now();

    currentDate.value =
        DateFormat('EEEE, dd MMMM yyyy').format(now);
  }



  //quick access items
  final RxList<IslamicCategoryModel> categories =
      <IslamicCategoryModel>[
        const IslamicCategoryModel(
          id: 1,
          title: 'Al-Quran',
          subtitle: 'Read and listen Quran',
          icon: Icons.menu_book_rounded,
          route: '/quran',
        ),
        const IslamicCategoryModel(
          id: 2,
          title: 'Dua & Azkar',
          subtitle: 'Daily duas and zikr',
          icon: Icons.volunteer_activism_rounded,
          route: '/dua',
        ),
        const IslamicCategoryModel(
          id: 3,
          title: 'Namaz',
          subtitle: 'Prayer time and guide',
          icon: Icons.mosque_rounded,
          route: '/namaz',
        ),
        const IslamicCategoryModel(
          id: 4,
          title: 'Qibla',
          subtitle: 'Find Qibla direction',
          icon: Icons.explore_rounded,
          route: '/qibla',
        ),
        const IslamicCategoryModel(
          id: 5,
          title: 'Hadith',
          subtitle: 'Authentic Hadith',
          icon: Icons.auto_stories_rounded,
          route: '/hadith',
        ),
        const IslamicCategoryModel(
          id: 6,
          title: 'Digital Tasbih',
          subtitle: 'Count your zikr',
          icon: Icons.radio_button_checked,
          route: '/tasbih',
        ),
        const IslamicCategoryModel(
          id: 7,
          title: 'Islamic History',
          subtitle: 'Learn Islamic history',
          icon: Icons.history_edu_rounded,
          route: '/history',
        ),
        const IslamicCategoryModel(
          id: 8,
          title: 'Dream Interpretation',
          subtitle: 'Islamic dreams',
          icon: Icons.nightlight_round,
          route: '/dream',
        ),
        const IslamicCategoryModel(
          id: 9,
          title: '99 Names of Allah',
          subtitle: 'Asma ul Husna',
          icon: Icons.auto_awesome_rounded,
          route: '/names-of-allah',
        ),
        const IslamicCategoryModel(
          id: 10,
          title: 'Islamic Calendar',
          subtitle: 'Hijri dates and events',
          icon: Icons.calendar_month_rounded,
          route: '/calendar',
        ),
        const IslamicCategoryModel(
          id: 11,
          title: 'Zakat Calculator',
          subtitle: 'Calculate your Zakat',
          icon: Icons.calculate_rounded,
          route: '/zakat',
        ),
        const IslamicCategoryModel(
          id: 12,
          title: 'Daily Amal',
          subtitle: 'Track daily worship',
          icon: Icons.check_circle_outline_rounded,
          route: '/daily-amal',
        ),
        const IslamicCategoryModel(
          id: 13,
          title: 'Islamic Quiz',
          subtitle: 'Test Islamic knowledge',
          icon: Icons.quiz_rounded,
          route: '/quiz',
        ),
        const IslamicCategoryModel(
          id: 14,
          title: 'Hajj & Umrah',
          subtitle: 'Pilgrimage guide',
          icon: Icons.flight_rounded,
          route: '/hajj-umrah',
        ),
        const IslamicCategoryModel(
          id: 15,
          title: 'Islamic Audio',
          subtitle: 'Listen to Quran',
          icon: Icons.headphones_rounded,
          route: '/audio',
        ),
        const IslamicCategoryModel(
          id: 16,
          title: 'Islamic Quotes',
          subtitle: 'Daily reminders',
          icon: Icons.format_quote_rounded,
          route: '/quotes',
        ),
      ].obs;


  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
