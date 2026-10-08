import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/widget/selection_sheet.dart';

// One parameterized sheet for every angle; the caller owns the draft/state.
class DetailAdjustmentPanel extends StatelessWidget {
  const DetailAdjustmentPanel({
    super.key,
    required this.categories,
    required this.selections,
    required this.onSelected,
    required this.onApply,
  });

  final List<DetailPartCategory> categories;
  final Map<String, int> selections;
  final void Function(String, int) onSelected;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) => OptionsPanelFrame(
    title: 'Yapılandırma seçin',
    child: Expanded(
      child: Column(
        children: [
          Expanded(
            child: categories.isEmpty
                ? const Center(
                    child: Text('Parça seçenekleri için önce bir açı seçin.'),
                  )
                : ListView.builder(
                    key: const Key('detailPartCategories'),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Padding(
                        key: ValueKey('partCategory${category.title}'),
                        padding: const EdgeInsets.only(
                          bottom: SizeItems.normalSpace,
                        ),
                        child: _PartSection(
                          category: category,
                          selectedIndex: selections[category.title],
                          onSelected: (index) =>
                              onSelected(category.title, index),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(
            width: double.infinity,
            child: ModyActionButton(
              onPressed: selections.isEmpty ? null : onApply,
              title: 'Uygula',
            ),
          ),
        ],
      ),
    ),
  );
}

class _PartSection extends StatelessWidget {
  const _PartSection({
    required this.category,
    required this.selectedIndex,
    required this.onSelected,
  });

  final DetailPartCategory category;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(category.title, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 4),
      SizedBox(
        height: _PartSizes.cardHeight,
        child: ListView.separated(
          key: ValueKey('partOptions${category.title}'),
          scrollDirection: Axis.horizontal,
          itemCount: category.images.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: SizeItems.smallSpace),
          itemBuilder: (context, index) => SizedBox(
            width: _PartSizes.cardWidth,
            child: Semantics(
              key: ValueKey('part${category.title}$index'),
              label: category.title,
              selected: selectedIndex == index,
              child: _PartCard(
                title: 'Seçenek ${index + 1}',
                imagePath: category.images[index],
                selected: selectedIndex == index,
                onPressed: () => onSelected(index),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _PartCard extends StatelessWidget {
  const _PartCard({
    required this.title,
    required this.imagePath,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final String imagePath;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(SizeItems.smallRadius),
      border: Border.all(
        color: selected ? ColorItems.primaryBlue : ColorItems.softBorder,
      ),
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SizeItems.smallRadius),
                child: ModyAssetImage(path: imagePath, width: double.infinity),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(title, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    ),
  );
}

class _PartSizes {
  static const double cardHeight = 112;
  static const double cardWidth = 128;
}
