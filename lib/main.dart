import 'package:flutter/material.dart';
import 'package:perasoft_staj/feature/shell/view/main_tabs_view.dart';
import 'package:perasoft_staj/product/init/theme/mody_theme.dart';
import 'package:perasoft_staj/product/init/selection_loader.dart';
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
    return MaterialApp(
      title: 'Mody AI',
      debugShowCheckedModeBanner: false,
      theme: ModyTheme.dark(),
      home: home,
    );
  }
}
