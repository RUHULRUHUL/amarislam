import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/ayah_model.dart';
import '../../models/bookmark_model.dart';
import '../../core/helper/hive_helper.dart';

class SurahDetailsController extends GetxController {
  final RxList<Ayah> ayahs = <Ayah>[].obs;
  final RxBool isLoading = true.obs;
  final RxnInt playingAyahIndex = RxnInt();
  final AudioPlayer audioPlayer = AudioPlayer();
  final RxBool isPlaying = false.obs;
  final RxnInt currentSurahNumber = RxnInt();

  @override
  void onInit() {
    super.onInit();
    // Listen for player state changes
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      
      // Auto play next ayah when finished
      if (state.processingState == ProcessingState.completed) {
        playNextAyah();
      }
    });
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  Future<void> loadAyahs(int surahNumber) async {
    try {
      isLoading.value = true;
      final String response = await rootBundle.loadString('assets/json/quran.json');
      if (response.isNotEmpty) {
        final List<dynamic> data = json.decode(response);
        final surahData = data.firstWhere(
          (s) => s['number'] == surahNumber,
          orElse: () => null,
        );
        if (surahData != null && surahData['ayahs'] != null) {
          ayahs.value = (surahData['ayahs'] as List).map((a) => Ayah.fromJson(a)).toList();
        } else {
          ayahs.clear();
        }
      } else {
        ayahs.clear();
      }
    } catch (e) {
      debugPrint("Error loading ayahs: $e");
      ayahs.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> playNextAyah() async {
    if (playingAyahIndex.value != null && playingAyahIndex.value! < ayahs.length - 1) {
      playAyah(playingAyahIndex.value! + 1, currentSurahNumber.value!);
    } else {
      playingAyahIndex.value = null;
      isPlaying.value = false;
    }
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    playingAyahIndex.value = null;
    isPlaying.value = false;
  }

  Future<void> togglePlayPause() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  Future<void> playAyah(int index, int surahNumber) async {
    try {
      currentSurahNumber.value = surahNumber;
      
      if (playingAyahIndex.value == index && audioPlayer.playing) {
        await audioPlayer.pause();
        return;
      }

      if (playingAyahIndex.value == index && !audioPlayer.playing && audioPlayer.processingState != ProcessingState.idle) {
        await audioPlayer.play();
        return;
      }

      final ayah = ayahs[index];
      final audioUrl = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/${ayah.number}.mp3";
      
      playingAyahIndex.value = index;

      await audioPlayer.setUrl(audioUrl);
      audioPlayer.play();

      // Save last read when playing
      HiveHelper().saveLastRead(surahNumber, ayah.numberInSurah);
    } catch (e) {
      debugPrint("Error playing audio: $e");
      playingAyahIndex.value = null;
      Get.snackbar(
        "Error",
        "Error playing audio. Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void toggleBookmark(int surahNumber, String surahName, int ayahNumber) {
    if (isBookmarked(surahNumber, ayahNumber)) {
      HiveHelper().removeBookmark(surahNumber, ayahNumber);
    } else {
      HiveHelper().addBookmark(Bookmark(
        surahNumber: surahNumber,
        surahName: surahName,
        ayahNumber: ayahNumber,
        timestamp: DateTime.now(),
      ));
    }
    ayahs.refresh();
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    return HiveHelper().isBookmarked(surahNumber, ayahNumber);
  }

  void saveLastRead(int surahNumber, int ayahNumber) {
    HiveHelper().saveLastRead(surahNumber, ayahNumber);
    Get.snackbar(
      "Success",
      "Marked as last read",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void copyAyah(Ayah ayah) {
    Clipboard.setData(ClipboardData(
      text: "${ayah.textArabic}\n\n${ayah.textBangla}\n\n${ayah.textEnglish}"
    ));
    Get.snackbar(
      "Copied",
      "Copied to clipboard",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
