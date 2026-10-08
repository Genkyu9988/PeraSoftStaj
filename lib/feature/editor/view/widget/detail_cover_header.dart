import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';

class DetailCoverHeader extends StatelessWidget {
  const DetailCoverHeader({
    super.key,
    required this.path,
    required this.title,
    required this.backLabel,
    required this.onBack,
  });

  final String path;
  final String title;
  final String backLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SizedBox(
      height: (constraints.maxWidth * .9).clamp(240.0, 360.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ModyAssetImage(
            key: const Key('detailCover'),
            path: path,
            fit: BoxFit.cover,
            semanticLabel: '$title önizlemesi',
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black,
                  ],
                  stops: [0, .12, .88, 1],
                ),
              ),
            ),
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black38,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black87,
                    Colors.black,
                  ],
                  stops: [0, .15, .48, .88, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 8,
            child: IconButton(
              tooltip: backLabel,
              onPressed: onBack,
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Positioned(
            left: 4,
            right: 4,
            bottom: 22,
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
        ],
      ),
    ),
  );
}
