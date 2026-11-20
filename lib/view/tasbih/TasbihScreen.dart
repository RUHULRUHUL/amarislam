import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodel/TasbihController.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TasbihController controller = Get.put(TasbihController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Digital Tasbih",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black),
            onPressed: () => _showResetDialog(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildTargetSelector(controller),
          const Spacer(),
          _buildCounterDisplay(controller),
          const Spacer(),
          _buildTapArea(controller),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildTargetSelector(TasbihController controller) {
    final targets = [33, 99, 100, 1000];
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: targets.map((target) {
        bool isSelected = controller.targetCount.value == target;
        return GestureDetector(
          onTap: () => controller.setTarget(target),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
              boxShadow: isSelected ? [
                BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
              ] : [],
            ),
            child: Text(
              target.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildCounterDisplay(TasbihController controller) {
    return Column(
      children: [
        Obx(() => Text(
          "Lap: ${controller.lapCount.value}",
          style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        )),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Obx(() => Text(
            controller.count.value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
              letterSpacing: 4,
            ),
          )),
        ),
        const SizedBox(height: 10),
        Obx(() => Text(
          "Target: ${controller.targetCount.value}",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
        )),
      ],
    );
  }

  Widget _buildTapArea(TasbihController controller) {
    return GestureDetector(
      onTap: () => controller.increment(),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded, color: Colors.white, size: 50),
              SizedBox(height: 10),
              Text(
                "TAP",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, TasbihController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Reset Counter?"),
        content: const Text("Are you sure you want to reset your tasbih count?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.reset();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Reset", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
