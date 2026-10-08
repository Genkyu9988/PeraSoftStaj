// Shared presentation contract, not a generation request model.
abstract interface class ImageChoice {
  String get id;
  String get label;
  String get imagePath;
}
