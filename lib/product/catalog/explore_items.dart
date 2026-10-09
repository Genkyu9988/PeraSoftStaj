import 'package:perasoft_staj/product/catalog/catalog_store.dart';

class ExploreItems {
  static const carModsTitle = 'Car Mods';
  static const styleBuilderTitle = 'Style Builder';
  static const wallpaperMakerTitle = 'Wallpaper Maker';
  static const aiEditsTitle = 'AI Edits';
  static const mockLabel = 'Mock';
  static const initialGridCount = 9;
  static const loadMoreLabel = 'Daha Fazla Yükle';

  static List<String> get carMods =>
      CatalogStore.read('explore_items.carMods', seedCarMods);

  static const seedCarMods = [
    'Change Color',
    'Customize Rims',
    'Suspension',
    'Neons',
    'Tire',
    'Spoiler',
    'Sound System',
    'Window Tints',
    'Exhaust',
    'Chrome Delete',
    'Body Kit',
    'Perspective',
    'Mirror Swap',
    'Sunroof Mood',
    'Put On Sticker',
    'Upholstery',
  ];

  static List<String> get styleBuilder =>
      CatalogStore.read('explore_items.styleBuilder', seedStyleBuilder);

  static const seedStyleBuilder = [
    'American',
    'Japanese',
    'Off Road',
    'SUV',
    'Racing',
  ];

  static List<String> get wallpaperMaker =>
      CatalogStore.read('explore_items.wallpaperMaker', seedWallpaperMaker);

  static const seedWallpaperMaker = [
    'Most WT',
    'Countryside',
    'Tuner Shop',
    'Crystal',
    'Night City',
  ];

  static List<String> get aiEdits =>
      CatalogStore.read('explore_items.aiEdits', seedAiEdits);

  static const seedAiEdits = [
    'Car Enhance',
    'Speed Trap',
    'Grand City Auto',
    'Dream Car & Me',
    'AI Crash Effect',
    'AI Car Restore',
    'Mini Toy Car',
    'Mody AI Technic',
    '3D Car Figurine',
    'Transformers',
    'Clone Car Style',
  ];
}
