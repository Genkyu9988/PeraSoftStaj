import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'package:perasoft_staj/product/widget/mock_options.dart';
import 'package:perasoft_staj/product/catalog/explore_items.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/widget/mody_header.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/navigation/navigation_helper.dart';
import 'package:perasoft_staj/feature/explore/view/widget/explore_option_grid.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({
    super.key,
    this.showBottomBar = true,
    this.initialSelections = const {},
    this.onApplied,
    this.generationService,
  });
  final bool showBottomBar;
  final GenerationService? generationService;
  final Map<String, ExploreSelection> initialSelections;
  final void Function(String title, ExploreSelection selection)? onApplied;

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  late final Map<String, ExploreSelection> _selections;
  bool _carModsExpanded = false;
  bool _aiEditsExpanded = false;

  @override
  void initState() {
    super.initState();
    _selections = Map.of(widget.initialSelections);
  }

  void _open(String title, {bool isCarMod = false}) {
    if (isCarMod &&
        title != 'Change Color' &&
        !CarModCatalog.groups.containsKey(title)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('$title seçim ekranı sonraki aşamada eklenecek.'),
          ),
        );
      return;
    }
    openPage<void>(
      context,
      ExploreDetailView(
        generationService: widget.generationService,
        title: title,
        coverImagePath: ImageItems.exploreCovers[title],
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
                    child: ExploreOptionGrid(
                      titles: ExploreItems.carMods,
                      images: ImageItems.exploreCovers,
                      expanded: _carModsExpanded,
                      initialCount: ExploreItems.initialGridCount,
                      expandLabel: ExploreItems.loadMoreLabel,
                      expandButtonKey: const Key('expandCarMods'),
                      onExpand: () => setState(() => _carModsExpanded = true),
                      onSelected: (title) => _open(title, isCarMod: true),
                    ),
                  ),
                  MockSection(
                    title: ExploreItems.styleBuilderTitle,
                    child: HorizontalMockOptions(
                      titles: ExploreItems.styleBuilder,
                      images: ImageItems.exploreCovers,
                      onSelected: _open,
                    ),
                  ),
                  MockSection(
                    title: ExploreItems.wallpaperMakerTitle,
                    child: HorizontalMockOptions(
                      titles: ExploreItems.wallpaperMaker,
                      images: ImageItems.exploreCovers,
                      onSelected: _open,
                    ),
                  ),
                  MockSection(
                    title: ExploreItems.aiEditsTitle,
                    child: ExploreOptionGrid(
                      titles: ExploreItems.aiEdits,
                      images: ImageItems.exploreCovers,
                      expanded: _aiEditsExpanded,
                      initialCount: ExploreItems.initialGridCount,
                      expandLabel: ExploreItems.loadMoreLabel,
                      expandButtonKey: const Key('expandAiEdits'),
                      onExpand: () => setState(() => _aiEditsExpanded = true),
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
