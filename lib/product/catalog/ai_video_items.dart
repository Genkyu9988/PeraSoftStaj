import 'package:perasoft_staj/product/catalog/catalog_store.dart';

class AiVideoItems {
  static const transformationsTitle = 'AI Video Transformations';
  static const driveScenesTitle = 'AI Drive Scenes';
  static const filtersTitle = 'AI Video Filters';

  // Görsellerde görünmeyen son iki seçenek geçici mock isimlerdir.
  static List<String> get transformations =>
      CatalogStore.read('ai_video_items.transformations', seedTransformations);

  static const seedTransformations = [
    'Apex Transform',
    'Pit Stop Transformation',
    'Magnetic Transformation',
    'Neon Transformation',
    'Classic Transformation',
  ];
  static List<String> get driveScenes =>
      CatalogStore.read('ai_video_items.driveScenes', seedDriveScenes);

  static const seedDriveScenes = [
    'Cliff Fly',
    'Cliff Drive',
    'Snow Drift',
    'City Drive',
    'Desert Drive',
  ];
  static List<String> get filters =>
      CatalogStore.read('ai_video_items.filters', seedFilters);

  static const seedFilters = [
    'Zoom Out',
    'Zoom In',
    'Hydraulic Heatwave',
    'Race Video',
    'Drift Showdown',
  ];
}
