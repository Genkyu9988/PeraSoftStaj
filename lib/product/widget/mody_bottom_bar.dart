import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';

class ModyBottomBar extends StatelessWidget {
  const ModyBottomBar({super.key, this.selectedIndex = 0, this.onSelected});

  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: SizeItems.bottomBarHeight),
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _BottomBarItem(
                title: 'Üret',
                onPressed: onSelected == null ? null : () => onSelected!(0),
                icon: Icons.generating_tokens_outlined,
                textColor: selectedIndex == 0
                    ? ColorItems.primaryText
                    : ColorItems.passiveText,
              ),
            ),
            Expanded(
              child: _BottomBarItem(
                title: 'Explore',
                onPressed: onSelected == null ? null : () => onSelected!(1),
                icon: Icons.layers_outlined,
                textColor: selectedIndex == 1
                    ? ColorItems.primaryText
                    : ColorItems.passiveText,
              ),
            ),
            Expanded(
              child: _BottomBarItem(
                title: 'AI Video',
                onPressed: onSelected == null ? null : () => onSelected!(2),
                icon: Icons.video_collection_outlined,
                textColor: selectedIndex == 2
                    ? ColorItems.primaryText
                    : ColorItems.passiveText,
                showBadge: true,
              ),
            ),
            Expanded(
              child: _BottomBarItem(
                title: 'Garaj',
                onPressed: onSelected == null ? null : () => onSelected!(3),
                icon: Icons.garage_outlined,
                textColor: selectedIndex == 3
                    ? ColorItems.primaryText
                    : ColorItems.passiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.title,
    required this.icon,
    required this.textColor,
    this.showBadge = false,
    this.onPressed,
  });

  final String title;
  final IconData icon;
  final Color textColor;
  final bool showBadge;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    color: textColor,
                    size: SizeItems.normalIcon,
                  ),
                ),
                if (showBadge)
                  const Positioned(top: 0, right: 0, child: _NewBadge()),
              ],
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: textColor, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: ColorItems.badge,
        borderRadius: BorderRadius.circular(SizeItems.smallRadius),
      ),
      child: Text(
        'Yeni',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: ColorItems.primaryText,
          fontSize: 8,
        ),
      ),
    );
  }
}
