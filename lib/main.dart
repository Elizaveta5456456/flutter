import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/product_cache.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProductCache.instance.preload();
  runApp(const LotusApp());
}

class LotusApp extends StatelessWidget {
  const LotusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lotus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
