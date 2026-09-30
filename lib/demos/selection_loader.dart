import 'package:flutter/material.dart';
import 'package:perasoft_staj/demos/main_tabs_view.dart';
import 'package:perasoft_staj/product/cache/app_selections.dart';
import 'package:perasoft_staj/product/cache/selection_cache_manager.dart';

// Kayıt okunmadan ekranları açmayarak ilk seçimlerin üzerine yazılmasını önler.
class SelectionLoader extends StatefulWidget {
  const SelectionLoader({
    super.key,
    required this.manager,
    this.initialTab = MainTab.generate,
  });
  final SelectionCacheManager manager;
  final MainTab initialTab;

  @override
  State<SelectionLoader> createState() => _SelectionLoaderState();
}

class _SelectionLoaderState extends State<SelectionLoader> {
  AppSelections? _selections;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    AppSelections selections;
    var failed = false;
    try {
      selections = await widget.manager.load();
    } catch (_) {
      selections = AppSelections();
      failed = true;
    }
    if (!mounted) return;
    setState(() => _selections = selections);
    if (failed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kayıtlar okunamadı; varsayılan seçimlerle devam ediliyor.',
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selections == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return MainTabsView(
      initialTab: widget.initialTab,
      initialSelections: _selections,
      cacheManager: widget.manager,
    );
  }
}
