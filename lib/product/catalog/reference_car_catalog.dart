import 'package:perasoft_staj/product/model/image_choice.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';

class ReferenceCar implements ImageChoice {
  const ReferenceCar(this.id, this.label, this.imagePath);

  @override
  final String id;
  @override
  final String label;
  @override
  final String imagePath;
}

// Reference photos describe a style, not the target vehicle's identity.
class ReferenceCarCatalog {
  static const items = [
    ReferenceCar('reference.wide_body', 'Geniş Gövde', ImageItems.bodyWide),
    ReferenceCar('reference.racing', 'Yarış Görünümü', ImageItems.race),
    ReferenceCar(
      'reference.leaf_wrap',
      'Desenli Kaplama',
      ImageItems.stickerLeaves,
    ),
    ReferenceCar(
      'reference.red_underglow',
      'Kırmızı Alt Aydınlatma',
      ImageItems.referenceRedUnderglow,
    ),
  ];

  static ReferenceCar? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static String restoreId(Object? value) =>
      value is String && find(value) != null ? value : '';
}
