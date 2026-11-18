import 'package:amarislam/core/constant/app_color.dart';
import 'package:amarislam/core/constant/extentions.dart';
import 'package:amarislam/models/ayah_model.dart';
import 'package:amarislam/models/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SurahDetailsController.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late final SurahDetailsController controller;

  @override
  void initState() {
    super.initState();
    // Using Get.put to ensure the controller is available
    controller = Get.put(SurahDetailsController());
    // Load ayahs for the specific surah
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAyahs(widget.surah.number);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => CustomScrollView(
            slivers: [
              _buildAppBar(),
              if (controller.isLoading.value)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColor.primary)),
                )
              else if (controller.ayahs.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "Content not available yet for this Surah",
                      style: GoogleFonts.poppins(fontSize: 18.sp, color: Colors.grey),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAyahItem(controller.ayahs[index], index),
                    childCount: controller.ayahs.length,
                  ),
                ),
            ],
          )),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250.h,
      pinned: true,
      backgroundColor: AppColor.primary,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.primary,
                AppColor.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/header_quran.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  40.height,
                  Text(
                    widget.surah.nameEnglish,
                    style: GoogleFonts.poppins(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.surah.nameBangla,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 20.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  10.height,
                  const Divider(color: Colors.white, indent: 100, endIndent: 100, thickness: 0.5),
                  10.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.surah.revelationType.toUpperCase(),
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      10.width,
                      const CircleAvatar(radius: 2, backgroundColor: Colors.white),
                      10.width,
                      Text(
                        "${widget.surah.numberOfAyahs} VERSES",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAyahItem(Ayah ayah, int index) {
    // Obx is not strictly necessary here because the parent is already an Obx
    // but it helps if we want to be explicit about what updates.
    // However, controller.ayahs.refresh() triggers the parent Obx.
    final bool isBookmarked = controller.isBookmarked(widget.surah.number, ayah.numberInSurah);
    final bool isPlaying = controller.playingAyahIndex.value == index;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: isPlaying ? AppColor.primary.withOpacity(0.05) : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColor.primary,
                  child: Text(
                    ayah.numberInSurah.toString(),
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => controller.copyAyah(ayah),
                  icon: const Icon(Icons.copy_outlined, color: AppColor.primary, size: 20),
                ),
                IconButton(
                  onPressed: () => controller.playAyah(index, widget.surah.number),
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                    color: AppColor.primary,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: () => controller.toggleBookmark(
                    widget.surah.number,
                    widget.surah.nameEnglish,
                    ayah.numberInSurah,
                  ),
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: AppColor.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          20.height,
          Text(
            ayah.textArabic,
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textBlack,
              height: 2,
            ),
          ),
          20.height,
          Text(
            ayah.textBangla,
            style: GoogleFonts.hindSiliguri(
              fontSize: 18.sp,
              color: AppColor.textBlack,
              height: 1.5,
            ),
          ),
          12.height,
          Text(
            ayah.textEnglish,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
