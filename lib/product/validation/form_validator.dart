import 'package:perasoft_staj/product/validation/generate_validation_messages.dart';

class FormValidator {
  const FormValidator();

  String? description(String? value) {
    if (value == null || value.trim().isEmpty) {
      return GenerateValidationMessages.description;
    }
    return null;
  }
}
