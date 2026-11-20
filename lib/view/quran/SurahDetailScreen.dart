import 'package:amarislam/core/constant/app_color.dart';
import 'package:amarislam/core/constant/extentions.dart';
import 'package:amarislam/models/ayah_model.dart';
import 'package:amarislam/models/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final ScrollController _scrollController = ScrollController();
  Worker? _worker;
  final Map<int, double> _itemHeights = {};

  @override
  void initState() {
    super.initState();
    controller = Get.put(SurahDetailsController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAyahs(widget.surah.number);
    });

    _worker = ever(controller.playingAyahIndex, (int? index) {
      if (index != null && _scrollController.hasClients) {
        double targetOffset = 0;
        if (index == 0) {
          targetOffset = 0;
        } else {
          targetOffset = 250.h;
          for (int i = 0; i < index; i++) {
            targetOffset += _itemHeights[i] ?? 255.h;
          }
        }
        
        if (_scrollController.position.maxScrollExtent > 0) {
          targetOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
        }

        _scrollController.animateTo(
          targetOffset, 
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Obx(() => CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildAppBar(),
                  if (controller.isLoading.value && controller.ayahs.isEmpty)
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
                      padding: EdgeInsets.only(bottom: 120.h),
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
                  20.height,
                  ElevatedButton.icon(
                    onPressed: () => controller.playAyah(0, widget.surah.number),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColor.primary,
                      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text("PLAY SURAH", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
    return MeasureSize(
      onChange: (size) {
        _itemHeights[index] = size.height;
      },
      child: Obx(() {
        final int? playingIndex = controller.playingAyahIndex.value;
        final bool isCurrentAyah = playingIndex == index;
        final bool isBookmarked = controller.isBookmarked(widget.surah.number, ayah.numberInSurah);
        final bool isCurrentlyPlayingThis = isCurrentAyah && controller.isPlaying.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: isCurrentAyah ? AppColor.primary.withOpacity(0.15) : Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[100]!, width: 1),
              left: isCurrentAyah ? const BorderSide(color: AppColor.primary, width: 6) : BorderSide.none,
            ),
            boxShadow: isCurrentAyah ? [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: InkWell(
            onTap: () => controller.playAyah(index, widget.surah.number),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14.r,
                            backgroundColor: AppColor.primary,
                            child: Text(
                              ayah.numberInSurah.toString(),
                              style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isCurrentAyah) ...[
                            8.width,
                            MusicVisualizer(isPlaying: controller.isPlaying.value, color: AppColor.primary),
                          ]
                        ],
                      ),
                    ),
                    // Row(
                    //   children: [
                    //     _buildAyahAction(
                    //       icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    //       color: isBookmarked ? AppColor.primary : Colors.grey,
                    //       onTap: () => controller.toggleBookmark(widget.surah.number, widget.surah.nameEnglish, ayah.numberInSurah),
                    //     ),
                    //     _buildAyahAction(
                    //       icon: Icons.copy_rounded,
                    //       onTap: () => controller.copyAyah(ayah),
                    //     ),
                    //     _buildAyahAction(
                    //       icon: isCurrentlyPlayingThis ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                    //       color: isCurrentAyah ? AppColor.primary : Colors.grey,
                    //       onTap: () => controller.playAyah(index, widget.surah.number),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
                20.height,
                Text(
                  ayah.textArabic,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: isCurrentAyah ? AppColor.primary : AppColor.textBlack,
                    height: 1.8,
                  ),
                ),
                15.height,
                Text(
                  ayah.textBangla,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 17.sp,
                    color: AppColor.textBlack,
                    height: 1.5,
                  ),
                ),
                10.height,
                Text(
                  ayah.textEnglish,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAyahAction({required IconData icon, required VoidCallback onTap, Color? color}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color ?? Colors.grey[600], size: 22.r),
      constraints: const BoxConstraints(),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
    );
  }

  Widget _buildBottomPlayer() {
    return Obx(() {
      final int? playingIndex = controller.playingAyahIndex.value;
      if (playingIndex == null || controller.ayahs.isEmpty) return const SizedBox.shrink();

      final ayah = controller.ayahs[playingIndex];

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 0.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInBack,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 120.h * value),
            child: Opacity(
              opacity: (1.0 - value).clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.primary, AppColor.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<Duration>(
                stream: controller.audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = controller.audioPlayer.duration ?? Duration.zero;
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.2),
                        thumbColor: Colors.white,
                        valueIndicatorColor: AppColor.primary,
                      ),
                      child: Slider(
                        min: 0,
                        max: duration.inMilliseconds.toDouble() > 0 
                            ? duration.inMilliseconds.toDouble() 
                            : position.inMilliseconds.toDouble() + 1,
                        value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : position.inMilliseconds.toDouble() + 1),
                        onChanged: (value) {
                          controller.audioPlayer.seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 15.w, 15.h),
                child: Row(
                  children: [
                    Container(
                      height: 45.r,
                      width: 45.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: MusicVisualizer(isPlaying: controller.isPlaying.value),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ayah ${ayah.numberInSurah}",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.sp,
                            ),
                          ),
                          Text(
                            widget.surah.nameEnglish,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => controller.audioPlayer.seekToPrevious(),
                          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                          iconSize: 28.r,
                        ),
                        IconButton(
                          onPressed: () => controller.togglePlayPause(),
                          icon: Icon(
                            controller.isPlaying.value ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                            color: Colors.white,
                            size: 48.r,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          onPressed: () => controller.audioPlayer.seekToNext(),
                          icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                          iconSize: 28.r,
                        ),
                        8.width,
                        GestureDetector(
                          onTap: () => controller.stopAudio(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}

class MusicVisualizer extends StatelessWidget {
  final bool isPlaying;
  final Color color;
  const MusicVisualizer({Key? key, required this.isPlaying, this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30.w,
      height: 25.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
            5, (index) => VisualizerBar(index: index, isPlaying: isPlaying, color: color)),
      ),
    );
  }
}

class VisualizerBar extends StatefulWidget {
  final int index;
  final bool isPlaying;
  final Color color;
  const VisualizerBar({Key? key, required this.index, required this.isPlaying, required this.color})
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
    _animation = Tween<double>(begin: 2, end: 18).animate(
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
            color: widget.color,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      },
    );
  }
}
