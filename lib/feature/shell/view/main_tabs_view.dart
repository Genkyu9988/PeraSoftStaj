import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'package:perasoft_staj/product/cache/selection_cache_manager.dart';
import 'package:perasoft_staj/feature/ai_video/view/ai_video_view.dart';
import 'package:perasoft_staj/feature/explore/view/explore_view.dart';
import 'package:perasoft_staj/feature/garage/view/garage_view.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/utility/mody_feedback.dart';

enum MainTab { generate, explore, aiVideo, garage }

class MainTabsView extends StatefulWidget {
  const MainTabsView({
    super.key,
    this.initialTab = MainTab.generate,
    this.initialSelections,
    this.cacheManager,
  });
  final MainTab initialTab;
  final AppSelections? initialSelections;
  final SelectionCacheManager? cacheManager;

  @override
  State<MainTabsView> createState() => _MainTabsViewState();
}

class _MainTabsViewState extends State<MainTabsView>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  late final AppSelections _selections;
  late int _previousTabIndex;

  @override
  void initState() {
    super.initState();
    _selections = widget.initialSelections ?? AppSelections();
    _previousTabIndex = widget.initialTab.index;
    _controller = TabController(
      length: MainTab.values.length,
      initialIndex: widget.initialTab.index,
      vsync: this,
    );
    _controller.addListener(_updateTab);
  }

  void _updateTab() {
    if (_previousTabIndex == MainTab.generate.index &&
        _controller.index != _previousTabIndex) {
      ModyFeedback.dismiss(context);
    }
    _previousTabIndex = _controller.index;
    setState(() {});
  }

  Future<void> _saveSelections() async {
    final manager = widget.cacheManager;
    if (manager == null) return;
    final saved = await manager.save(_selections);
    if (!saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seçiminiz bu oturumda korundu ancak cihaza kaydedilemedi.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateTab);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _KeepTabAlive(
            child: ModyHomeView(
              showBottomBar: false,
              isActive: () => _controller.index == MainTab.generate.index,
              initialSelection: _selections.generate,
              onApplied: (selection) {
                _selections.generate = selection;
                _saveSelections();
              },
            ),
          ),
          _KeepTabAlive(
            child: ExploreView(
              showBottomBar: false,
              initialSelections: _selections.explore,
              onApplied: (title, selection) {
                _selections.explore[title] = selection;
                _saveSelections();
              },
            ),
          ),
          _KeepTabAlive(
            child: AiVideoView(
              showBottomBar: false,
              initialSelections: _selections.aiVideo,
              onApplied: (title, selection) {
                _selections.aiVideo[title] = selection;
                _saveSelections();
              },
            ),
          ),
          const _KeepTabAlive(child: GarageView(showBottomBar: false)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ModyBottomBar(
          selectedIndex: _controller.index,
          onSelected: _controller.animateTo,
        ),
      ),
    );
  }
}

// Sekme görünmez olduğunda da seçimleri ve kaydırma konumunu korur.
class _KeepTabAlive extends StatefulWidget {
  const _KeepTabAlive({required this.child});
  final Widget child;

  @override
  State<_KeepTabAlive> createState() => _KeepTabAliveState();
}

class _KeepTabAliveState extends State<_KeepTabAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
