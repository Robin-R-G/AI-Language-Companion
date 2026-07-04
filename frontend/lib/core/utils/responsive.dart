import 'package:flutter/material.dart';

/// Responsive layout breakpoints and helpers.
/// Based on the design system specification:
/// - Small Phones (0–399dp): 4 columns, 16dp margins
/// - Large Phones & Tablets (400–1023dp): 8 columns, 32dp margins
/// - Foldables / Desktop (1024dp+): 12 columns
class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 400;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 12;
    if (isTablet(context)) return 8;
    return 4;
  }

  static double horizontalMargin(BuildContext context) {
    if (isDesktop(context)) return 48;
    if (isTablet(context)) return 32;
    return 16;
  }

  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 800;
    return double.infinity;
  }

  static EdgeInsets screenPadding(BuildContext context) {
    final margin = horizontalMargin(context);
    return EdgeInsets.symmetric(horizontal: margin);
  }
}

/// Responsive builder widget that provides layout information.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveLayout layout) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final layout = ResponsiveLayout(
      isMobile: width < Responsive.mobileBreakpoint,
      isTablet:
          width >= Responsive.mobileBreakpoint &&
          width < Responsive.tabletBreakpoint,
      isDesktop: width >= Responsive.tabletBreakpoint,
      columns: Responsive.gridColumns(context),
      margin: Responsive.horizontalMargin(context),
      maxWidth: Responsive.contentMaxWidth(context),
    );
    return builder(context, layout);
  }
}

/// Data class for responsive layout information.
class ResponsiveLayout {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final int columns;
  final double margin;
  final double maxWidth;

  const ResponsiveLayout({
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.columns,
    required this.margin,
    required this.maxWidth,
  });
}
