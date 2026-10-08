import 'package:perasoft_staj/product/validation/form_validator.dart';
import 'package:perasoft_staj/product/validation/generate_validation_messages.dart';

// Yalnızca onaylı girdileri kontrol eder; UI, cache ve seçim state'ini değiştirmez.
// null: geçerli. Mesaj: öncelik sırasındaki ilk eksik bilgi.
class GenerateValidator {
  const GenerateValidator();

  String? styleBuilder({
    required String vehicleId,
    required String style,
    required String extra,
    required String color,
  }) {
    final vehicleError = _vehicle(vehicleId);
    if (vehicleError != null) return vehicleError;
    if (style.trim().isEmpty && extra.trim().isEmpty && color.trim().isEmpty) {
      return GenerateValidationMessages.styleChoice;
    }
    return null;
  }

  // Parça ve renk opsiyoneldir; üretim doğrulamasına dahil edilmez.
  String? detailEdit({required String vehicleId, required String angle}) =>
      _vehicle(vehicleId) ?? detailOptions(angle: angle);

  String? customEdit({
    required String vehicleId,
    required String? description,
  }) => _vehicle(vehicleId) ?? const FormValidator().description(description);

  // Ayarla/Renk açılışı için araç gerekmez; onaylı açı yeterlidir.
  String? detailOptions({required String angle}) =>
      angle.trim().isEmpty ? GenerateValidationMessages.angle : null;

  String? _vehicle(String vehicleId) =>
      vehicleId.trim().isEmpty ? GenerateValidationMessages.vehicle : null;
}
