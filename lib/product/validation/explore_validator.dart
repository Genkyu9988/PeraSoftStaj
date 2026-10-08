import 'package:perasoft_staj/product/validation/explore_validation_messages.dart';

enum ExploreValidationRule { imageOnly, targetImage, color, clone }

// Yalnızca onaylı girdiler: UI, context, cache veya seçim değişikliği yok.
class ExploreValidator {
  const ExploreValidator();

  // Diğer Car Mods, kullanıcının onayladığı benzerlik varsayımıyla Neon/Tire
  // kuralını paylaşır. Change Color ve Clone'ın özel mesajları ayrı kalır.
  static ExploreValidationRule ruleFor({
    required String title,
    required bool isCarMod,
    required bool isVideo,
  }) {
    if (isVideo) return ExploreValidationRule.imageOnly;
    if (title == 'Clone Car Style') return ExploreValidationRule.clone;
    if (!isCarMod) return ExploreValidationRule.imageOnly;
    return title == 'Change Color'
        ? ExploreValidationRule.color
        : ExploreValidationRule.targetImage;
  }

  // İlk eksik alanın mesajı; bütün zorunlu girdiler geçerliyse null.
  String? validate(
    ExploreValidationRule rule, {
    required String image,
    String option = '',
    String referenceImage = '',
  }) {
    if (image.trim().isEmpty) {
      return rule == ExploreValidationRule.clone
          ? ExploreValidationMessages.cloneImage
          : ExploreValidationMessages.image;
    }
    return switch (rule) {
      ExploreValidationRule.imageOnly => null,
      ExploreValidationRule.targetImage =>
        option.trim().isEmpty ? ExploreValidationMessages.targetImage : null,
      ExploreValidationRule.color =>
        option.trim().isEmpty ? ExploreValidationMessages.color : null,
      ExploreValidationRule.clone =>
        referenceImage.trim().isEmpty
            ? ExploreValidationMessages.referenceImage
            : null,
    };
  }
}
