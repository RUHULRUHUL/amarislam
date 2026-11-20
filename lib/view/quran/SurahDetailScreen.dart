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
      body: Stack(
        children: [
          Obx(() => CustomScrollView(
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
                    SliverPadding(
                      padding: EdgeInsets.only(bottom: 100.h),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildAyahItem(controller.ayahs[index], index),
                          childCount: controller.ayahs.length,
                        ),
                      ),
                    ),
                ],
              )),
          _buildBottomPlayer(),
        ],
      ),
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
    final bool isBookmarked = controller.isBookmarked(widget.surah.number, ayah.numberInSurah);

    return Obx(() {
      final bool isCurrentAyah = controller.playingAyahIndex.value == index;
      final bool isActuallyPlaying = isCurrentAyah && controller.isPlaying.value;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: isCurrentAyah ? AppColor.primary.withOpacity(0.05) : Colors.transparent,
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
    });
  }

  Widget _buildBottomPlayer() {
    return Obx(() {
      if (controller.playingAyahIndex.value == null) return const SizedBox.shrink();

      final ayah = controller.ayahs[controller.playingAyahIndex.value!];

      return Positioned(
        bottom: 20.h,
        left: 20.w,
        right: 20.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              MusicVisualizer(isPlaying: controller.isPlaying.value),
              15.width,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Playing Ayah ${ayah.numberInSurah}",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      widget.surah.nameEnglish,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => controller.togglePlayPause(),
                icon: Icon(
                  controller.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 35.r,
                ),
              ),
              IconButton(
                onPressed: () => controller.stopAudio(),
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class MusicVisualizer extends StatelessWidget {
  final bool isPlaying;
  const MusicVisualizer({Key? key, required this.isPlaying}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25.w,
      height: 20.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
            3, (index) => VisualizerBar(index: index, isPlaying: isPlaying)),
      ),
    );
  }
}

class VisualizerBar extends StatefulWidget {
  final int index;
  final bool isPlaying;
  const VisualizerBar({Key? key, required this.index, required this.isPlaying})
      : super(key: key);

  @override
  State<VisualizerBar> createState() => _VisualizerBarState();
}

class _VisualizerBarState extends State<VisualizerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 400 + (widget.index * 150)),
        vsync: this);
    _animation = Tween<double>(begin: 2, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VisualizerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 3.w,
          height: widget.isPlaying ? _animation.value.h : 5.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      },
    );
  }
}
