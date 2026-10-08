import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';

class GenerateIdeaButton extends StatelessWidget {
  const GenerateIdeaButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: const Key('suggestIdea'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: ColorItems.primaryBlue,
        foregroundColor: ColorItems.primaryText,
        minimumSize: const Size(48, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeItems.smallRadius),
        ),
      ),
      child: Text('Fikir Ver', style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
