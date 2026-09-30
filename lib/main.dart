import 'package:flutter/material.dart';
import 'package:perasoft_staj/demos/main_tabs_view.dart';
import 'package:perasoft_staj/product/color_items.dart';
import 'package:perasoft_staj/demos/selection_loader.dart';
import 'package:perasoft_staj/product/cache/selection_cache_manager.dart';
import 'package:perasoft_staj/product/cache/shared_manager.dart';

void main() {
  runModyApp();
}

void runModyApp({MainTab initialTab = MainTab.generate}) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyApp(
      home: SelectionLoader(
        manager: SelectionCacheManager(SharedManager()),
        initialTab: initialTab,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home = const MainTabsView()});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData.dark();
    final textTheme = darkTheme.textTheme.apply(
      bodyColor: ColorItems.primaryText,
      displayColor: ColorItems.primaryText,
    );

    return MaterialApp(
      title: 'Mody AI',
      debugShowCheckedModeBanner: false,
      theme: darkTheme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: textTheme.copyWith(
          titleLarge: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          titleMedium: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          labelLarge: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: home,
    );
  }
}
