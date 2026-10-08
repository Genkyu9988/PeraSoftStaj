// The panels, suggestions and saved-selection validation share these choices.
// Existing labels remain unchanged because they are also saved values.
class GenerateOptionCatalog {
  GenerateOptionCatalog._();

  static const styles = [
    'Klasik',
    'Sportif',
    'Off Road',
    'SUV',
    'Yarış',
    'Şehir',
  ];
  // A confirmed manual style card also selects its displayed sample vehicle.
  // Keep stable catalog IDs, not translated car labels or sample-list indices.
  static const styleVehicleIds = {
    'Klasik': 'mustang_classic',
    'Sportif': 'porsche_911',
    'Off Road': 'jeep_wrangler',
    'SUV': 'bmw_ix5',
    'Yarış': 'porsche_race',
    'Şehir': 'fiat_500',
  };
  static const extras = [
    'Jant',
    'Spoiler',
    'Boya',
    'Neon',
    'Kaput',
    'Gövde Kiti',
  ];

  static const colorCategories = ['Mat', 'Premium', 'Özel'];
  static const baseColors = {
    'Kırmızı': 0xffD51F18,
    'Mavi': 0xff126EDB,
    'Mor': 0xff7E32B8,
    'Gri': 0xff646A72,
  };

  static String colorTitle(String name, int category) =>
      category == 0 ? name : '${colorCategories[category]} $name';

  static final colors = List<String>.unmodifiable([
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
  static const styleIds = {
    'Klasik': 'style.classic',
    'Sportif': 'style.sport',
    'Off Road': 'style.off_road',
    'SUV': 'style.suv',
    'Yarış': 'style.racing',
    'Şehir': 'style.city',
  };
  static const extraIds = {
    'Jant': 'extra.rims',
    'Spoiler': 'extra.spoiler',
    'Boya': 'extra.paint',
    'Neon': 'extra.neon',
    'Kaput': 'extra.hood',
    'Gövde Kiti': 'extra.body_kit',
  };
  static const angleIds = {
    'Front': 'angle.front',
    'Rear': 'angle.rear',
    'Side': 'angle.side',
  };
  static const colorIds = {
    'Kırmızı': 'red',
    'Mavi': 'blue',
    'Mor': 'purple',
    'Gri': 'gray',
  };
  static const colorCategoryIds = {
    'Mat': 'matte',
    'Premium': 'premium',
    'Özel': 'special',
  };
}
