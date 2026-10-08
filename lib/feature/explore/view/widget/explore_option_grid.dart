import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/mock_options.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';

/// Presentation only: the parent owns expansion and navigation.
class ExploreOptionGrid extends StatelessWidget {
  const ExploreOptionGrid({
    super.key,
    required this.titles,
    required this.images,
    required this.expanded,
    required this.initialCount,
    required this.onExpand,
    required this.onSelected,
    required this.expandButtonKey,
    required this.expandLabel,
  });

  final List<String> titles;
  final Map<String, String> images;
  final bool expanded;
  final int initialCount;
  final VoidCallback onExpand;
  final ValueChanged<String> onSelected;
  final Key expandButtonKey;
  final String expandLabel;

  @override
  Widget build(BuildContext context) {
    final visible = expanded ? titles : titles.take(initialCount).toList();
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 144,
            mainAxisSpacing: SizeItems.smallSpace,
            crossAxisSpacing: SizeItems.smallSpace,
          ),
          itemCount: visible.length,
          itemBuilder: (context, index) {
            final title = visible[index];
            return MockOptionCard(
              key: ValueKey('exploreCard:$title'),
              title: title,
              imagePath: images[title],
              onPressed: () => onSelected(title),
            );
          },
        ),
        if (!expanded && titles.length > initialCount) ...[
          const SizedBox(height: SizeItems.normalSpace),
          ModyActionButton(
            key: expandButtonKey,
            title: expandLabel,
            appearance: ModyButtonAppearance.themed,
            onPressed: onExpand,
          ),
        ],
      ],
    );
  }
}
