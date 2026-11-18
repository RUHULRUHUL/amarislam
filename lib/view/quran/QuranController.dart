import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:amarislam/models/surah_model.dart';

class QuranController extends GetxController {
  // স্পষ্টভাবে RxList টাইপ ডিফাইন করা হয়েছে যাতে টাইপ এরর না হয়
  final RxList<Surah> allSurahs = RxList<Surah>([]);
  final RxList<Surah> filteredSurahs = RxList<Surah>([]);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSurahList();
  }

  Future<void> _loadSurahList() async {
    try {
      isLoading.value = true;
      final String response = await rootBundle.loadString('assets/json/surahs.json');
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      
      // স্পষ্ট টাইপ কাস্টিং নিশ্চিত করা হয়েছে
      final List<Surah> surahList = data.map((dynamic json) {
        return Surah.fromJson(json as Map<String, dynamic>);
      }).toList();
      
      // .assignAll() ব্যবহার করা হয়েছে যা RxList আপডেট করার সঠিক নিয়ম
      allSurahs.assignAll(surahList);
      filteredSurahs.assignAll(surahList);
    } catch (e) {
      print("Error loading surahs: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterSurah(String query) {
    if (query.isEmpty) {
      // RxList এর ডাটা অন্য RxList এ সেট করতে assignAll ব্যবহার করুন
      filteredSurahs.assignAll(allSurahs);
    } else {
      final String searchLower = query.toLowerCase();
      // filtering করার পর প্রাপ্ত List<Surah> কে assignAll দিয়ে সেট করা হয়েছে
      final List<Surah> result = allSurahs.where((Surah surah) {
        return surah.nameEnglish.toLowerCase().contains(searchLower) ||
            surah.nameBangla.toLowerCase().contains(searchLower) ||
            surah.nameArabic.contains(query) ||
            surah.number.toString().contains(query);
      }).toList();

      filteredSurahs.assignAll(result);
    }
  }
}
