import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodel/QiblaController.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  final QiblaController controller = Get.put(QiblaController());
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        title: const Text(
          "Qibla Finder",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
        }

        if (controller.locationError.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_rounded, size: 80, color: Colors.redAccent),
                  const SizedBox(height: 20),
                  Text(
                    controller.locationError.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => controller.checkPermissionsAndFetchLocation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Retry", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade50,
                Colors.white,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildInfoCards(),
                const Spacer(),
                _buildCompassView(),
                const Spacer(),
                _buildLocationDetailCard(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildInfoItem(
            icon: Icons.explore_rounded,
            label: "Qibla Angle",
            value: "${controller.qiblaAngle.value.toStringAsFixed(1)}°",
            color: Colors.blue,
          ),
          const SizedBox(width: 15),
          _buildInfoItem(
            icon: Icons.straighten_rounded,
            label: "Distance",
            value: "${controller.distanceToKaaba.value.toStringAsFixed(0)} KM",
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassView() {
    double? heading = controller.direction.value;
    if (heading == null) return const SizedBox();

    double qiblaDirection = controller.qiblaAngle.value;
    // Calculate rotation: (Heading - Qibla) or vice-versa depending on how you want to rotate
    // Usually we rotate the compass disc based on heading, and the needle points to Qibla relative to the disc.
    // Or rotate a single container.
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        
        // Compass Scale / Background
        Transform.rotate(
          angle: (heading * (pi / 180) * -1),
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: Stack(
              children: List.generate(72, (index) {
                return Transform.rotate(
                  angle: (index * 5) * (pi / 180),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: index % 2 == 0 ? 15 : 8,
                      width: 2,
                      color: index % 18 == 0 ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // Cardinal directions (Static or rotating? usually static relative to user, but here disc rotates)
         Transform.rotate(
          angle: (heading * (pi / 180) * -1),
           child: const SizedBox(
             width: 220,
             height: 220,
             child: Stack(
               children: [
                 Align(alignment: Alignment.topCenter, child: Text("N", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                 Align(alignment: Alignment.bottomCenter, child: Text("S", style: TextStyle(fontWeight: FontWeight.bold))),
                 Align(alignment: Alignment.centerLeft, child: Text("W", style: TextStyle(fontWeight: FontWeight.bold))),
                 Align(alignment: Alignment.centerRight, child: Text("E", style: TextStyle(fontWeight: FontWeight.bold))),
               ],
             ),
           ),
         ),

        // Qibla Needle
        Transform.rotate(
          angle: ((qiblaDirection - heading) * (pi / 180)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_rounded, size: 50, color: Color(0xFF2E7D32)),
              Container(
                height: 120,
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF2E7D32), Colors.green.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 60), // Offset to center the needle properly
            ],
          ),
        ),

        // Center hub
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2E7D32), width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDetailCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.my_location_rounded, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Current Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      "Lat: ${controller.currentPosition.value?.latitude.toStringAsFixed(4)}, Lng: ${controller.currentPosition.value?.longitude.toStringAsFixed(4)}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _HelperItem(icon: Icons.vibration, text: "Level device"),
               _HelperItem(icon: Icons.wifi_tethering_rounded, text: "Calibrate"),
               _HelperItem(icon: Icons.info_outline_rounded, text: "Accuracy"),
            ],
          )
        ],
      ),
    );
  }
}

class _HelperItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HelperItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 5),
        Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
