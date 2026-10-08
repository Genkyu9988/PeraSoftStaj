import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';

class GenerateModeTabs extends StatelessWidget {
  const GenerateModeTabs({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeItems.tabHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _ModeTab(
              title: 'Style Builder',
              color: const Color(0xff00AEEF),
              isSelected: selectedIndex == 0,
              onPressed: () => onSelected(0),
            ),
          ),
          Expanded(
            child: _ModeTab(
              title: 'Custom Edit',
              color: const Color(0xff4B1FA5),
              isSelected: selectedIndex == 1,
              onPressed: () => onSelected(1),
            ),
          ),
          Expanded(
            child: _ModeTab(
              title: 'Detail Edit',
              color: const Color(0xffB63819),
              isSelected: selectedIndex == 2,
              onPressed: () => onSelected(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.title,
    required this.color,
    required this.isSelected,
    required this.onPressed,
  });

  final String title;
  final Color color;
  final bool isSelected;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeItems.tabHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? color : color.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: isSelected ? Border.all(color: ColorItems.primaryText) : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
