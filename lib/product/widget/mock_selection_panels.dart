import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/mock_options.dart';
import 'package:perasoft_staj/product/widget/selection_sheet.dart';
import 'package:perasoft_staj/product/model/image_choice.dart';

class MockOptionsSelectionPanel extends StatelessWidget {
  const MockOptionsSelectionPanel({
    super.key,
    required this.title,
    required this.selected,
    required this.onSelected,
    required this.onApply,
    required this.options,
  });
  final String title;
  final List<ImageChoice> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onApply;
  @override
  Widget build(BuildContext context) {
    return OptionsPanelFrame(
      title: '$title seçin',
      child: Expanded(
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisExtent: 144,
                crossAxisSpacing: SizeItems.smallSpace,
                mainAxisSpacing: SizeItems.smallSpace,
                children: [
                  for (final option in options)
                    _choice(
                      option.id,
                      selected,
                      onSelected,
                      label: option.label,
                      imagePath: option.imagePath,
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ModyActionButton(
                onPressed: options.any((option) => option.id == selected)
                    ? onApply
                    : null,
                appearance: ModyButtonAppearance.themed,
                title: 'Uygula',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _choice(
  String name,
  String selected,
  ValueChanged<String> onSelected, {
  String? imagePath,
  String? label,
}) {
  return Semantics(
    key: ValueKey('choice$name'),
    selected: name == selected,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: Border.all(
          color: name == selected ? ColorItems.primaryBlue : Colors.transparent,
          width: 2,
        ),
      ),
      child: MockOptionCard(
        title: label ?? name,
        imagePath: imagePath,
        onPressed: () => onSelected(name),
      ),
    ),
  );
}
