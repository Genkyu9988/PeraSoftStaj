import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';

class ExploreSelection {
  const ExploreSelection({
    this.image = '',
    this.option = '',
    this.colorCategory = 0,
    this.referenceImage = '',
  });
  final String image;
  final String option;
  final int colorCategory;
  final String referenceImage;

  Map<String, dynamic> toJson() => {
    'image': image,
    'option': option,
    'colorCategory': colorCategory,
    'referenceImage': referenceImage,
  };

  factory ExploreSelection.fromJson(
    Map<String, dynamic> json,
    String title, {
    bool isVideo = false,
  }) {
    final image = VehicleCatalog.restoreId(json['image']);
    final option = isVideo
        ? ''
        : title == 'Change Color'
        ? readColor(json['option'])
        : CarModCatalog.restoreId(title, json['option']);
    return ExploreSelection(
      image: image,
      option: option,
      colorCategory: colorCategoryOf(option),
      referenceImage: !isVideo && title == 'Clone Car Style'
          ? ReferenceCarCatalog.restoreId(json['referenceImage'])
          : '',
    );
  }
}
