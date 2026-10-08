import 'dart:math';

import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/catalog/generate_option_catalog.dart';
import 'package:perasoft_staj/feature/generate/data/modification_prompts.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';

// VB10 #14: Random/nextInt and callbacks; #18: inject the dependency for tests.
// No widget, context, storage or network dependency belongs in this selector.
class GenerateSuggestions {
  GenerateSuggestions({Random? random}) : _random = random ?? Random();

  final Random _random;

  T _pick<T>(List<T> choices) => choices[_random.nextInt(choices.length)];

  CatalogVehicle vehicle() => _pick(VehicleCatalog.all);

  String description() => _pick(ModificationPrompts.values);

  StyleSuggestion styleBuilder() => StyleSuggestion(
    vehicleId: vehicle().id,
    style: _pick(GenerateOptionCatalog.styles),
    extra: _pick(GenerateOptionCatalog.extras),
    color: _pick(GenerateOptionCatalog.colors),
  );

  DetailSuggestion detailEdit() {
    final vehicleId = vehicle().id;
    final angle = _pick(DetailPartCatalog.byAngle.keys.toList());
    // User's rule: choose the angle FIRST, then only its allowed categories.
    // The same catalog drives the manual panel and cache restoration.
    final category = _pick(DetailPartCatalog.forAngle(angle));
    return DetailSuggestion(
      vehicleId: vehicleId,
      angle: angle,
      category: category,
      partIndex: _random.nextInt(category.images.length),
      color: _pick(GenerateOptionCatalog.colors),
    );
  }
}

class StyleSuggestion {
  const StyleSuggestion({
    required this.vehicleId,
    required this.style,
    required this.extra,
    required this.color,
  });

  final String vehicleId;
  final String style;
  final String extra;
  final String color;
}

class DetailSuggestion {
  const DetailSuggestion({
    required this.vehicleId,
    required this.angle,
    required this.category,
    required this.partIndex,
    required this.color,
  });

  final String vehicleId;
  final String angle;
  final DetailPartCategory category;
  final int partIndex;
  final String color;
}
