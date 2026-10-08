import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';

// Presentation only: the parent owns selection, sheet results and persistence.
class SelectionImageBox extends StatelessWidget {
  const SelectionImageBox({
    super.key,
    required this.imagePath,
    required this.emptyChild,
    required this.inputKey,
    required this.imageKey,
    required this.semanticLabel,
    required this.clearLabel,
    required this.onSelect,
    required this.onClear,
    this.height = 160,
    this.footer,
  });

  final String? imagePath;
  final Widget emptyChild;
  final Key inputKey;
  final Key imageKey;
  final String semanticLabel;
  final String clearLabel;
  final VoidCallback onSelect;
  final VoidCallback onClear;
  final double height;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: ColorItems.cardBackground,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeItems.normalRadius),
          side: BorderSide(
            color: imagePath == null
                ? ColorItems.softBorder
                : ColorItems.primaryBlue,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            InkWell(
              key: inputKey,
              onTap: onSelect,
              child: imagePath == null
                  ? emptyChild
                  : ModyAssetImage(
                      key: imageKey,
                      path: imagePath!,
                      semanticLabel: semanticLabel,
                    ),
            ),
            if (imagePath != null)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filled(
                  tooltip: clearLabel,
                  onPressed: onClear,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close),
                ),
              ),
            if (footer case final child?)
              Positioned(right: 8, bottom: 8, child: child),
          ],
        ),
      ),
    );
  }
}
