import 'package:amarislam/core/constant/app_image.dart';
import 'package:flutter/material.dart';
import 'HomeController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Amar Islam",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(),
            _buildNextPrayerCard(),
            _buildPrayerListHeader(),
            _buildHorizontalPrayerList(),
            const SizedBox(height: 5),
            _buildQuickAccessListHeader(),
            const SizedBox(height: 5),
            _buildQuickAccessCategoryList()
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
            "Assalamu Alaikum, ${controller.userName.value}",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          )),
          const SizedBox(height: 4),
          Obx(() => Text(
            controller.currentDate.value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  AppImage.mosjid,
                  width: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Next Prayer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    controller.nextPrayerName.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Obx(() {
                        final time = controller.nextPrayerTime.value;
                        return Text(
                          time != null ? DateFormat('hh:mm a').format(time) : '--:--',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Obx(() => Text(
                      "Remaining: ${controller.countdown.value}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerListHeader() {
    return const Padding(
      padding: EdgeInsets.only(left: 22, top: 25, bottom: 15),
      child: Text(
        "Today's Schedule",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildQuickAccessListHeader() {
    return const Padding(
      padding: EdgeInsets.only(left: 22, top: 25, bottom: 15),
      child: Text(
        "Quick Access day's",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildHorizontalPrayerList() {
    return SizedBox(
      height: 140,
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          physics: const BouncingScrollPhysics(),
          itemCount: controller.prayerList.length,
          itemBuilder: (context, index) {
            final prayer = controller.prayerList[index];
            final bool isNext = controller.nextPrayerName.value == prayer.name;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 110,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isNext ? Colors.green.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isNext ? Colors.green.shade300 : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    prayer.name.split(' ')[0], // Extracts Bengali name if present
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isNext ? Colors.green.shade800 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prayer.name.contains('(') 
                        ? prayer.name.split('(')[1].replaceAll(')', '') 
                        : '',
                    style: TextStyle(
                      fontSize: 12,
                      color: isNext ? Colors.green.shade600 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    DateFormat('hh:mm').format(prayer.time),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isNext ? Colors.green.shade900 : Colors.black54,
                    ),
                  ),
                  Text(
                    DateFormat('a').format(prayer.time),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isNext ? Colors.green.shade700 : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }



  Widget _buildQuickAccessCategoryList() {
    return Obx(() {
      final categories = controller.categories;

      if (categories.isEmpty) {
        return const Center(
          child: Text('No categories available'),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ),
        itemCount: categories.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // controller.openCategory(category);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade100,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3EC),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      size: 28,
                      color: const Color(0xFF216747),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    category.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

}
