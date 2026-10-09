import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perasoft_staj/feature/creations/view_model/creation_history_cubit.dart';
import 'package:perasoft_staj/feature/creations/view/widget/creation_grid.dart';
import 'package:perasoft_staj/feature/creations/view/widget/history_persistence_notice.dart';
import 'package:perasoft_staj/feature/generation/view/generation_result_view.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/navigation/navigation_helper.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/feature/garage/data/garage_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/widget/mody_header.dart';

class GarageView extends StatefulWidget {
  const GarageView({super.key, this.showBottomBar = true});
  final bool showBottomBar;

  @override
  State<GarageView> createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateIndex(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _selectTab(int index) {
    _updateIndex(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreationHistoryCubit, CreationHistoryState>(
      builder: (context, history) => _build(context, history),
    );
  }

  Widget _build(BuildContext context, CreationHistoryState history) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12),
        child: Column(
          children: [
            const Padding(
              padding: PaddingItems.pageHorizontal,
              child: Row(
                children: [
                  Expanded(child: ModyHeader()),
                  SizedBox(width: SizeItems.smallSpace),
                  Icon(Icons.more_vert, color: ColorItems.primaryText),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _GarageProfile(
                            hasReal: history.records.any(
                              (r) => r.result is AiImageGenerationResult,
                            ),
                            images: history.images.length,
                            videos: history.videos.length,
                          ),
                          const HistoryPersistenceNotice(),
                          Padding(
                            padding: PaddingItems.pageHorizontal,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _GarageTab(
                                    title: GarageItems.all,
                                    icon: Icons.grid_view_rounded,
                                    isSelected: _selectedIndex == 0,
                                    onPressed: () => _selectTab(0),
                                  ),
                                ),
                                Expanded(
                                  child: _GarageTab(
                                    title: GarageItems.modys,
                                    icon: Icons.directions_car,
                                    isSelected: _selectedIndex == 1,
                                    onPressed: () => _selectTab(1),
                                  ),
                                ),
                                Expanded(
                                  child: _GarageTab(
                                    title: GarageItems.videos,
                                    icon: Icons.video_library_outlined,
                                    isSelected: _selectedIndex == 2,
                                    onPressed: () => _selectTab(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  body: PageView(
                    controller: _pageController,
                    onPageChanged: _updateIndex,
                    children: [
                      _historyPage(history.records, GarageItems.emptyImages),
                      _historyPage(history.images, GarageItems.emptyImages),
                      _historyPage(history.videos, GarageItems.emptyVideos),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.showBottomBar) const ModyBottomBar(selectedIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _historyPage(List<CreationRecord> records, String emptyMessage) =>
      CreationGrid(
        records: records,
        emptyMessage: emptyMessage,
        onSelected: (record) => openPage<void>(
          context,
          GenerationResultView(result: record.result, fromHistory: true),
        ),
      );
}

class _GarageProfile extends StatelessWidget {
  const _GarageProfile({
    required this.images,
    required this.videos,
    required this.hasReal,
  });
  final bool hasReal;
  final int images;
  final int videos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeItems.largeSpace),
      child: Column(
        children: [
          Container(
            key: const Key('garageAvatar'),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorItems.sampleColor,
              border: Border.all(color: ColorItems.primaryBlue, width: 2),
            ),
          ),
          const SizedBox(height: SizeItems.normalSpace),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  GarageItems.userName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: SizeItems.smallSpace),
              const Icon(Icons.edit, size: SizeItems.normalIcon),
            ],
          ),
          const SizedBox(height: SizeItems.normalSpace),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _ProfileCount(title: GarageItems.modys, count: images),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _ProfileCount(title: GarageItems.videos, count: videos),
              ),
            ],
          ),
          if (images + videos > 0)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                hasReal
                    ? 'AI görselleri ve demo kayıtları • Videolar demodur'
                    : 'Demo işlem sayıları • Gerçek görsel/video üretilmedi',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileCount extends StatelessWidget {
  const _ProfileCount({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          key: ValueKey('creation-count-$title'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: ColorItems.secondaryText),
        ),
      ],
    );
  }
}

class _GarageTab extends StatelessWidget {
  const _GarageTab({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? ColorItems.primaryText
        : ColorItems.secondaryText;
    return Column(
      children: [
        TextButton(
          key: Key('garageTab$title'),
          onPressed: onPressed,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: SizeItems.smallIcon),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
        Container(
          key: Key('garageUnderline$title'),
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? ColorItems.primaryText : Colors.transparent,
            borderRadius: BorderRadius.circular(SizeItems.smallRadius),
          ),
        ),
      ],
    );
  }
}
