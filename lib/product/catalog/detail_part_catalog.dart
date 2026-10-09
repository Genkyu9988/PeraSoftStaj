import 'package:perasoft_staj/product/catalog/catalog_store.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/model/generation_plan.dart';

// VB10 #7: the section receives its model, not the whole catalog and an index.
class DetailPartCategory {
  const DetailPartCategory({required this.title, required this.options});

  // Titles and image order are existing saved keys/indices. Keep them stable.
  final String title;
  final List<GenerationAsset> options;
  List<String> get images => List.unmodifiable(options.map((e) => e.assetPath));
}

class DetailPartCatalog {
  static DetailPartCategory get frontBumper =>
      all.firstWhere((c) => c.title == 'Front Bumper');

  static const seedFrontBumper = DetailPartCategory(
    title: 'Front Bumper',
    options: [
      GenerationAsset(
        id: 'front_bumper.sport',
        assetPath: ImageItems.frontBumperSport,
      ),
      GenerationAsset(
        id: 'front_bumper.classic',
        assetPath: ImageItems.frontBumperClassic,
      ),
      GenerationAsset(
        id: 'front_bumper.chrome',
        assetPath: ImageItems.frontBumperChrome,
      ),
    ],
  );
  static DetailPartCategory get hood =>
      all.firstWhere((c) => c.title == 'Hood');

  static const seedHood = DetailPartCategory(
    title: 'Hood',
    options: [
      GenerationAsset(id: 'hood.classic', assetPath: ImageItems.hoodClassic),
      GenerationAsset(id: 'hood.scoop', assetPath: ImageItems.hoodScoop),
      GenerationAsset(
        id: 'hood.carbon_scoop',
        assetPath: ImageItems.hoodCarbonScoop,
      ),
    ],
  );
  static DetailPartCategory get headlights =>
      all.firstWhere((c) => c.title == 'Headlights');

  static const seedHeadlights = DetailPartCategory(
    title: 'Headlights',
    options: [
      GenerationAsset(
        id: 'headlight.modern',
        assetPath: ImageItems.headlightModern,
      ),
      GenerationAsset(id: 'headlight.led', assetPath: ImageItems.headlightLed),
      GenerationAsset(
        id: 'headlight.round',
        assetPath: ImageItems.headlightRound,
      ),
    ],
  );
  static DetailPartCategory get spoiler =>
      all.firstWhere((c) => c.title == 'Spoiler');

  static const seedSpoiler = DetailPartCategory(
    title: 'Spoiler',
    options: [
      GenerationAsset(
        id: 'spoiler.race_wing',
        assetPath: ImageItems.spoilerRaceWing,
      ),
      GenerationAsset(
        id: 'spoiler.sport_wing',
        assetPath: ImageItems.spoilerSportWing,
      ),
      GenerationAsset(
        id: 'spoiler.roof_lip',
        assetPath: ImageItems.spoilerRoofLip,
      ),
    ],
  );
  static DetailPartCategory get exhaust =>
      all.firstWhere((c) => c.title == 'Exhaust');

  static const seedExhaust = DetailPartCategory(
    title: 'Exhaust',
    options: [
      GenerationAsset(
        id: 'exhaust.single',
        assetPath: ImageItems.exhaustSingle,
      ),
      GenerationAsset(
        id: 'exhaust.quad_black',
        assetPath: ImageItems.exhaustQuadBlack,
      ),
      GenerationAsset(
        id: 'exhaust.quad_metal',
        assetPath: ImageItems.exhaustQuadMetal,
      ),
    ],
  );
  static DetailPartCategory get rearBumper =>
      all.firstWhere((c) => c.title == 'Rear Bumper & Diffuser');

  static const seedRearBumper = DetailPartCategory(
    title: 'Rear Bumper & Diffuser',
    options: [
      GenerationAsset(
        id: 'body.rear_diffuser',
        assetPath: ImageItems.bodyRearDiffuser,
      ),
      GenerationAsset(
        id: 'diffuser.sport',
        assetPath: ImageItems.diffuserSport,
      ),
      GenerationAsset(id: 'diffuser.race', assetPath: ImageItems.diffuserRace),
    ],
  );
  static DetailPartCategory get tailLights =>
      all.firstWhere((c) => c.title == 'Tail Lights');

  static const seedTailLights = DetailPartCategory(
    title: 'Tail Lights',
    options: [
      GenerationAsset(
        id: 'tail_light.classic',
        assetPath: ImageItems.tailLightClassic,
      ),
      GenerationAsset(id: 'tail_light.led', assetPath: ImageItems.tailLightLed),
      GenerationAsset(
        id: 'tail_light.round',
        assetPath: ImageItems.tailLightRound,
      ),
    ],
  );
  static DetailPartCategory get rims =>
      all.firstWhere((c) => c.title == 'Rims/Wheels');

  static const seedRims = DetailPartCategory(
    title: 'Rims/Wheels',
    options: [
      GenerationAsset(
        id: 'detail_rim.classic',
        assetPath: ImageItems.rimClassic,
      ),
      GenerationAsset(id: 'detail_rim.alloy', assetPath: ImageItems.rimAlloy),
      GenerationAsset(id: 'detail_rim.sport', assetPath: ImageItems.rimSport),
    ],
  );
  static DetailPartCategory get sideSkirts =>
      all.firstWhere((c) => c.title == 'Side Skirts');

  static const seedSideSkirts = DetailPartCategory(
    title: 'Side Skirts',
    options: [
      GenerationAsset(
        id: 'body.side_skirt',
        assetPath: ImageItems.bodySideSkirt,
      ),
      GenerationAsset(
        id: 'side_skirt.carbon',
        assetPath: ImageItems.sideSkirtCarbon,
      ),
      GenerationAsset(
        id: 'side_skirt.modulo',
        assetPath: ImageItems.sideSkirtModulo,
      ),
    ],
  );

  static List<DetailPartCategory> get all =>
      CatalogStore.read('detail_part_catalog.all', seedAll);

  static const seedAll = [
    seedFrontBumper,
    seedHood,
    seedHeadlights,
    seedSpoiler,
    seedExhaust,
    seedRearBumper,
    seedTailLights,
    seedRims,
    seedSideSkirts,
  ];

  // Product rules verified by the user, not rules from the Flutter course.
  static Map<String, List<DetailPartCategory>> get byAngle =>
      CatalogStore.read('detail_part_catalog.byAngle', seedByAngle);

  static const seedByAngle = {
    'Front': [seedFrontBumper, seedHood, seedHeadlights],
    'Rear': [seedSpoiler, seedExhaust, seedRearBumper, seedTailLights],
    'Side': [
      seedSpoiler,
      seedRims,
      seedExhaust,
      seedFrontBumper,
      seedRearBumper,
      seedHood,
      seedSideSkirts,
    ],
  };

  static List<DetailPartCategory> forAngle(String angle) =>
      byAngle[angle] ?? const [];

  // UI and restoration share the same allowed categories and option counts.
  // Old wrong-angle selections are dropped; valid saved indices stay unchanged.
  static Map<String, int> restoreSelections(String angle, Object? value) {
    if (value is! Map) return {};
    final selections = <String, int>{};
    for (final category in forAngle(angle)) {
      final index = value[category.title];
      if (index is int && index >= 0 && index < category.images.length) {
        selections[category.title] = index;
      }
    }
    return selections;
  }
}
