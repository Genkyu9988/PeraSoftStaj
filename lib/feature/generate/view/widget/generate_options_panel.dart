import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/widget/selection_sheet.dart';

class GenerateOptionsPanel extends StatelessWidget {
  const GenerateOptionsPanel({
    super.key,
    required this.title,
    required this.options,
    required this.selectedTitle,
    required this.onSelected,
    this.images = const {},
    this.showApply = false,
    this.onApply,
  });

  final String title;
  final List<String> options;
  final String selectedTitle;
  final void Function(String) onSelected;
  final Map<String, String> images;
  final bool showApply;
  final VoidCallback? onApply;

  Widget _option(String name) {
    final selected = selectedTitle == name;
    return Expanded(
      child: Semantics(
        key: Key('option$name'),
        selected: selected,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? ColorItems.primaryBlue : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(SizeItems.normalRadius),
          ),
          child: TextButton(
            onPressed: () => onSelected(name),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: _SelectionOptionCard(title: name, imagePath: images[name]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OptionsPanelFrame(
      title: title,
      child: Expanded(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _option(options[0]),
                        const SizedBox(width: SizeItems.smallSpace),
                        _option(options[1]),
                        const SizedBox(width: SizeItems.smallSpace),
                        _option(options[2]),
                      ],
                    ),
                    if (options.length > 3) ...[
                      const SizedBox(height: SizeItems.smallSpace),
                      Row(
                        children: [
                          _option(options[3]),
                          const SizedBox(width: SizeItems.smallSpace),
                          _option(options[4]),
                          const SizedBox(width: SizeItems.smallSpace),
                          _option(options[5]),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (showApply)
              Padding(
                padding: const EdgeInsets.only(top: SizeItems.normalSpace),
                child: SizedBox(
                  width: double.infinity,
                  child: ModyActionButton(
                    onPressed: selectedTitle.isEmpty ? null : onApply,
                    title: 'Uygula',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectionOptionCard extends StatelessWidget {
  const _SelectionOptionCard({required this.title, this.imagePath});

  final String title;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 128,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ColorItems.sampleColor,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: Border.all(color: ColorItems.softBorder),
      ),
      child: imagePath != null
          ? Column(
              children: [
                Expanded(
                  child: ModyAssetImage(
                    path: imagePath!,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.directions_car_outlined,
                  color: ColorItems.secondaryText,
                  size: 36,
                ),
                const SizedBox(height: SizeItems.normalSpace),
                Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Mock',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ColorItems.secondaryText,
                  ),
                ),
              ],
            ),
    );
  }
}
