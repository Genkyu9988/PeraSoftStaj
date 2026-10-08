import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';

void main() {
  test('Angles contain exactly the user-confirmed categories in order', () {
    const expected = {
      'Front': ['Front Bumper', 'Hood', 'Headlights'],
      'Rear': ['Spoiler', 'Exhaust', 'Rear Bumper & Diffuser', 'Tail Lights'],
      'Side': [
        'Spoiler',
        'Rims/Wheels',
        'Exhaust',
        'Front Bumper',
        'Rear Bumper & Diffuser',
        'Hood',
        'Side Skirts',
      ],
    };
    expect(DetailPartCatalog.byAngle.keys, expected.keys);
    for (final entry in expected.entries) {
      expect(
        DetailPartCatalog.forAngle(entry.key).map((c) => c.title),
        entry.value,
      );
    }
    expect(DetailPartCatalog.forAngle(''), isEmpty);
    expect(DetailPartCatalog.forAngle('unknown'), isEmpty);
    expect(DetailPartCatalog.all.map((c) => c.title).toSet(), hasLength(9));
    for (final category in DetailPartCatalog.all) {
      expect(category.images.toSet(), hasLength(3));
    }
    expect(
      identical(
        DetailPartCatalog.forAngle('Front')[1],
        DetailPartCatalog.forAngle('Side')[5],
      ),
      isTrue,
    );
  });

  for (final angle in DetailPartCatalog.byAngle.keys) {
    test(
      '$angle restores all its parts and drops foreign or invalid values',
      () {
        final categories = DetailPartCatalog.forAngle(angle);
        final allParts = {for (final c in DetailPartCatalog.all) c.title: 2};
        final restored = GenerateSelection.fromJson({
          'angle': angle,
          'parts': allParts,
          'detailColor': 'Premium Mor',
        });
        expect(restored.parts, {for (final c in categories) c.title: 2});
        expect(restored.detailColor, 'Premium Mor');
        expect(restored.detailColorCategory, 1);
        for (final invalid in [-1, 3, 2.0, '1', true, null]) {
          expect(
            DetailPartCatalog.restoreSelections(angle, {
              categories.first.title: invalid,
            }),
            isEmpty,
          );
        }
        for (final invalid in [
          null,
          'bad',
          [1, 2],
        ]) {
          expect(DetailPartCatalog.restoreSelections(angle, invalid), isEmpty);
        }
        expect(
          DetailPartCatalog.restoreSelections(angle, {'deleted': 0}),
          isEmpty,
        );
      },
    );
  }

  test('Legacy keys/indices remain valid only for their selected angle', () {
    const legacyParts = {'Spoiler': 2, 'Exhaust': 1, 'Tail Lights': 0};
    expect(
      GenerateSelection.fromJson({'angle': 'Rear', 'parts': legacyParts}).parts,
      legacyParts,
    );
    expect(
      GenerateSelection.fromJson({'angle': 'Side', 'parts': legacyParts}).parts,
      {'Spoiler': 2, 'Exhaust': 1},
    );
    for (final angle in ['Front', '', 'deleted', 3]) {
      expect(
        GenerateSelection.fromJson({
          'angle': angle,
          'parts': legacyParts,
        }).parts,
        isEmpty,
      );
    }
  });
}
