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
  ConcatenatingAudioSource? _playlist;

  @override
  void onInit() {
    super.onInit();
    // Listen for player state changes
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      debugPrint("SurahDetailsController: PlayerState: playing=${state.playing}, state=${state.processingState}");
      
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
        playingAyahIndex.value = null;
        playingAyahIndex.refresh();
      }
    });

    // Listen for index changes to highlight the correct ayah
    audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        debugPrint("SurahDetailsController: Current index changed to $index");
        
        // Update the playing index and force UI refresh
        playingAyahIndex.value = index;
        playingAyahIndex.refresh();
        
        // Save last read if valid - wrapped in try-catch to prevent stream interruption
        try {
          if (currentSurahNumber.value != null && ayahs.isNotEmpty && index < ayahs.length) {
            HiveHelper().saveLastRead(currentSurahNumber.value!, ayahs[index].numberInSurah);
          }
        } catch (e) {
          debugPrint("Error saving last read: $e");
        }
      }
    });

    // Also sync with sequence state for additional reliability
    audioPlayer.sequenceStateStream.listen((state) {
      if (state != null && state.currentIndex != playingAyahIndex.value) {
        debugPrint("SurahDetailsController: Syncing index from sequence state: ${state.currentIndex}");
        playingAyahIndex.value = state.currentIndex;
        playingAyahIndex.refresh();
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
      // Stop any existing playback when loading new surah
      if (audioPlayer.playing) {
        await audioPlayer.stop();
      }
      
      // Reset playing index when loading new Surah
      playingAyahIndex.value = null;
      _playlist = null;
      currentSurahNumber.value = surahNumber;

      final String response = await rootBundle.loadString('assets/json/quran.json');
      if (response.isNotEmpty) {
        final List<dynamic> data = json.decode(response);
        final surahData = data.firstWhere(
          (s) => s['number'] == surahNumber,
          orElse: () => null,
        );
        if (surahData != null && surahData['ayahs'] != null) {
          ayahs.assignAll((surahData['ayahs'] as List).map((a) => Ayah.fromJson(a)).toList());
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

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    playingAyahIndex.value = null;
    isPlaying.value = false;
    _playlist = null;
  }

  Future<void> togglePlayPause() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      if ((audioPlayer.processingState == ProcessingState.idle || audioPlayer.processingState == ProcessingState.completed) && ayahs.isNotEmpty) {
        playAyah(0, currentSurahNumber.value ?? 0);
      } else {
        await audioPlayer.play();
      }
    }
  }

  Future<void> playAyah(int index, int surahNumber) async {
    try {
      debugPrint("SurahDetailsController: playAyah(index: $index, surah: $surahNumber)");
      
      // If surah changed or playlist not initialized
      if (currentSurahNumber.value != surahNumber || _playlist == null) {
        currentSurahNumber.value = surahNumber;
        
        _playlist = ConcatenatingAudioSource(
          useLazyPreparation: true,
          children: ayahs.map((ayah) => AudioSource.uri(
            Uri.parse("https://cdn.islamic.network/quran/audio/128/ar.alafasy/${ayah.number}.mp3"),
            tag: ayah,
          )).toList(),
        );
        
        await audioPlayer.setAudioSource(_playlist!);
      }

      // Update index immediately for UI feedback
      playingAyahIndex.value = index;

      await audioPlayer.seek(Duration.zero, index: index);
      audioPlayer.play();
      
    } catch (e) {
      debugPrint("Error playing audio: $e");
      Get.snackbar("Error", "Error playing audio. Please check your connection.");
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
