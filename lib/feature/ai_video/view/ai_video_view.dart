import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'package:perasoft_staj/product/catalog/ai_video_items.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/mock_options.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/widget/mody_header.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/navigation/navigation_helper.dart';

class AiVideoView extends StatefulWidget {
  const AiVideoView({
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
  State<AiVideoView> createState() => _AiVideoViewState();
}

class _AiVideoViewState extends State<AiVideoView> {
  late final Map<String, ExploreSelection> _selections;

  @override
  void initState() {
    super.initState();
    _selections = Map.of(widget.initialSelections);
  }

  void _open(String title) {
    openPage<void>(
      context,
      ExploreDetailView(
        title: title,
        coverImagePath: ImageItems.aiVideoCovers[title],
        isCarMod: false,
        isVideo: true,
        generationService: widget.generationService,
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
                key: const Key('aiVideoScroll'),
                padding: PaddingItems.pageHorizontal,
                children: [
                  MockSection(
                    title: AiVideoItems.transformationsTitle,
                    child: HorizontalMockOptions(
                      titles: AiVideoItems.transformations,
                      images: ImageItems.aiVideoCovers,
                      onSelected: _open,
                    ),
                  ),
                  MockSection(
                    title: AiVideoItems.driveScenesTitle,
                    child: HorizontalMockOptions(
                      titles: AiVideoItems.driveScenes,
                      images: ImageItems.aiVideoCovers,
                      onSelected: _open,
                    ),
                  ),
                  MockSection(
                    title: AiVideoItems.filtersTitle,
                    child: _VideoFilters(onSelected: _open),
                  ),
                ],
              ),
            ),
            if (widget.showBottomBar) const ModyBottomBar(selectedIndex: 2),
          ],
        ),
      ),
    );
  }
}

class _VideoFilters extends StatelessWidget {
  const _VideoFilters({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FilterRow(
          firstTitle: AiVideoItems.filters[0],
          onSelected: onSelected,
          secondTitle: AiVideoItems.filters[1],
        ),
        const SizedBox(height: SizeItems.smallSpace),
        _FilterRow(
          firstTitle: AiVideoItems.filters[2],
          onSelected: onSelected,
          secondTitle: AiVideoItems.filters[3],
        ),
        const SizedBox(height: SizeItems.smallSpace),
        _FilterRow(firstTitle: AiVideoItems.filters[4], onSelected: onSelected),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.firstTitle,
    this.secondTitle = '',
    required this.onSelected,
  });

  final ValueChanged<String> onSelected;

  final String firstTitle;
  final String secondTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MockOptionCard(
            title: firstTitle,
            imagePath: ImageItems.aiVideoCovers[firstTitle],
            onPressed: () => onSelected(firstTitle),
          ),
        ),
        const SizedBox(width: SizeItems.smallSpace),
        Expanded(
          child: secondTitle.isEmpty
              ? const SizedBox()
              : MockOptionCard(
                  title: secondTitle,
                  imagePath: ImageItems.aiVideoCovers[secondTitle],
                  onPressed: () => onSelected(secondTitle),
                ),
        ),
      ],
    );
  }
}
