// VB10 #4: image paths are kept outside the screen widget.
class ImageItems {
  static const _folder = 'assets/images';
  static const classic = '$_folder/classic.jpg';
  static const sport = '$_folder/sport.jpg';
  static const offRoad = '$_folder/off_road.jpg';
  static const suv = '$_folder/suv.jpg';
  static const race = '$_folder/race.jpg';
  static const city = '$_folder/city.jpg';
  static const credits = 'assets/IMAGE_CREDITS.txt';
  static const referenceRedUnderglow = '$_folder/neon_red_photo.jpg';
  static const spoilerRaceWing = '$_folder/spoiler.jpg';
  static const spoilerSportWing = '$_folder/spoiler_2.jpg';
  static const spoilerRoofLip = '$_folder/spoiler_3.jpg';
  static const audioSubwoofer = '$_folder/mod_audio_subwoofer.jpg';
  static const audioTweeter = '$_folder/mod_audio_door.jpg';
  static const audioShowInstall = '$_folder/explore_audio.jpg';
  static const tintLight = '$_folder/explore_tints.jpg';
  static const tintDark = '$_folder/mod_tint_smoke.jpg';
  static const tintReflective = '$_folder/mod_tint_reflective.jpg';
  static const exhaustSingle = '$_folder/exhaust_1.jpg';
  static const exhaustQuadBlack = '$_folder/exhaust_2.jpg';
  static const exhaustQuadMetal = '$_folder/exhaust_3.jpg';
  static const chromeGrilleBlack = '$_folder/explore_chrome.jpg';
  static const chromeWindowTrimBlack = '$_folder/explore_tints.jpg';
  static const bodySideSkirt = '$_folder/body_kit.jpg';
  static const bodyWide = '$_folder/explore_bodykit.jpg';
  static const bodyRearDiffuser = '$_folder/diffuser_1.jpg';
  static const perspectiveFrontQuarter = '$_folder/angle_front.jpg';
  static const perspectiveRearQuarter = '$_folder/angle_rear.jpg';
  static const perspectiveSide = '$_folder/angle_side.jpg';
  static const mirrorBlack = '$_folder/mod_mirror_classic.jpg';
  static const mirrorCarbon = '$_folder/mod_mirror_carbon.jpg';
  static const roofGlass = '$_folder/mod_roof_open.jpg';
  static const roofShadeClosed = '$_folder/mod_roof_closed.jpg';
  static const roofDual = '$_folder/explore_sunroof.jpg';
  static const stickerRacingStripes = '$_folder/mod_sticker_stripes.jpg';
  static const stickerLeaves = '$_folder/explore_sticker.jpg';
  static const stickerRaceLivery = '$_folder/race.jpg';
  static const upholsteryBlack = '$_folder/explore_upholstery.jpg';
  static const upholsteryTan = '$_folder/mod_seat_brown.jpg';
  static const upholsteryRedBlack = '$_folder/mod_seat_red.jpg';
  static const frontBumperSport = '$_folder/front_bumper_1.jpg';
  static const frontBumperClassic = '$_folder/front_bumper_2.jpg';
  static const frontBumperChrome = '$_folder/front_bumper_3.jpg';
  static const hoodClassic = '$_folder/hood.jpg';
  static const hoodScoop = '$_folder/hood_2.jpg';
  static const hoodCarbonScoop = '$_folder/hood_3.jpg';
  static const headlightModern = '$_folder/headlight_1.jpg';
  static const headlightLed = '$_folder/headlight_2.jpg';
  static const headlightRound = '$_folder/headlight_3.jpg';
  static const diffuserSport = '$_folder/diffuser_2.jpg';
  static const diffuserRace = '$_folder/diffuser_3.jpg';
  static const tailLightClassic = '$_folder/tail_light_1.jpg';
  static const tailLightLed = '$_folder/tail_light_2.jpg';
  static const tailLightRound = '$_folder/tail_light_3.jpg';
  static const rimClassic = '$_folder/rim.jpg';
  static const rimAlloy = '$_folder/mod_rim_2.jpg';
  static const rimSport = '$_folder/mod_rim_3.jpg';
  static const sideSkirtCarbon = '$_folder/side_skirt_2.jpg';
  static const sideSkirtModulo = '$_folder/side_skirt_3.jpg';

  static const catalogBmw525 = '$_folder/mod_suspension_4.jpg';
  static const catalogMustangGt = '$_folder/angle_front.jpg';
  static const catalogMustangBlue = '$_folder/angle_side.jpg';
  static const catalogSkyline = '$_folder/explore_japanese.jpg';
  static const catalogImpala = '$_folder/explore_suspension.jpg';
  static const catalogBuick = '$_folder/mod_suspension_3.jpg';

  // Existing titles are also the saved selection values; do not rename them.
  static const styleOptions = {
    'Klasik': classic,
    'Sportif': sport,
    'Off Road': offRoad,
    'SUV': suv,
    'Yarış': race,
    'Şehir': city,
  };
  static const extraOptions = {
    'Jant': '$_folder/rim.jpg',
    'Spoiler': '$_folder/spoiler.jpg',
    'Boya': '$_folder/paint.jpg',
    'Neon': '$_folder/neon.jpg',
    'Kaput': '$_folder/hood.jpg',
    'Gövde Kiti': '$_folder/body_kit.jpg',
  };

  static const angleOptions = {
    'Front': '$_folder/angle_front.jpg',
    'Rear': '$_folder/angle_rear.jpg',
    'Side': '$_folder/angle_side.jpg',
  };

  // Explore cover images only; detail selections keep their existing content.
  static const exploreCovers = {
    'Change Color': '$_folder/paint.jpg',
    'Customize Rims': '$_folder/rim.jpg',
    'Suspension': '$_folder/explore_suspension.jpg',
    'Neons': '$_folder/neon.jpg',
    'Tire': '$_folder/explore_tire.jpg',
    'Spoiler': '$_folder/spoiler.jpg',
    'Sound System': '$_folder/explore_audio.jpg',
    'Window Tints': '$_folder/explore_tints.jpg',
    'Exhaust': '$_folder/exhaust_1.jpg',
    'Chrome Delete': '$_folder/explore_chrome.jpg',
    'Body Kit': '$_folder/explore_bodykit.jpg',
    'Perspective': '$_folder/explore_perspective.jpg',
    'Mirror Swap': '$_folder/explore_mirror.jpg',
    'Sunroof Mood': '$_folder/explore_sunroof.jpg',
    'Put On Sticker': '$_folder/explore_sticker.jpg',
    'Upholstery': '$_folder/explore_upholstery.jpg',
    'American': classic,
    'Japanese': '$_folder/explore_japanese.jpg',
    'Off Road': offRoad,
    'SUV': suv,
    'Racing': race,
    'Most WT': '$_folder/angle_front.jpg',
    'Countryside': '$_folder/explore_countryside.jpg',
    'Tuner Shop': '$_folder/explore_workshop.jpg',
    'Crystal': '$_folder/explore_crystal.jpg',
    'Night City': '$_folder/explore_night.jpg',
    'Car Enhance': '$_folder/body_kit.jpg',
    'Speed Trap': '$_folder/explore_speed.jpg',
    'Grand City Auto': '$_folder/explore_city.jpg',
    'Dream Car & Me': sport,
    'AI Crash Effect': '$_folder/explore_crash.jpg',
    'AI Car Restore': classic,
    'Mini Toy Car': '$_folder/explore_toy.jpg',
    'Mody AI Technic': '$_folder/explore_technic.jpg',
    '3D Car Figurine': '$_folder/explore_figurine.jpg',
    'Transformers': '$_folder/explore_robot.jpg',
    'Clone Car Style': '$_folder/explore_clone.jpg',
  };

  // Temporary still covers, not frames from generated videos. Reuse bundled
  // photos until scene-specific video previews are available.
  static const aiVideoCovers = {
    'Apex Transform': '$_folder/body_kit.jpg',
    'Pit Stop Transformation': '$_folder/explore_workshop.jpg',
    'Magnetic Transformation': '$_folder/paint.jpg',
    'Neon Transformation': '$_folder/neon_purple_photo.png',
    'Classic Transformation': classic,
    'Cliff Fly': sport,
    'Cliff Drive': '$_folder/explore_countryside.jpg',
    'Snow Drift': race,
    'City Drive': '$_folder/explore_city.jpg',
    'Desert Drive': offRoad,
    'Zoom Out': '$_folder/explore_countryside.jpg',
    'Zoom In': sport,
    'Hydraulic Heatwave': '$_folder/explore_suspension.jpg',
    'Race Video': race,
    'Drift Showdown': '$_folder/explore_japanese.jpg',
  };
}
