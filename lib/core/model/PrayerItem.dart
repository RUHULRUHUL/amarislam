import 'package:flutter/material.dart';

class PrayerItem {
  final String name;
  final DateTime time;

  PrayerItem({
    required this.name,
    required this.time,
  });
}

class IslamicCategoryModel {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const IslamicCategoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}
