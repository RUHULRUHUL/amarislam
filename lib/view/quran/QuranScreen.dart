import 'package:amarislam/core/constant/app_color.dart';
import 'package:amarislam/core/constant/extentions.dart';
import 'package:amarislam/models/surah_model.dart';
import 'package:amarislam/core/helper/hive_helper.dart';
import 'package:amarislam/view/quran/QuranController.dart';
import 'package:amarislam/view/quran/SurahDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  // Get.find এর বদলে Get.put ব্যবহার করা নিরাপদ যদি এটিই প্রথম স্ক্রিন হয়
  final QuranController controller = Get.put(QuranController());
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColor.primary),
                    )
                  : _buildSurahList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Text(
                    'Al-Quran',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Surah',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18.sp,
                    ),
                  ),
                  10.height,
                  Container(
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => controller.filterSurah(value),
                      style: GoogleFonts.poppins(fontSize: 16.sp),
                      decoration: InputDecoration(
                        hintText: "Search by Name, Meaning or Number...",
                        prefixIcon: const Icon(Icons.search, color: AppColor.primary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    final lastRead = HiveHelper().getLastRead();

    return Column(
      children: [
        if (lastRead['surah'] != null && controller.allSurahs.isNotEmpty)
          _buildLastReadCard(lastRead),
        Expanded(
          child: Obx(
            () => controller.filteredSurahs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(15.w),
                    itemCount: controller.filteredSurahs.length,
                    itemBuilder: (context, index) {
                      return _buildSurahItem(controller.filteredSurahs[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastReadCard(Map<String, int?> lastRead) {
    try {
      final surah = controller.allSurahs.firstWhere(
        (s) => s.number == lastRead['surah'],
      );
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.menu_book, color: Colors.white, size: 30),
            15.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Last Read", style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                Text("${surah.nameEnglish} : Ayah ${lastRead['ayah']}", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SurahDetailScreen(surah: surah))),
              child: const Text("Continue"),
            )
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No Surah Found"));
  }

  Widget _buildSurahItem(Surah surah) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SurahDetailScreen(surah: surah))),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                height: 60.h, width: 60.h,
                decoration: BoxDecoration(color: AppColor.primary.withOpacity(0.1), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(surah.number.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              20.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(surah.nameEnglish, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    Text("${surah.revelationType} • ${surah.numberOfAyahs} Verses"),
                    Text(surah.nameBangla, style: TextStyle(color: AppColor.primary, fontSize: 16.sp)),
                  ],
                ),
              ),
              Text(surah.nameArabic, style: GoogleFonts.amiri(fontSize: 28.sp, color: AppColor.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
