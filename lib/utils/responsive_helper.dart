import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive font sizes
  static double fontSize(BuildContext context, double size) {
    if (isMobile(context)) {
      return size * 0.85;
    } else if (isTablet(context)) {
      return size * 0.95;
    }
    return size;
  }

  // Responsive padding
  static double padding(BuildContext context, double size) {
    if (isMobile(context)) {
      return size * 0.7;
    } else if (isTablet(context)) {
      return size * 0.85;
    }
    return size;
  }

  // Responsive spacing
  static double spacing(BuildContext context, double size) {
    if (isMobile(context)) {
      return size * 0.6;
    } else if (isTablet(context)) {
      return size * 0.8;
    }
    return size;
  }

  // Grid columns based on screen size
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    }
    return 3;
  }

  // Card width
  static double cardWidth(BuildContext context) {
    final width = getWidth(context);
    if (isMobile(context)) {
      return width - 32; // Full width with padding
    } else if (isTablet(context)) {
      return (width - 60) / 2; // 2 columns
    }
    return 230; // Fixed width for desktop
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return mobile;
        } else if (constraints.maxWidth < 1100) {
          return tablet ?? mobile;
        } else {
          return desktop;
        }
      },
    );
  }
}
