import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/product/catalog/ai_video_items.dart';
import 'package:perasoft_staj/product/catalog/explore_items.dart';
import 'package:perasoft_staj/product/validation/explore_validation_messages.dart';
import 'package:perasoft_staj/product/validation/explore_validator.dart';

void main() {
  const validator = ExploreValidator();

  test('Original warning text and punctuation are preserved', () {
    expect(ExploreValidationMessages.image, 'Lütfen önce bir görsel seçin');
    expect(
      ExploreValidationMessages.targetImage,
      'Lütfen önce bir hedef görsel seçin',
    );
    expect(ExploreValidationMessages.color, 'Lütfen önce bir renk seçin');
    expect(
      ExploreValidationMessages.cloneImage,
      'Please upload your car image or select inspire image first',
    );
    expect(
      ExploreValidationMessages.referenceImage,
      'Please upload the reference image.',
    );
  });

  for (final rule in ExploreValidationRule.values) {
    for (final hasImage in [false, true]) {
      for (final hasOption in [false, true]) {
        for (final hasReference in [false, true]) {
          test('$rule image=$hasImage option=$hasOption ref=$hasReference', () {
            final expected = !hasImage
                ? rule == ExploreValidationRule.clone
                      ? ExploreValidationMessages.cloneImage
                      : ExploreValidationMessages.image
                : switch (rule) {
                    ExploreValidationRule.imageOnly => null,
                    ExploreValidationRule.targetImage =>
                      hasOption ? null : ExploreValidationMessages.targetImage,
                    ExploreValidationRule.color =>
                      hasOption ? null : ExploreValidationMessages.color,
                    ExploreValidationRule.clone =>
                      hasReference
                          ? null
                          : ExploreValidationMessages.referenceImage,
                  };
            expect(
              validator.validate(
                rule,
                image: hasImage ? 'vehicle' : '',
                option: hasOption ? 'option' : '',
                referenceImage: hasReference ? 'reference' : '',
              ),
              expected,
            );
          });
        }
      }
    }
    test('$rule whitespace is empty, without changing input', () {
      expect(
        validator.validate(
          rule,
          image: ' \n\t ',
          option: 'choice',
          referenceImage: 'reference',
        ),
        rule == ExploreValidationRule.clone
            ? ExploreValidationMessages.cloneImage
            : ExploreValidationMessages.image,
      );
      expect(
        validator.validate(
          rule,
          image: ' vehicle ',
          option: ' \n\t ',
          referenceImage: ' \n\t ',
        ),
        switch (rule) {
          ExploreValidationRule.imageOnly => null,
          ExploreValidationRule.targetImage =>
            ExploreValidationMessages.targetImage,
          ExploreValidationRule.color => ExploreValidationMessages.color,
          ExploreValidationRule.clone =>
            ExploreValidationMessages.referenceImage,
        },
      );
    });
  }

  test(
    'All Car Mods share target-image validation except Change Color; Clone stays separate',
    () {
      for (final title in ExploreItems.carMods) {
        expect(
          ExploreValidator.ruleFor(
            title: title,
            isCarMod: true,
            isVideo: false,
          ),
          switch (title) {
            'Change Color' => ExploreValidationRule.color,
            _ => ExploreValidationRule.targetImage,
          },
          reason: title,
        );
      }
      for (final title in [
        ...ExploreItems.styleBuilder,
        ...ExploreItems.wallpaperMaker,
        ...ExploreItems.aiEdits,
      ]) {
        expect(
          ExploreValidator.ruleFor(
            title: title,
            isCarMod: false,
            isVideo: false,
          ),
          title == 'Clone Car Style'
              ? ExploreValidationRule.clone
              : ExploreValidationRule.imageOnly,
          reason: title,
        );
      }
      for (final title in [
        ...AiVideoItems.transformations,
        ...AiVideoItems.driveScenes,
        ...AiVideoItems.filters,
        'Clone Car Style',
      ]) {
        expect(
          ExploreValidator.ruleFor(
            title: title,
            isCarMod: false,
            isVideo: true,
          ),
          ExploreValidationRule.imageOnly,
          reason: title,
        );
      }
      expect(
        ExploreValidator.ruleFor(
          title: 'Unknown Car Mod',
          isCarMod: true,
          isVideo: false,
        ),
        ExploreValidationRule.targetImage,
      );
    },
  );
}
