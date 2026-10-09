import 'package:perasoft_staj/product/catalog/catalog_store.dart';

// The panels, suggestions and saved-selection validation share these choices.
// Existing labels remain unchanged because they are also saved values.
class GenerateOptionCatalog {
  GenerateOptionCatalog._();

  static List<String> get styles =>
      CatalogStore.read('generate_option_catalog.styles', seedStyles);

  static const seedStyles = [
    'Klasik',
    'Sportif',
    'Off Road',
    'SUV',
    'Yarış',
    'Şehir',
  ];
  // A confirmed manual style card also selects its displayed sample vehicle.
  // Keep stable catalog IDs, not translated car labels or sample-list indices.
  static Map<String, String> get styleVehicleIds => CatalogStore.read(
    'generate_option_catalog.styleVehicleIds',
    seedStyleVehicleIds,
  );

  static const seedStyleVehicleIds = {
    'Klasik': 'mustang_classic',
    'Sportif': 'porsche_911',
    'Off Road': 'jeep_wrangler',
    'SUV': 'bmw_ix5',
    'Yarış': 'porsche_race',
    'Şehir': 'fiat_500',
  };
  static List<String> get extras =>
      CatalogStore.read('generate_option_catalog.extras', seedExtras);

  static const seedExtras = [
    'Jant',
    'Spoiler',
    'Boya',
    'Neon',
    'Kaput',
    'Gövde Kiti',
  ];

  static List<String> get colorCategories => CatalogStore.read(
    'generate_option_catalog.colorCategories',
    seedColorCategories,
  );

  static const seedColorCategories = ['Mat', 'Premium', 'Özel'];
  static Map<String, int> get baseColors =>
      CatalogStore.read('generate_option_catalog.baseColors', seedBaseColors);

  static const seedBaseColors = {
    'Kırmızı': 0xffD51F18,
    'Mavi': 0xff126EDB,
    'Mor': 0xff7E32B8,
    'Gri': 0xff646A72,
  };

  static String colorTitle(String name, int category) =>
      category == 0 ? name : '${colorCategories[category]} $name';

  static List<String> get colors => List<String>.unmodifiable([
    for (var category = 0; category < colorCategories.length; category++)
      for (final name in baseColors.keys) colorTitle(name, category),
  ]);

  static int colorCategoryOf(String title) {
    for (var category = 1; category < colorCategories.length; category++) {
      if (title.startsWith('${colorCategories[category]} ')) return category;
    }
    return 0;
  }

  // Explicit domain IDs: do not derive them from translated labels or indices.
  // Existing UI/cache values above remain unchanged.
  static Map<String, String> get styleIds =>
      CatalogStore.read('generate_option_catalog.styleIds', seedStyleIds);

  static const seedStyleIds = {
    'Klasik': 'style.classic',
    'Sportif': 'style.sport',
    'Off Road': 'style.off_road',
    'SUV': 'style.suv',
    'Yarış': 'style.racing',
    'Şehir': 'style.city',
  };
  static Map<String, String> get extraIds =>
      CatalogStore.read('generate_option_catalog.extraIds', seedExtraIds);

  static const seedExtraIds = {
    'Jant': 'extra.rims',
    'Spoiler': 'extra.spoiler',
    'Boya': 'extra.paint',
    'Neon': 'extra.neon',
    'Kaput': 'extra.hood',
    'Gövde Kiti': 'extra.body_kit',
  };
  static Map<String, String> get angleIds =>
      CatalogStore.read('generate_option_catalog.angleIds', seedAngleIds);

  static const seedAngleIds = {
    'Front': 'angle.front',
    'Rear': 'angle.rear',
    'Side': 'angle.side',
  };
  static Map<String, String> get colorIds =>
      CatalogStore.read('generate_option_catalog.colorIds', seedColorIds);

  static const seedColorIds = {
    'Kırmızı': 'red',
    'Mavi': 'blue',
    'Mor': 'purple',
    'Gri': 'gray',
  };
  static Map<String, String> get colorCategoryIds => CatalogStore.read(
    'generate_option_catalog.colorCategoryIds',
    seedColorCategoryIds,
  );

  static const seedColorCategoryIds = {
    'Mat': 'matte',
    'Premium': 'premium',
    'Özel': 'special',
  };
}
