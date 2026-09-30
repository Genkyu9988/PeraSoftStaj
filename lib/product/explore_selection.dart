import 'package:perasoft_staj/product/cache/generate_selection.dart';

class ExploreSelection {
  const ExploreSelection({
    this.image = '',
    this.option = '',
    this.colorCategory = 0,
  });
  final String image;
  final String option;
  final int colorCategory;

  Map<String, dynamic> toJson() => {
    'image': image,
    'option': option,
    'colorCategory': colorCategory,
  };

  factory ExploreSelection.fromJson(
    Map<String, dynamic> json,
    String title, {
    bool isVideo = false,
  }) {
    final image = readChoice(json['image'], [
      for (final prefix in ['Mock Araç', 'Mock Üretim', 'Örnek Araç'])
        for (var i = 1; i <= 5; i++) '$prefix $i',
    ]);
    const labels = {
      'Customize Rims': 'Rim',
      'Suspension': 'Suspension',
      'Neons': 'Neon',
      'Tire': 'Tire',
    };
    final label = labels[title];
    final option = isVideo
        ? ''
        : title == 'Change Color'
        ? readColor(json['option'])
        : label == null
        ? ''
        : readChoice(json['option'], [
            for (var i = 1; i <= 5; i++) '$label $i',
          ]);
    return ExploreSelection(
      image: image,
      option: option,
      colorCategory: colorCategoryOf(option),
    );
  }
}
