import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/catalog/generate_option_catalog.dart';

class GenerateSelection {
  const GenerateSelection({
    this.vehicleId = '',
    this.style = '',
    this.extra = '',
    this.color = '',
    this.colorCategory = 0,
    this.angle = '',
    this.parts = const {},
    this.detailColor = '',
    this.detailColorCategory = 0,
  });

  final String vehicleId;
  final String style;
  final String extra;
  final String color;
  final int colorCategory;
  final String angle;
  final Map<String, int> parts;
  final String detailColor;
  final int detailColorCategory;

  Map<String, dynamic> toJson() => {
    'vehicleId': vehicleId,
    'style': style,
    'extra': extra,
    'color': color,
    'colorCategory': colorCategory,
    'angle': angle,
    'parts': parts,
    'detailColor': detailColor,
    'detailColorCategory': detailColorCategory,
  };

  factory GenerateSelection.fromJson(Map<String, dynamic> json) {
    final angle = readChoice(
      json['angle'],
      DetailPartCatalog.byAngle.keys.toList(),
    );
    final color = readColor(json['color']);
    final detailColor = readColor(json['detailColor']);
    return GenerateSelection(
      vehicleId: VehicleCatalog.restoreId(json['vehicleId']),
      style: readChoice(json['style'], GenerateOptionCatalog.styles),
      extra: readChoice(json['extra'], GenerateOptionCatalog.extras),
      color: color,
      colorCategory: colorCategoryOf(color),
      angle: angle,
      parts: DetailPartCatalog.restoreSelections(angle, json['parts']),
      detailColor: detailColor,
      detailColorCategory: colorCategoryOf(detailColor),
    );
  }
}

String readChoice(Object? value, List<String> choices) =>
    value is String && choices.contains(value) ? value : '';

String readColor(Object? value) =>
    readChoice(value, GenerateOptionCatalog.colors);

int colorCategoryOf(String color) =>
    GenerateOptionCatalog.colorCategoryOf(color);
