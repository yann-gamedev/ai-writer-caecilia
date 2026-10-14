import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/placeholder/presentation/placeholder_page.dart';

class CaeciliaApp extends StatelessWidget {
  const CaeciliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caecilia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const PlaceholderPage(),
    );
  }
}
