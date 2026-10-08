import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';

// VB10's PngImage approach, with fit and dimensions supplied by the caller.
class ModyAssetImage extends StatelessWidget {
  const ModyAssetImage({
    super.key,
    required this.path,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Image.asset(
    path,
    fit: fit,
    width: width,
    height: height,
    semanticLabel: semanticLabel,
    excludeFromSemantics: semanticLabel == null,
    errorBuilder: (context, error, stackTrace) => SizedBox(
      width: width,
      height: height,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          semanticLabel: 'Görsel yüklenemedi',
          color: ColorItems.secondaryText,
        ),
      ),
    ),
  );
}
