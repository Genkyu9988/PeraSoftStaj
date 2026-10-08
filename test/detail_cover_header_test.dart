import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/editor/view/widget/detail_cover_header.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';

void main() {
  for (final width in [320.0, 390.0]) {
    testWidgets(
      'Cover overlays title and leaves back button usable at $width',
      (tester) async {
        var wentBack = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: width,
                child: DetailCoverHeader(
                  path: ImageItems.classic,
                  title: 'Customize Rims',
                  backLabel: 'Explore’a dön',
                  onBack: () => wentBack = true,
                ),
              ),
            ),
          ),
        );
        final cover = find.byKey(const Key('detailCover'));
        expect(tester.widget<ModyAssetImage>(cover).fit, BoxFit.cover);
        expect(
          tester
              .getRect(cover)
              .contains(tester.getCenter(find.text('Customize Rims'))),
          isTrue,
        );
        expect(
          find.descendant(
            of: find.byType(DetailCoverHeader),
            matching: find.byType(IgnorePointer),
          ),
          findsNWidgets(2),
        );
        await tester.tap(find.byTooltip('Explore’a dön'));
        expect(wentBack, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
