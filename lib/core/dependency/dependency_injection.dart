
import 'package:amarislam/view/HomeController.dart';
import 'package:amarislam/view/quran/QuranController.dart';
import 'package:get/get.dart';
class DependencyInjection extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=>HomeController());
    Get.lazyPut(()=>QuranController());
  }

}