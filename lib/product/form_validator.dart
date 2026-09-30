class FormValidator {
  const FormValidator();

  String? description(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lütfen yapmak istediğiniz değişikliği yazın.';
    }
    return null;
  }
}
