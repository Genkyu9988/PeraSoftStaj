import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';

class GenerateOptionBoxes extends StatelessWidget {
  const GenerateOptionBoxes({
    super.key,
    required this.firstTitle,
    required this.secondTitle,
    required this.onSelected,
    this.firstSelection = '',
    this.secondSelection = '',
    this.colorSelection = '',
  });

  final String firstTitle;
  final String secondTitle;
  final String firstSelection;
  final String secondSelection;
  final String colorSelection;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 88),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _OptionBox(
                title: firstTitle,
                selection: firstSelection,
                icon: Icons.keyboard_arrow_down,
                onPressed: () => onSelected(1),
              ),
            ),
            const SizedBox(width: SizeItems.smallSpace),
            Expanded(
              child: _OptionBox(
                title: secondTitle,
                selection: secondSelection,
                icon: Icons.add,
                onPressed: () => onSelected(2),
              ),
            ),
            const SizedBox(width: SizeItems.smallSpace),
            Expanded(
              child: _OptionBox(
                title: 'Renk',
                selection: colorSelection,
                icon: Icons.keyboard_arrow_down,
                onPressed: () => onSelected(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionBox extends StatelessWidget {
  const _OptionBox({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.selection = '',
  });

  final String title;
  final String selection;
  final IconData icon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: ColorItems.cardBackground,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Icon(
                  icon,
                  color: ColorItems.primaryText,
                  size: SizeItems.smallIcon,
                ),
              ],
            ),
            if (selection.isNotEmpty) ...[
              const SizedBox(height: SizeItems.smallSpace),
              Text(
                selection,
                key: ValueKey('selection$title'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColorItems.secondaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
