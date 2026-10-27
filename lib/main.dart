import 'package:amarislam/core/dependency/dependency_injection.dart';
import 'package:amarislam/core/helper/hive_helper.dart';
import 'package:amarislam/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HiveHelper().init();
  DependencyInjection().dependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ScreenUtilInit(
        designSize: const Size(640, 960),
        minTextAdapt: true,
        builder: (context, child) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Amar Islam',
          theme: ThemeData(
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
          initialRoute: Routes.splashScreen,
          getPages: Routes.pages,
        ),
      ),
    );
  }
}
