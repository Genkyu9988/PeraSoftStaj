import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';

class MockSection extends StatelessWidget {
  const MockSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _MockPadding.section,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: ColorItems.exploreSectionTitle,
                  ),
                ),
              ),
              const SizedBox(width: SizeItems.normalSpace),
              const SizedBox(
                width: 64,
                child: Divider(color: ColorItems.exploreSectionTitle),
              ),
            ],
          ),
          const SizedBox(height: SizeItems.normalSpace),
          child,
        ],
      ),
    );
  }
}

class HorizontalMockOptions extends StatelessWidget {
  const HorizontalMockOptions({
    super.key,
    required this.titles,
    this.onSelected,
    this.images = const {},
  });

  final List<String> titles;
  final Map<String, String> images;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _MockSizes.cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: SizeItems.smallSpace),
        itemBuilder: (context, index) => SizedBox(
          width: _MockSizes.horizontalCardWidth,
          child: MockOptionCard(
            title: titles[index],
            imagePath: images[titles[index]],
            onPressed: onSelected == null
                ? null
                : () => onSelected!(titles[index]),
          ),
        ),
      ),
    );
  }
}

class MockOptionCard extends StatelessWidget {
  const MockOptionCard({
    super.key,
    required this.title,
    this.onPressed,
    this.imagePath,
  });

  final String title;
  final String? imagePath;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(SizeItems.normalRadius),
      child: Container(
        height: _MockSizes.cardHeight,
        padding: imagePath == null
            ? _MockPadding.card
            : const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: ColorItems.cardBackground,
          borderRadius: BorderRadius.circular(SizeItems.normalRadius),
          border: Border.all(color: ColorItems.softBorder),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(SizeItems.normalRadius - 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: ModyAssetImage(path: imagePath!)),
                    SizedBox(
                      height: 42,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car_outlined,
                    color: ColorItems.secondaryText,
                    size: 36,
                  ),
                  const SizedBox(height: SizeItems.smallSpace),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mock',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ColorItems.secondaryText,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MockSizes {
  static const double cardHeight = 144;
  static const double horizontalCardWidth = 132;
}

class _MockPadding {
  static const card = EdgeInsets.all(SizeItems.smallSpace);
  static const section = EdgeInsets.only(bottom: SizeItems.largeSpace);
}
