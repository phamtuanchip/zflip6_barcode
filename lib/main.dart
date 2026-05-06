import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_theme.dart';
import 'core/utils/screen_utils.dart';
import 'providers/barcode_provider.dart';
import 'screens/cover_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => BarcodeProvider()..loadBarcodes(),
      child: const ZFlip6BarcodeApp(),
    ),
  );
}

/// Root application widget.
class ZFlip6BarcodeApp extends StatelessWidget {
  const ZFlip6BarcodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZFlip6 Barcode',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _AppEntryPoint(),
    );
  }
}

/// Decides whether to show the cover screen or the main home screen based
/// on the current [MediaQuery] dimensions.
class _AppEntryPoint extends StatelessWidget {
  const _AppEntryPoint();

  @override
  Widget build(BuildContext context) {
    return ScreenUtils.isCoverScreen(context)
        ? const CoverScreen()
        : const HomeScreen();
  }
}
