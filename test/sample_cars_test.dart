import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/product/widget/sample_cars_area.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';

void main() {
  testWidgets('Shared samples scroll to all five photos and report stable ID', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: SampleCarsArea(onSelected: (index) => selected = index),
          ),
        ),
      ),
    );
    for (var index = 0; index < VehicleCatalog.samples.length; index++) {
      final target = find.byTooltip('Örnek Araç ${index + 1}');
      await tester.scrollUntilVisible(
        target,
        60,
        scrollable: find.byType(Scrollable),
      );
      final image = tester.widget<ModyAssetImage>(
        find.descendant(of: target, matching: find.byType(ModyAssetImage)),
      );
      expect(image.path, VehicleCatalog.samples[index].imagePath);
      await tester.tap(target);
      expect(selected, VehicleCatalog.samples[index].id);
    }
    expect(tester.takeException(), isNull);
  });
}
