// test/helpers/golden_test_helper.dart
import 'package:flutter/material.dart';

/// Helper to wrap a widget inside standard Material setups for Golden Tests.
Widget createGoldenWrapper(
  Widget child, {
  bool isDark = false,
  Size size = const Size(375, 812), // Standard iPhone screen bounds
}) {
  return SizedBox(
    width: size.width,
    height: size.height,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: Scaffold(
        body: child,
      ),
    ),
  );
}
