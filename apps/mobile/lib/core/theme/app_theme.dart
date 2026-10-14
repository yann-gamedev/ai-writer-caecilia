import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const pagePadding = EdgeInsets.all(24);

  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
  );
}
