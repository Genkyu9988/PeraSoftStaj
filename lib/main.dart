import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perasoft_staj/feature/creations/view_model/creation_history_cubit.dart';
import 'package:perasoft_staj/product/cache/creation_cache_manager.dart';
import 'package:perasoft_staj/product/cache/creation_repository.dart';
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
      historyRepository: CreationCacheManager(SharedManager()),
      home: SelectionLoader(
        manager: SelectionCacheManager(SharedManager()),
        initialTab: initialTab,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.home = const MainTabsView(),
    this.historyRepository,
  });

  final Widget home;
  final CreationRepository? historyRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreationHistoryCubit(
        repository: historyRepository ?? MemoryCreationRepository(),
      )..load(),
      lazy: false,
      child: MaterialApp(
        title: 'Mody AI',
        debugShowCheckedModeBanner: false,
        theme: ModyTheme.dark(),
        home: home,
      ),
    );
  }
}
