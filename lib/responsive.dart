import 'package:demo_vps/MobileLayouts/mobilemain.dart';
import 'package:demo_vps/DesktopLayout/desktopmain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Responsive extends StatelessWidget {
  const Responsive({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 767) {
          return ScreenUtilInit(
            designSize: Size(360, 800), //Galaxy S20 Dimensions
            builder:
                (context, child) => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: const MobileMain(),
                ),
          );
        } else {
          return ScreenUtilInit(
            designSize: Size(1366, 768), //My Laptop Dimension
            builder:
                (context, child) => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: const DesktopMain(),
                ),
          );
        }
      },
    );
  }
}
