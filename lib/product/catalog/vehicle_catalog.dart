import 'package:perasoft_staj/product/catalog/catalog_store.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';

class CatalogVehicle {
  const CatalogVehicle({
    required this.id,
    required this.label,
    required this.imagePath,
  });

  final String id;
  final String label;
  final String imagePath;
}

// One local catalog; screens store an ID, not a translated label or list index.
class VehicleCatalog {
  static List<CatalogVehicle> get samples =>
      CatalogStore.read('vehicle_catalog.samples', seedSamples);

  static const seedSamples = <CatalogVehicle>[
    CatalogVehicle(
      id: 'mustang_classic',
      label: 'Klasik Mustang',
      imagePath: ImageItems.classic,
    ),
    CatalogVehicle(
      id: 'porsche_911',
      label: 'Porsche 911',
      imagePath: ImageItems.sport,
    ),
    CatalogVehicle(
      id: 'jeep_wrangler',
      label: 'Jeep Wrangler',
      imagePath: ImageItems.offRoad,
    ),
    CatalogVehicle(id: 'bmw_ix5', label: 'BMW iX5', imagePath: ImageItems.suv),
    CatalogVehicle(
      id: 'fiat_500',
      label: 'Fiat 500',
      imagePath: ImageItems.city,
    ),
  ];

  static List<CatalogVehicle> get all =>
      CatalogStore.read('vehicle_catalog.all', seedAll);

  static const seedAll = <CatalogVehicle>[
    ...seedSamples,
    CatalogVehicle(
      id: 'porsche_race',
      label: 'Porsche Yarış',
      imagePath: ImageItems.race,
    ),
    CatalogVehicle(
      id: 'bmw_525',
      label: 'BMW 525',
      imagePath: ImageItems.catalogBmw525,
    ),
    CatalogVehicle(
      id: 'mustang_gt',
      label: 'Mustang GT',
      imagePath: ImageItems.catalogMustangGt,
    ),
    CatalogVehicle(
      id: 'mustang_blue',
      label: 'Mavi Mustang',
      imagePath: ImageItems.catalogMustangBlue,
    ),
    CatalogVehicle(
      id: 'skyline_gtr',
      label: 'Skyline GT-R',
      imagePath: ImageItems.catalogSkyline,
    ),
    CatalogVehicle(
      id: 'impala_lowrider',
      label: 'Impala Lowrider',
      imagePath: ImageItems.catalogImpala,
    ),
    CatalogVehicle(
      id: 'buick_classic',
      label: 'Klasik Buick',
      imagePath: ImageItems.catalogBuick,
    ),
  ];

  static CatalogVehicle? find(String id) {
    for (final vehicle in all) {
      if (vehicle.id == id) return vehicle;
    }
    return null;
  }

  static String restoreId(Object? value) {
    if (value is! String) return '';
    if (find(value) != null) return value;
    // Only old sample entries refer to known photos. Mock entries do not.
    for (var i = 0; i < samples.length; i++) {
      if (value == 'Örnek Araç ${i + 1}') return samples[i].id;
    }
    return '';
  }
}
