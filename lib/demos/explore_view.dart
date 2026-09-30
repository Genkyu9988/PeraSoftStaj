import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/mock_options.dart';
import 'package:perasoft_staj/product/explore_items.dart';
import 'package:perasoft_staj/product/layout_items.dart';
import 'package:perasoft_staj/product/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/mody_header.dart';
import 'package:perasoft_staj/demos/explore_detail_view.dart';
import 'package:perasoft_staj/product/explore_selection.dart';
import 'package:perasoft_staj/product/navigation_helper.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({
    super.key,
    this.showBottomBar = true,
    this.initialSelections = const {},
    this.onApplied,
  });
  final bool showBottomBar;
  final Map<String, ExploreSelection> initialSelections;
  final void Function(String title, ExploreSelection selection)? onApplied;

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  late final Map<String, ExploreSelection> _selections;

  @override
  void initState() {
    super.initState();
    _selections = Map.of(widget.initialSelections);
  }

  void _open(String title, {bool isCarMod = false}) {
    openPage<void>(
      context,
      ExploreDetailView(
        title: title,
        isCarMod: isCarMod,
        initialSelection: _selections[title] ?? const ExploreSelection(),
        onApplied: (selection) {
          _selections[title] = selection;
          widget.onApplied?.call(title, selection);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12),
        child: Column(
          children: [
            const Padding(
              padding: PaddingItems.pageHorizontal,
              child: ModyHeader(),
            ),
            const SizedBox(height: SizeItems.normalSpace),
            Expanded(
              child: ListView(
                key: const Key('exploreScroll'),
                padding: PaddingItems.pageHorizontal,
                children: [
                  MockSection(
                    title: ExploreItems.carModsTitle,
                    child: _FiveOptionGrid(
                      titles: ExploreItems.carMods,
                      onSelected: (title) => _open(title, isCarMod: true),
                    ),
                  ),
                  MockSection(
                    title: ExploreItems.styleBuilderTitle,
                    child: HorizontalMockOptions(
                      titles: ExploreItems.styleBuilder,
                      onSelected: _open,
                    ),
                  ),
                  MockSection(
                    title: ExploreItems.wallpaperMakerTitle,
                    child: HorizontalMockOptions(
                      titles: ExploreItems.wallpaperMaker,
                      onSelected: _open,
                    ),
                  ),
                  MockSection(
                    title: ExploreItems.aiEditsTitle,
                    child: _FiveOptionGrid(
                      titles: ExploreItems.aiEdits,
                      onSelected: _open,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showBottomBar) const ModyBottomBar(selectedIndex: 1),
          ],
        ),
      ),
    );
  }
}

// Bu aşamada her bölüm tam beş mock seçenek içerir.
class _FiveOptionGrid extends StatelessWidget {
  const _FiveOptionGrid({required this.titles, required this.onSelected});

  final List<String> titles;
  final ValueChanged<String> onSelected;

  Widget _card(int index) => Expanded(
    child: MockOptionCard(
      title: titles[index],
      onPressed: () => onSelected(titles[index]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _card(0),
            const SizedBox(width: SizeItems.smallSpace),
            _card(1),
            const SizedBox(width: SizeItems.smallSpace),
            _card(2),
          ],
        ),
        const SizedBox(height: SizeItems.smallSpace),
        Row(
          children: [
            _card(3),
            const SizedBox(width: SizeItems.smallSpace),
            _card(4),
            const SizedBox(width: SizeItems.smallSpace),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}
