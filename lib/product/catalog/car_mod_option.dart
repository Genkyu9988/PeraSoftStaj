import 'package:perasoft_staj/product/catalog/catalog_store.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/model/image_choice.dart';

// Display text, persistent identity and generation intent are separate concerns.
class CarModOption implements ImageChoice {
  const CarModOption(
    this.id,
    this.label,
    this.instruction,
    this.legacyName, {
    required this.imagePath,
  });
  @override
  final String id;
  @override
  final String label;
  final String instruction;
  final String legacyName;
  @override
  final String imagePath;
}

class CarModCatalog {
  static Map<String, List<CarModOption>> get groups =>
      CatalogStore.read('car_mod_option.groups', seedGroups);

  static const seedGroups = <String, List<CarModOption>>{
    'Spoiler': [
      CarModOption(
        'spoiler.race_wing',
        'Yarış Kanadı',
        'Add a tall rear racing wing with two supports and endplates. Preserve the input vehicle model, paint, wheels and camera angle. Do not copy logos or sponsor text.',
        '',
        imagePath: ImageItems.spoilerRaceWing,
      ),
      CarModOption(
        'spoiler.sport_wing',
        'Sportif Kanat',
        'Add a curved sporty rear wing on the trunk. Preserve the input vehicle identity, paint and background; do not copy the reference car model.',
        '',
        imagePath: ImageItems.spoilerSportWing,
      ),
      CarModOption(
        'spoiler.roof_lip',
        'Tavan Spoileri',
        'Add a slim body-colored spoiler along the upper edge of the rear window. Preserve the trunk, vehicle paint, model and camera angle.',
        '',
        imagePath: ImageItems.spoilerRoofLip,
      ),
    ],
    'Sound System': [
      CarModOption(
        'audio.subwoofer',
        'Bagaj Subwoofer',
        'Add a single boxed subwoofer inside the trunk. Preserve the vehicle identity and existing camera angle. Show it only if the trunk interior is visible; do not add branding.',
        '',
        imagePath: ImageItems.audioSubwoofer,
      ),
      CarModOption(
        'audio.tweeter',
        'Kompakt Tweeter',
        'Add a compact mesh-covered tweeter near the interior mirror triangle. Preserve trim, vehicle and camera angle. Show it only if the relevant interior area is visible; do not add brand lettering.',
        '',
        imagePath: ImageItems.audioTweeter,
      ),
      CarModOption(
        'audio.show_install',
        'Çok Hoparlörlü Sistem',
        'Add a custom multi-speaker installation inside the trunk and trunk lid. Preserve the input vehicle identity and paint. Show it only from a suitable open-trunk view; do not copy the reference vehicle or advertising.',
        '',
        imagePath: ImageItems.audioShowInstall,
      ),
    ],
    'Window Tints': [
      CarModOption(
        'tint.light',
        'Hafif Karartma',
        'Apply a subtle neutral smoke appearance to the side and rear windows while keeping the interior clearly visible. Preserve paint, window surrounds, windshield and camera angle. This is a visual request, not a measured transmission specification.',
        '',
        imagePath: ImageItems.tintLight,
      ),
      CarModOption(
        'tint.dark',
        'Koyu Karartma',
        'Apply a dark smoke appearance to the side and rear windows. Keep the windshield, paint, window frames and camera angle unchanged. Do not infer a measured light-transmission value from the reference.',
        '',
        imagePath: ImageItems.tintDark,
      ),
      CarModOption(
        'tint.reflective',
        'Yansımalı Cam',
        'Give the side and rear windows a reflective tinted appearance with reflections consistent with the input scene. Preserve windshield, body paint and window frames; do not copy the reference clouds or photographer.',
        '',
        imagePath: ImageItems.tintReflective,
      ),
    ],
    'Exhaust': [
      CarModOption(
        'exhaust.single',
        'Tek Yuvarlak Uç',
        'Use a single clean round metal exhaust tip at the rear. Preserve the vehicle identity, paint and camera angle. Do not copy dirt, rust or the underbody camera view.',
        '',
        imagePath: ImageItems.exhaustSingle,
      ),
      CarModOption(
        'exhaust.quad_black',
        'Dört Siyah Uç',
        'Use four dark exhaust tips arranged as two pairs at the rear. Preserve the vehicle identity, paint and camera angle. Show installed tips, not the detached exhaust system in the reference.',
        '',
        imagePath: ImageItems.exhaustQuadBlack,
      ),
      CarModOption(
        'exhaust.quad_metal',
        'Dört Metal Uç',
        'Use four round metallic exhaust tips arranged as two pairs at the rear. Preserve the vehicle identity, body paint and camera angle.',
        '',
        imagePath: ImageItems.exhaustQuadMetal,
      ),
    ],
    'Chrome Delete': [
      CarModOption(
        'chrome.grille_black',
        'Siyah Izgara',
        'Black out the chrome grille surround and grille slats. Preserve grille shape, logos, body paint, wheels and background.',
        '',
        imagePath: ImageItems.chromeGrilleBlack,
      ),
      CarModOption(
        'chrome.window_trim_black',
        'Siyah Cam Çerçevesi',
        'Change only chrome window surrounds to black. Do not tint the glass or change the body paint, wheels or camera angle.',
        '',
        imagePath: ImageItems.chromeWindowTrimBlack,
      ),
    ],
    'Body Kit': [
      CarModOption(
        'body.side_skirt',
        'Yan Etek',
        'Add sporty side skirts along the lower rocker panels. Keep the body width, bumpers, paint and camera angle unchanged.',
        '',
        imagePath: ImageItems.bodySideSkirt,
      ),
      CarModOption(
        'body.wide',
        'Geniş Gövde',
        'Add widened wheel arches and a coordinated wide body kit while retaining the identity and paint of the input vehicle. Do not copy the reference car model.',
        '',
        imagePath: ImageItems.bodyWide,
      ),
      CarModOption(
        'body.rear_diffuser',
        'Arka Difüzör',
        'Add a sporty finned rear diffuser below the rear bumper. Preserve the vehicle identity, paint and exhaust configuration.',
        '',
        imagePath: ImageItems.bodyRearDiffuser,
      ),
    ],
    'Perspective': [
      CarModOption(
        'perspective.front_quarter',
        'Ön Çapraz',
        'Render the same input vehicle from a front three-quarter angle. Preserve its model, paint, wheels and modifications. The reference demonstrates angle only.',
        '',
        imagePath: ImageItems.perspectiveFrontQuarter,
      ),
      CarModOption(
        'perspective.rear_quarter',
        'Arka Çapraz',
        'Render the same input vehicle from a rear three-quarter angle. Preserve its model, paint, wheels and modifications. The reference demonstrates angle only.',
        '',
        imagePath: ImageItems.perspectiveRearQuarter,
      ),
      CarModOption(
        'perspective.side',
        'Yan',
        'Render the same input vehicle in side profile. Preserve its model, paint, wheels and modifications. Do not copy the open hood or model of the reference.',
        '',
        imagePath: ImageItems.perspectiveSide,
      ),
    ],
    'Mirror Swap': [
      CarModOption(
        'mirror.black',
        'Siyah Ayna',
        'Use black housings for the exterior side mirrors. Preserve the body paint, vehicle identity, background and camera angle. Do not copy the reflection from the reference.',
        '',
        imagePath: ImageItems.mirrorBlack,
      ),
      CarModOption(
        'mirror.carbon',
        'Karbon Desenli Ayna',
        'Apply a visible carbon fiber weave finish to the exterior side mirror housings. Preserve the mirror shape, body paint and vehicle identity.',
        '',
        imagePath: ImageItems.mirrorCarbon,
      ),
    ],
    'Sunroof Mood': [
      CarModOption(
        'roof.glass',
        'Panoramik Cam Tavan',
        'Add a panoramic glass roof with the interior shade retracted. Preserve the vehicle identity and camera angle. Do not change the exterior into an interior view to match the reference.',
        '',
        imagePath: ImageItems.roofGlass,
      ),
      CarModOption(
        'roof.shade_closed',
        'Kapalı Tavan Perdesi',
        'Close the interior sunroof shade. Keep the exterior roof, vehicle and camera angle unchanged. The shade is visible only from a suitable interior viewpoint.',
        '',
        imagePath: ImageItems.roofShadeClosed,
      ),
      CarModOption(
        'roof.dual',
        'Çift Panelli Cam Tavan',
        'Add two glass roof panels separated by a roof cross-member. Preserve the vehicle identity, paint and camera angle.',
        '',
        imagePath: ImageItems.roofDual,
      ),
    ],
    'Put On Sticker': [
      CarModOption(
        'sticker.racing_stripes',
        'Çift Yarış Şeridi',
        'Add two parallel racing stripes along the center of the hood, roof and trunk where applicable. Preserve the base paint and vehicle identity. Do not add text or brands.',
        '',
        imagePath: ImageItems.stickerRacingStripes,
      ),
      CarModOption(
        'sticker.leaves',
        'Yaprak Desenli Kaplama',
        'Apply a turquoise and blue leaf-pattern vinyl wrap. Preserve the vehicle shape and wheels. Do not copy any advertising, lettering or logos from the reference.',
        '',
        imagePath: ImageItems.stickerLeaves,
      ),
      CarModOption(
        'sticker.race_livery',
        'Yarış Grafikleri',
        'Add racing-style color blocks and graphic accents on the body. Preserve the input vehicle model and wheels. Do not add sponsor names, brand logos or text.',
        '',
        imagePath: ImageItems.stickerRaceLivery,
      ),
    ],
    'Upholstery': [
      CarModOption(
        'upholstery.black',
        'Siyah Deri',
        'Use black leather seat upholstery. Preserve seat shapes, dashboard, vehicle and camera angle. This interior change is visible only when the seats are visible.',
        '',
        imagePath: ImageItems.upholsteryBlack,
      ),
      CarModOption(
        'upholstery.tan',
        'Taba Deri',
        'Use tan brown leather seat upholstery. Preserve seat shapes, dashboard, vehicle and camera angle. Do not copy the classic dashboard from the reference.',
        '',
        imagePath: ImageItems.upholsteryTan,
      ),
      CarModOption(
        'upholstery.red_black',
        'Kırmızı-Siyah Deri',
        'Use red leather center panels with black leather bolsters on the seats. Preserve seat shapes, dashboard and camera angle.',
        '',
        imagePath: ImageItems.upholsteryRedBlack,
      ),
    ],
    'Customize Rims': [
      CarModOption(
        'rim.five_spoke',
        'Beş Kollu Jant',
        'Replace the wheel rims with silver five-spoke rims. Keep the tires and vehicle unchanged.',
        'Rim 1',
        imagePath: 'assets/images/rim.jpg',
      ),
      CarModOption(
        'rim.mesh',
        'Örgü Desenli Jant',
        'Replace the wheel rims with silver mesh-pattern rims. Keep the tires and vehicle unchanged.',
        'Rim 2',
        imagePath: 'assets/images/mod_rim_2.jpg',
      ),
      CarModOption(
        'rim.split_spoke',
        'Çift Kollu Jant',
        'Replace the wheel rims with silver split-spoke rims. Keep the tires and vehicle unchanged.',
        'Rim 3',
        imagePath: 'assets/images/mod_rim_3.jpg',
      ),
      CarModOption(
        'rim.blue_accents',
        'Mavi Detaylı Jant',
        'Replace the wheel rims with black rims with blue spoke and outer-edge accents. Do not recolor the car or brake calipers.',
        'Rim 4',
        imagePath: 'assets/images/mod_rim_4.jpg',
      ),
      CarModOption(
        'rim.multi_spoke',
        'Çok Kollu Jant',
        'Replace the wheel rims with silver thin multi-spoke rims. Keep the tires and vehicle unchanged.',
        'Rim 5',
        imagePath: 'assets/images/mod_rim_5.jpg',
      ),
    ],
    'Suspension': [
      CarModOption(
        'stance.lowrider',
        'Lowrider Duruş',
        'Lower the vehicle into a lowrider stance with minimal ground clearance. Keep its identity, paint and background unchanged.',
        'Suspension 1',
        imagePath: 'assets/images/explore_suspension.jpg',
      ),
      CarModOption(
        'stance.off_road',
        'Arazi Yüksekliği',
        'Raise the suspension for increased off-road ground clearance. Keep the vehicle identity, paint, wheels and background unchanged.',
        'Suspension 2',
        imagePath: ImageItems.offRoad,
      ),
      CarModOption(
        'stance.slammed',
        'Yere Yakın Duruş',
        'Lower the body very close to the ground with the wheels tucked inside the arches. Preserve vehicle identity and paint.',
        'Suspension 3',
        imagePath: 'assets/images/mod_suspension_3.jpg',
      ),
      CarModOption(
        'stance.sport',
        'Sportif Alçaltma',
        'Moderately lower the suspension for a sporty stance and reduce the wheel arch gap. Keep the wheels, vehicle identity and paint unchanged.',
        'Suspension 4',
        imagePath: 'assets/images/mod_suspension_4.jpg',
      ),
      CarModOption(
        'stance.monster',
        'Monster Duruş',
        'Create an extreme monster-truck stance with a very high suspension and oversized off-road tires. Preserve the recognizable vehicle body and paint.',
        'Suspension 5',
        imagePath: 'assets/images/mod_suspension_5.jpg',
      ),
    ],
    'Neons': [
      CarModOption(
        'neon.purple',
        'Mor Alt Aydınlatma',
        'Add purple underbody lighting with a purple glow on the ground beneath the vehicle. Do not recolor the body, headlights or wheels.',
        'Neon 1',
        imagePath: 'assets/images/neon_purple_photo.png',
      ),
      CarModOption(
        'neon.cyan',
        'Turkuaz Alt Aydınlatma',
        'Add cyan underbody lighting with a cyan glow on the ground beneath the vehicle. Do not recolor the body, headlights or wheels.',
        'Neon 2',
        imagePath: 'assets/images/neon_cyan_photo.png',
      ),
      CarModOption(
        'neon.green',
        'Yeşil Alt Aydınlatma',
        'Add green underbody lighting with a green glow on the ground beneath the vehicle. Do not recolor the body, headlights or wheels.',
        'Neon 3',
        imagePath: 'assets/images/neon_green_photo.png',
      ),
      CarModOption(
        'neon.red',
        'Kırmızı Alt Aydınlatma',
        'Add red underbody lighting with a red glow on the ground beneath the vehicle. Do not recolor the body, headlights or wheels.',
        'Neon 4',
        imagePath: 'assets/images/neon_red_photo.jpg',
      ),
      CarModOption(
        'neon.multicolor',
        'Çok Renkli Alt Işık',
        'Add multicolor underbody lighting blending cyan, purple and pink on the ground beneath the vehicle. Do not recolor the body, headlights or wheels.',
        'Neon 5',
        imagePath: 'assets/images/neon_multicolor_photo.png',
      ),
    ],
    'Tire': [
      CarModOption(
        'tire.directional',
        'Yönlü Desen',
        'Use tires with a directional V-shaped tread pattern. Preserve rim design, vehicle paint and stance. Show tread only where visible from the original camera angle.',
        'Tire 1',
        imagePath: 'assets/images/explore_tire.jpg',
      ),
      CarModOption(
        'tire.grooved_race',
        'Oluklu Yarış Lastiği',
        'Use wide grooved racing tires with sparse curved tread channels. Preserve the vehicle body and rim design. Do not add branding or text.',
        'Tire 2',
        imagePath: 'assets/images/mod_tire_2.jpg',
      ),
      CarModOption(
        'tire.whitewall',
        'Beyaz Yanak',
        'Add a broad white sidewall band to the tires. Preserve the rims, tire dimensions, vehicle body and paint.',
        'Tire 3',
        imagePath: 'assets/images/mod_tire_3.jpg',
      ),
      CarModOption(
        'tire.diagonal',
        'Çapraz Kanallı Desen',
        'Use tires with diagonal tread grooves as a clean new tire, not a worn or dirty tire. Preserve rim design and vehicle stance. Show tread only where visible.',
        'Tire 4',
        imagePath: 'assets/images/mod_tire_4.jpg',
      ),
      CarModOption(
        'tire.road',
        'Yol Lastiği',
        'Use clean road tires with longitudinal drainage channels and shallow tread blocks. Preserve wheel dimensions, rim design and vehicle stance. Do not add labels or text.',
        'Tire 5',
        imagePath: 'assets/images/mod_tire_5.jpg',
      ),
    ],
  };

  static CarModOption? find(String group, Object? value) {
    if (value is! String) return null;
    for (final item in groups[group] ?? const <CarModOption>[]) {
      if (item.id == value) return item;
    }
    return null;
  }

  static String restoreId(String group, Object? value) {
    if (value is! String || value.isEmpty) return '';
    final current = find(group, value);
    if (current != null) return current.id;
    // Old neon photos did not represent a unique color: require re-selection.
    if (group == 'Neons') return '';
    for (final item in groups[group] ?? const <CarModOption>[]) {
      if (item.legacyName == value) return item.id;
    }
    return '';
  }
}
