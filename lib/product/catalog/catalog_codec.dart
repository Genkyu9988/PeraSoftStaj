import 'dart:convert';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/product/catalog/generate_option_catalog.dart';
import 'package:perasoft_staj/product/catalog/ai_video_items.dart';
import 'package:perasoft_staj/product/catalog/explore_items.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/model/generation_plan.dart';
import 'package:perasoft_staj/product/model/ai_video_template.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';

/// One versioned wire format for both local SQLite and the Django API.
class CatalogCodec {
  static final seedSections = <String, Object>{
    'generate_option_catalog.styles': GenerateOptionCatalog.seedStyles,
    'generate_option_catalog.extras': GenerateOptionCatalog.seedExtras,
    'generate_option_catalog.colorCategories':
        GenerateOptionCatalog.seedColorCategories,
    'generate_option_catalog.baseColors': GenerateOptionCatalog.seedBaseColors,
    'generate_option_catalog.styleVehicleIds':
        GenerateOptionCatalog.seedStyleVehicleIds,
    'generate_option_catalog.styleIds': GenerateOptionCatalog.seedStyleIds,
    'generate_option_catalog.extraIds': GenerateOptionCatalog.seedExtraIds,
    'generate_option_catalog.angleIds': GenerateOptionCatalog.seedAngleIds,
    'generate_option_catalog.colorIds': GenerateOptionCatalog.seedColorIds,
    'generate_option_catalog.colorCategoryIds':
        GenerateOptionCatalog.seedColorCategoryIds,
    'ai_video_items.transformations': AiVideoItems.seedTransformations,
    'ai_video_items.driveScenes': AiVideoItems.seedDriveScenes,
    'ai_video_items.filters': AiVideoItems.seedFilters,
    'explore_items.carMods': ExploreItems.seedCarMods,
    'explore_items.styleBuilder': ExploreItems.seedStyleBuilder,
    'explore_items.wallpaperMaker': ExploreItems.seedWallpaperMaker,
    'explore_items.aiEdits': ExploreItems.seedAiEdits,
    'image_items.styleOptions': ImageItems.seedStyleOptions,
    'image_items.extraOptions': ImageItems.seedExtraOptions,
    'image_items.angleOptions': ImageItems.seedAngleOptions,
    'image_items.exploreCovers': ImageItems.seedExploreCovers,
    'image_items.aiVideoCovers': ImageItems.seedAiVideoCovers,
  };

  static Map<String, Object> decode(Map<String, dynamic> payload) {
    if (payload['schemaVersion'] != 2 || payload['tables'] is! Map) {
      throw const FormatException('Unsupported catalog contract');
    }
    final tables = payload['tables'] as Map;
    List<Map<String, Object?>> table(String name) {
      final rows = tables[name];
      if (rows is! List) throw FormatException('Missing catalog table: $name');
      return [for (final row in rows) Map<String, Object?>.from(row as Map)];
    }

    final result = <String, Object>{};
    final vehicles = table('vehicles');
    CatalogVehicle vehicle(Map<String, Object?> r) => CatalogVehicle(
      id: r['id']! as String,
      label: r['label']! as String,
      imagePath: r['asset_path']! as String,
    );
    result['vehicle_catalog.all'] = List<CatalogVehicle>.unmodifiable(
      vehicles.map(vehicle),
    );
    final samples = vehicles.where((r) => r['sample_position'] != null).toList()
      ..sort(
        (a, b) => (a['sample_position']! as int).compareTo(
          b['sample_position']! as int,
        ),
      );
    result['vehicle_catalog.samples'] = List<CatalogVehicle>.unmodifiable(
      samples.map(vehicle),
    );
    final categories = table('part_categories');
    final options = table('detail_part_options');
    final details = <String, DetailPartCategory>{};
    for (final category in categories) {
      final id = category['id']! as String;
      final rows = options.where((r) => r['category_id'] == id).toList();
      for (var i = 0; i < rows.length; i++) {
        if (rows[i]['slot'] != i) {
          throw FormatException('Non-contiguous detail slots: $id');
        }
      }
      details[id] = DetailPartCategory(
        title: id,
        options: List.unmodifiable([
          for (final row in rows)
            GenerationAsset(
              id: row['part_id']! as String,
              assetPath: row['asset_path']! as String,
            ),
        ]),
      );
    }
    result['detail_part_catalog.all'] = List<DetailPartCategory>.unmodifiable(
      details.values,
    );
    final angles = <String, List<DetailPartCategory>>{};
    for (final row in table('angle_categories')) {
      (angles[row['angle']! as String] ??= []).add(
        details[row['category_id']]!,
      );
    }
    result['detail_part_catalog.byAngle'] =
        Map<String, List<DetailPartCategory>>.unmodifiable(
          angles.map(
            (k, v) => MapEntry(k, List<DetailPartCategory>.unmodifiable(v)),
          ),
        );
    final mods = <String, List<CarModOption>>{};
    for (final row in table('mod_options')) {
      (mods[row['operation']! as String] ??= []).add(
        CarModOption(
          row['part_id']! as String,
          row['label']! as String,
          row['instruction']! as String,
          row['legacy_name']! as String,
          imagePath: row['asset_path']! as String,
        ),
      );
    }
    result['car_mod_option.groups'] =
        Map<String, List<CarModOption>>.unmodifiable(
          mods.map((k, v) => MapEntry(k, List<CarModOption>.unmodifiable(v))),
        );
    result['reference_car_catalog.items'] = List<ReferenceCar>.unmodifiable([
      for (final r in table('reference_cars'))
        ReferenceCar(
          r['id']! as String,
          r['label']! as String,
          r['asset_path']! as String,
        ),
    ]);
    final sections = table('catalog_sections');
    final entries = table('catalog_entries');
    for (final section in sections) {
      final id = section['id']! as String;
      final values = {
        for (final row in entries.where((r) => r['section_id'] == id))
          row['entry_key']! as String: jsonDecode(row['value_json']! as String),
      };
      result[id] = switch (section['value_type']) {
        'list' => List<String>.unmodifiable(values.values.cast<String>()),
        'integers' => Map<String, int>.unmodifiable(values.cast<String, int>()),
        'strings' => Map<String, String>.unmodifiable(
          values.cast<String, String>(),
        ),
        _ => throw FormatException('Unknown catalog value type: $id'),
      };
    }
    for (final key in seedSections.keys) {
      if (!result.containsKey(key)) {
        throw FormatException('Missing catalog section: $key');
      }
    }
    _validate(result);
    return Map.unmodifiable(result);
  }

  static void _validate(Map<String, Object> snapshot) {
    T data<T>(String key) => snapshot[key] as T;
    final vehicles = data<List<CatalogVehicle>>('vehicle_catalog.all');
    if (vehicles.isEmpty) throw const FormatException('Empty vehicle catalog');
    final ids = vehicles.map((v) => v.id).toSet();
    final mappings = data<Map<String, String>>(
      'generate_option_catalog.styleVehicleIds',
    );
    final styles = data<List<String>>('generate_option_catalog.styles');
    final styleIds = data<Map<String, String>>(
      'generate_option_catalog.styleIds',
    );
    if (styles.isEmpty ||
        styles.any(
          (s) => !ids.contains(mappings[s]) || !styleIds.containsKey(s),
        )) {
      throw const FormatException('Invalid style vehicle mapping');
    }
    final extras = data<List<String>>('generate_option_catalog.extras');
    final extraIds = data<Map<String, String>>(
      'generate_option_catalog.extraIds',
    );
    if (extras.isEmpty || extras.any((s) => !extraIds.containsKey(s))) {
      throw const FormatException('Invalid extra catalog');
    }
    final colors = data<Map<String, int>>('generate_option_catalog.baseColors');
    final colorIds = data<Map<String, String>>(
      'generate_option_catalog.colorIds',
    );
    final finishes = data<List<String>>(
      'generate_option_catalog.colorCategories',
    );
    final finishIds = data<Map<String, String>>(
      'generate_option_catalog.colorCategoryIds',
    );
    if (colors.isEmpty ||
        finishes.isEmpty ||
        colors.keys.any((s) => !colorIds.containsKey(s)) ||
        finishes.any((s) => !finishIds.containsKey(s))) {
      throw const FormatException('Invalid color catalog');
    }
    final angles = data<Map<String, List<DetailPartCategory>>>(
      'detail_part_catalog.byAngle',
    );
    final angleIds = data<Map<String, String>>(
      'generate_option_catalog.angleIds',
    );
    if (angles.isEmpty ||
        angles.entries.any(
          (e) =>
              !angleIds.containsKey(e.key) ||
              e.value.isEmpty ||
              e.value.any((c) => c.options.isEmpty),
        )) {
      throw const FormatException('Invalid detail categories');
    }
    for (final section in [
      'carMods',
      'styleBuilder',
      'wallpaperMaker',
      'aiEdits',
    ]) {
      for (final title in data<List<String>>('explore_items.$section')) {
        final operation = ExploreOperation.fromTitle(title);
        if (operation == null) {
          throw FormatException('Unsupported operation: $title');
        }
        if (operation.input == ExploreInput.option &&
            (data<Map<String, List<CarModOption>>>(
                  'car_mod_option.groups',
                )[title]?.isEmpty ??
                true)) {
          throw FormatException('Missing operation options: $title');
        }
      }
    }
    for (final section in ['transformations', 'driveScenes', 'filters']) {
      for (final title in data<List<String>>('ai_video_items.$section')) {
        if (AiVideoTemplate.fromTitle(title) == null) {
          throw FormatException('Unsupported video template: $title');
        }
      }
    }
  }
}
