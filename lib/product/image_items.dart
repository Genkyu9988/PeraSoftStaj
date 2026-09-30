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

  static const sampleCars = [classic, sport, offRoad, suv, city];

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
}
