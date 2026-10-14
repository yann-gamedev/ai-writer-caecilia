import 'package:caecilia/app.dart';
import 'package:caecilia/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Menampilkan halaman placeholder dengan tema Material 3', (
    tester,
  ) async {
    await tester.pumpWidget(const CaeciliaApp());

    expect(find.text('Caecilia'), findsOneWidget);
    expect(find.text('Aplikasi sedang disiapkan.'), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, AppTheme.light);
    expect(app.theme!.useMaterial3, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Placeholder aman pada layar kecil dan teks besar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const CaeciliaApp());

    expect(find.text('Aplikasi sedang disiapkan.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
