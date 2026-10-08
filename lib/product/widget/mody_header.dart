import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';

class ModyHeader extends StatelessWidget {
  const ModyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: Colors.white70, size: 32),
          const SizedBox(width: SizeItems.smallSpace),
          Expanded(
            child: Text(
              'Mody AI',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const _ProArea(),
        ],
      ),
    );
  }
}

class _ProArea extends StatelessWidget {
  const _ProArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: Border.all(color: ColorItems.softBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flag,
            color: ColorItems.primaryText,
            size: SizeItems.smallIcon,
          ),
          const SizedBox(width: SizeItems.smallSpace),
          Text('PRO', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
