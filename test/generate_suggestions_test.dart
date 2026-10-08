import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/catalog/generate_option_catalog.dart';
import 'package:perasoft_staj/feature/generate/logic/generate_suggestions.dart';
import 'package:perasoft_staj/product/validation/generate_validator.dart';
import 'package:perasoft_staj/feature/generate/data/modification_prompts.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';

import 'helpers/sequence_random.dart';

void expectRoundTrip(GenerateSelection selection) {
  expect(
    GenerateSelection.fromJson(selection.toJson()).toJson(),
    selection.toJson(),
  );
}

void main() {
  for (var i = 0; i < VehicleCatalog.all.length; i++) {
    test('Vehicle suggestion reaches catalog entry $i, not only samples', () {
      final random = SequenceRandom([i]);
      expect(
        GenerateSuggestions(random: random).vehicle(),
        same(VehicleCatalog.all[i]),
      );
      expect(random.bounds, [VehicleCatalog.all.length]);
      expect(random.exhausted, isTrue);
    });
  }

  for (var i = 0; i < GenerateOptionCatalog.colors.length; i++) {
    test('Style suggestion $i uses valid choices and survives restoration', () {
      final vehicleIndex = i % VehicleCatalog.all.length;
      final styleIndex = i % GenerateOptionCatalog.styles.length;
      final extraIndex = i % GenerateOptionCatalog.extras.length;
      final random = SequenceRandom([vehicleIndex, styleIndex, extraIndex, i]);
      final idea = GenerateSuggestions(random: random).styleBuilder();
      expect(idea.vehicleId, VehicleCatalog.all[vehicleIndex].id);
      expect(idea.style, GenerateOptionCatalog.styles[styleIndex]);
      expect(idea.extra, GenerateOptionCatalog.extras[extraIndex]);
      expect(idea.color, GenerateOptionCatalog.colors[i]);
      expect(random.exhausted, isTrue);
      expectRoundTrip(
        GenerateSelection(
          vehicleId: idea.vehicleId,
          style: idea.style,
          extra: idea.extra,
          color: idea.color,
          colorCategory: colorCategoryOf(idea.color),
        ),
      );
      expect(
        const GenerateValidator().styleBuilder(
          vehicleId: idea.vehicleId,
          style: idea.style,
          extra: idea.extra,
          color: idea.color,
        ),
        isNull,
      );
    });
  }

  final angles = DetailPartCatalog.byAngle.keys.toList();
  for (var a = 0; a < angles.length; a++) {
    final categories = DetailPartCatalog.forAngle(angles[a]);
    for (var c = 0; c < categories.length; c++) {
      for (var p = 0; p < categories[c].images.length; p++) {
        test('${angles[a]} selects only ${categories[c].title} option $p', () {
          final random = SequenceRandom([11, a, c, p, 11]);
          final idea = GenerateSuggestions(random: random).detailEdit();
          expect(idea.vehicleId, VehicleCatalog.all.last.id);
          expect(idea.angle, angles[a]);
          expect(idea.category, same(categories[c]));
          expect(idea.partIndex, p);
          expect(idea.color, 'Özel Gri');
          // In particular, the category bound is 3/4/7, never all 9 parts.
          expect(random.bounds, [12, 3, categories.length, 3, 12]);
          expect(random.exhausted, isTrue);
          expectRoundTrip(
            GenerateSelection(
              vehicleId: idea.vehicleId,
              angle: idea.angle,
              parts: {idea.category.title: idea.partIndex},
              detailColor: idea.color,
              detailColorCategory: colorCategoryOf(idea.color),
            ),
          );
          expect(
            const GenerateValidator().detailEdit(
              vehicleId: idea.vehicleId,
              angle: idea.angle,
            ),
            isNull,
          );
        });
      }
    }
  }

  for (var i = 0; i < ModificationPrompts.values.length; i++) {
    test('Description $i is available without any vehicle input', () {
      final random = SequenceRandom([i]);
      final description = GenerateSuggestions(random: random).description();
      expect(description, ModificationPrompts.values[i]);
      expect(description.trim(), isNotEmpty);
      expect(random.exhausted, isTrue);
    });
  }

  test('Consecutive equal choices are allowed, without retry loops', () {
    final random = SequenceRandom([1, 1]);
    final suggestions = GenerateSuggestions(random: random);
    expect(suggestions.description(), suggestions.description());
    expect(random.exhausted, isTrue);
  });

  test('Seeded suggestions preserve the angle/part invariant across calls', () {
    final suggestions = GenerateSuggestions(random: Random(42));
    for (var i = 0; i < 200; i++) {
      final idea = suggestions.detailEdit();
      expect(DetailPartCatalog.forAngle(idea.angle), contains(idea.category));
      expect(
        idea.partIndex,
        inInclusiveRange(0, idea.category.images.length - 1),
      );
      expect(GenerateOptionCatalog.colors, contains(idea.color));
      expect(VehicleCatalog.find(idea.vehicleId), isNotNull);
    }
  });

  test(
    'Color names, category indices and old saved values stay compatible',
    () {
      expect(GenerateOptionCatalog.colors, [
        'Kırmızı',
        'Mavi',
        'Mor',
        'Gri',
        'Premium Kırmızı',
        'Premium Mavi',
        'Premium Mor',
        'Premium Gri',
        'Özel Kırmızı',
        'Özel Mavi',
        'Özel Mor',
        'Özel Gri',
      ]);
      for (var i = 0; i < GenerateOptionCatalog.colors.length; i++) {
        final color = GenerateOptionCatalog.colors[i];
        expect(colorCategoryOf(color), i ~/ 4);
        expect(readColor(color), color);
      }
      expect(readColor('silinen renk'), '');
      expect(readColor(null), '');
    },
  );
}
