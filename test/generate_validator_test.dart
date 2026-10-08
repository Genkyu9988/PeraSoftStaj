import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/product/validation/form_validator.dart';
import 'package:perasoft_staj/product/validation/generate_validation_messages.dart';
import 'package:perasoft_staj/product/validation/generate_validator.dart';

void main() {
  const validator = GenerateValidator();

  test('Uyarılar orijinal ekranlardaki metinleri kullanır', () {
    expect(
      GenerateValidationMessages.vehicle,
      'Araç Fotoğrafı Yüklemek İçin Dokunun',
    );
    expect(
      GenerateValidationMessages.styleChoice,
      'Lütfen en az bir stil, ayar veya renk seçin.',
    );
    expect(GenerateValidationMessages.angle, 'Önce lütfen bir açı seçin.');
    expect(GenerateValidationMessages.description, 'Lütfen bir metin girin');
  });

  for (final vehicle in ['', 'mustang_classic']) {
    // Üç seçimin sekiz kombinasyonu: hepsi değil, herhangi biri yeterli.
    for (var mask = 0; mask < 8; mask++) {
      test('Style: vehicle=$vehicle, style/extra/color mask=$mask', () {
        expect(
          validator.styleBuilder(
            vehicleId: vehicle,
            style: mask & 1 != 0 ? 'Klasik' : '',
            extra: mask & 2 != 0 ? 'Jant' : '',
            color: mask & 4 != 0 ? 'Mavi' : '',
          ),
          vehicle.isEmpty
              ? GenerateValidationMessages.vehicle
              : mask == 0
              ? GenerateValidationMessages.styleChoice
              : null,
        );
      });
    }
    for (final angle in ['', 'Front', 'Rear', 'Side']) {
      test('Detail: vehicle=$vehicle, angle=$angle', () {
        expect(
          validator.detailEdit(vehicleId: vehicle, angle: angle),
          vehicle.isEmpty
              ? GenerateValidationMessages.vehicle
              : angle.isEmpty
              ? GenerateValidationMessages.angle
              : null,
        );
      });
    }
    for (final text in [null, '', '   ', '\n\t', '  Mat siyah\nYeni jant  ']) {
      test('Custom: vehicle=$vehicle, text=${text.runtimeType}:$text', () {
        expect(
          validator.customEdit(vehicleId: vehicle, description: text),
          vehicle.isEmpty
              ? GenerateValidationMessages.vehicle
              : (text == null || text.trim().isEmpty)
              ? GenerateValidationMessages.description
              : null,
        );
      });
    }
  }
  test('Panel kontrolü yalnızca açı ister; araçtan bağımsızdır', () {
    for (final angle in ['', ' \n\t ']) {
      expect(
        validator.detailOptions(angle: angle),
        GenerateValidationMessages.angle,
      );
    }
    for (final angle in ['Front', 'Rear', 'Side']) {
      expect(validator.detailOptions(angle: angle), isNull);
    }
  });
  test('Boşluklardan oluşan girdiler gerçek seçim sayılmaz', () {
    expect(
      validator.styleBuilder(
        vehicleId: ' ',
        style: 'Klasik',
        extra: '',
        color: '',
      ),
      GenerateValidationMessages.vehicle,
    );
    expect(
      validator.styleBuilder(
        vehicleId: 'mustang_classic',
        style: ' ',
        extra: '\n',
        color: '\t',
      ),
      GenerateValidationMessages.styleChoice,
    );
    expect(
      validator.detailEdit(vehicleId: 'mustang_classic', angle: ' '),
      GenerateValidationMessages.angle,
    );
  });
  test('Mevcut metin doğrulayıcısı aynı merkezi mesajı kullanır', () {
    const formValidator = FormValidator();
    for (final value in [null, '', '   ', '\n\t']) {
      expect(
        formValidator.description(value),
        GenerateValidationMessages.description,
      );
    }
    expect(
      formValidator.description('  Mat siyah tasarım\nYeni jant  '),
      isNull,
    );
  });
}
