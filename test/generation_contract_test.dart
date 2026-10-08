import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/catalog/generate_option_catalog.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/ai_video_template.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/model/generation_plan.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/fake_generation_service.dart';
import 'package:perasoft_staj/product/service/generation/generation_input_resolver.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';

const _resolver = GenerationInputResolver();
const _vehicle = 'porsche_911';

Matcher invalidField(String field) => throwsA(
  isA<GenerationInputException>().having((e) => e.field, 'field', field),
);

void main() {
  test(
    'Every existing choice has an explicit ID, never a label-derived ID',
    () {
      expect(
        GenerateOptionCatalog.styleIds.keys,
        orderedEquals(GenerateOptionCatalog.styles),
      );
      expect(
        GenerateOptionCatalog.extraIds.keys,
        orderedEquals(GenerateOptionCatalog.extras),
      );
      expect(
        GenerateOptionCatalog.angleIds.keys,
        orderedEquals(DetailPartCatalog.byAngle.keys),
      );
      expect(
        GenerateOptionCatalog.colorIds.keys,
        orderedEquals(GenerateOptionCatalog.baseColors.keys),
      );
      expect(
        GenerateOptionCatalog.colorCategoryIds.keys,
        orderedEquals(GenerateOptionCatalog.colorCategories),
      );
      final ids = [
        ...GenerateOptionCatalog.styleIds.values,
        ...GenerateOptionCatalog.extraIds.values,
        ...GenerateOptionCatalog.angleIds.values,
        for (final category in DetailPartCatalog.all)
          for (final part in category.options) part.id,
      ];
      expect(ids.toSet(), hasLength(ids.length));
      expect(DetailPartCatalog.spoiler.options[0].id, 'spoiler.race_wing');
      expect(DetailPartCatalog.exhaust.options[2].id, 'exhaust.quad_metal');
      for (final category in DetailPartCatalog.all) {
        for (final part in category.options) {
          expect(File(part.assetPath).existsSync(), isTrue, reason: part.id);
        }
      }
    },
  );

  for (final vehicle in VehicleCatalog.all) {
    test(
      '${vehicle.id}: source is a resolvable local asset, not an upload URL',
      () {
        final request = GenerationRequest(
          mode: GenerateMode.customEdit,
          vehicleId: vehicle.id,
          description: 'Yeni jant',
        );
        final plan = _resolver.resolve(request);
        expect(plan.request, same(request));
        expect(
          plan.vehicle,
          GenerationAsset(id: vehicle.id, assetPath: vehicle.imagePath),
        );
        expect(File(plan.vehicle.assetPath).existsSync(), isTrue);
        expect(plan.expectedMedia, GenerationMediaKind.image);
        expect(plan.parts, isEmpty);
      },
    );
  }

  for (final style in GenerateOptionCatalog.styles) {
    test(
      'Style $style keeps its identity without requiring optional extras',
      () {
        final plan = _resolver.resolve(
          GenerationRequest(
            mode: GenerateMode.styleBuilder,
            vehicleId: _vehicle,
            style: style,
          ),
        );
        expect(plan.styleId, GenerateOptionCatalog.styleIds[style]);
        expect(plan.extraId, isNull);
        expect(plan.color, isNull);
      },
    );
  }
  for (final extra in GenerateOptionCatalog.extras) {
    test('Extra $extra keeps its identity without requiring a style', () {
      final plan = _resolver.resolve(
        GenerationRequest(
          mode: GenerateMode.styleBuilder,
          vehicleId: _vehicle,
          extra: extra,
        ),
      );
      expect(plan.extraId, GenerateOptionCatalog.extraIds[extra]);
      expect(plan.styleId, isNull);
    });
  }

  for (
    var category = 0;
    category < GenerateOptionCatalog.colorCategories.length;
    category++
  ) {
    for (final entry in GenerateOptionCatalog.baseColors.entries) {
      final title = GenerateOptionCatalog.colorTitle(entry.key, category);
      test(
        '$title: identical color meaning across Generate, Detail and Explore',
        () {
          final requests = <GenerationInput>[
            GenerationRequest(
              mode: GenerateMode.styleBuilder,
              vehicleId: _vehicle,
              color: title,
            ),
            GenerationRequest(
              mode: GenerateMode.detailEdit,
              vehicleId: _vehicle,
              angle: 'Rear',
              color: title,
            ),
            ExploreGenerationRequest(
              operation: ExploreOperation.changeColor,
              vehicleId: _vehicle,
              color: title,
            ),
          ];
          final colors = requests
              .map((e) => _resolver.resolve(e).color!)
              .toList();
          expect(colors[0], colors[1]);
          expect(colors[1], colors[2]);
          expect(colors[0].argb, entry.value);
          final categoryId =
              GenerateOptionCatalog.colorCategoryIds[GenerateOptionCatalog
                  .colorCategories[category]];
          expect(colors[0].categoryId, categoryId);
          expect(
            colors[0].id,
            'color.$categoryId.${GenerateOptionCatalog.colorIds[entry.key]}',
          );
        },
      );
    }
  }

  for (final angle in DetailPartCatalog.byAngle.keys) {
    test(
      '$angle: every allowed part/index resolves without changing cache',
      () {
        for (final category in DetailPartCatalog.forAngle(angle)) {
          for (var index = 0; index < category.options.length; index++) {
            final saved = GenerateSelection(
              vehicleId: _vehicle,
              angle: angle,
              parts: {category.title: index},
            );
            final before = saved.toJson();
            final restored = GenerateSelection.fromJson(before);
            final plan = _resolver.resolve(
              GenerationRequest(
                mode: GenerateMode.detailEdit,
                vehicleId: restored.vehicleId,
                angle: restored.angle,
                parts: restored.parts,
              ),
            );
            expect(plan.angleId, GenerateOptionCatalog.angleIds[angle]);
            expect(plan.parts.single.id, category.options[index].id);
            expect(
              plan.parts.single.reference.assetPath,
              category.images[index],
            );
            expect(plan.parts.single.instruction, isNull);
            expect(saved.toJson(), before);
            expect(restored.toJson(), before);
          }
        }
        // Angle-only remains a valid product behavior.
        final plan = _resolver.resolve(
          GenerationRequest(
            mode: GenerateMode.detailEdit,
            vehicleId: _vehicle,
            angle: angle,
          ),
        );
        expect(plan.parts, isEmpty);
        expect(plan.color, isNull);
      },
    );
  }

  test(
    'Every wrong-angle category is rejected, not dropped or substituted',
    () {
      for (final angle in DetailPartCatalog.byAngle.keys) {
        final allowed = DetailPartCatalog.forAngle(angle);
        for (final category in DetailPartCatalog.all.where(
          (e) => !allowed.contains(e),
        )) {
          expect(
            () => _resolver.resolve(
              GenerationRequest(
                mode: GenerateMode.detailEdit,
                vehicleId: _vehicle,
                angle: angle,
                parts: {category.title: 0},
              ),
            ),
            invalidField('parts'),
          );
        }
      }
    },
  );

  test('Part order and snapshots are immutable; index bounds are checked', () {
    final parts = {'Exhaust': 2, 'Spoiler': 0};
    final request = GenerationRequest(
      mode: GenerateMode.detailEdit,
      vehicleId: _vehicle,
      angle: 'Rear',
      parts: parts,
    );
    final plan = _resolver.resolve(request);
    parts.clear();
    expect(plan.parts.map((e) => e.id), [
      'exhaust.quad_metal',
      'spoiler.race_wing',
    ]);
    expect(() => plan.parts.clear(), throwsUnsupportedError);
    expect(() => request.parts.clear(), throwsUnsupportedError);
    final copy = plan.parts.toList();
    final detached = GenerationPlan(
      request: request,
      vehicle: plan.vehicle,
      expectedMedia: plan.expectedMedia,
      parts: copy,
    );
    copy.clear();
    expect(detached.parts, hasLength(2));
    for (final index in [-1, DetailPartCatalog.spoiler.options.length]) {
      expect(
        () => _resolver.resolve(
          GenerationRequest(
            mode: GenerateMode.detailEdit,
            vehicleId: _vehicle,
            angle: 'Rear',
            parts: {'Spoiler': index},
          ),
        ),
        invalidField('parts'),
      );
    }
  });

  for (final operation in ExploreOperation.values) {
    test('Explore ${operation.name}: only its active inputs are resolved', () {
      final option = CarModCatalog.groups[operation.title]?.first;
      final reference = ReferenceCarCatalog.items.first;
      final request = ExploreGenerationRequest(
        operation: operation,
        vehicleId: _vehicle,
        optionId: option?.id ?? 'inactive invalid option',
        color: operation.input == ExploreInput.color
            ? 'Özel Mor'
            : 'inactive invalid color',
        referenceId: operation.input == ExploreInput.reference
            ? reference.id
            : 'inactive invalid reference',
      );
      final plan = _resolver.resolve(request);
      expect(plan.request, same(request));
      expect(plan.expectedMedia, GenerationMediaKind.image);
      if (operation.input == ExploreInput.option) {
        expect(plan.option!.id, option!.id);
        expect(plan.option!.instruction, option.instruction);
        expect(plan.option!.reference.assetPath, option.imagePath);
      } else {
        expect(plan.option, isNull);
      }
      expect(plan.color != null, operation.input == ExploreInput.color);
      expect(plan.reference != null, operation.input == ExploreInput.reference);
      if (plan.reference != null) {
        expect(plan.reference!.id, reference.id);
        expect(plan.reference!.assetPath, reference.imagePath);
        expect(plan.reference, isNot(plan.vehicle));
      }
      expect(plan.parts, isEmpty);
    });
  }

  test('Every Explore option keeps its existing reference and instruction', () {
    for (final operation in ExploreOperation.values.where(
      (e) => e.input == ExploreInput.option,
    )) {
      for (final option in CarModCatalog.groups[operation.title]!) {
        final plan = _resolver.resolve(
          ExploreGenerationRequest(
            operation: operation,
            vehicleId: _vehicle,
            optionId: option.id,
          ),
        );
        expect(plan.option!.id, option.id);
        expect(plan.option!.instruction, option.instruction);
        expect(plan.option!.reference.assetPath, option.imagePath);
      }
    }
    for (final reference in ReferenceCarCatalog.items) {
      final plan = _resolver.resolve(
        ExploreGenerationRequest(
          operation: ExploreOperation.cloneCarStyle,
          vehicleId: _vehicle,
          referenceId: reference.id,
        ),
      );
      expect(plan.reference!.assetPath, reference.imagePath);
    }
  });

  for (final template in AiVideoTemplate.values) {
    test(
      '${template.name}: video intent is never mistaken for demo image output',
      () async {
        final request = AiVideoGenerationRequest(
          template: template,
          vehicleId: _vehicle,
        );
        final plan = _resolver.resolve(request);
        expect(plan.expectedMedia, GenerationMediaKind.video);
        expect(plan.request, same(request));
        expect(plan.option, isNull);
        expect(plan.reference, isNull);
        final result = await FakeGenerationService(
          delay: Duration.zero,
        ).generate(request);
        expect(result, isA<DemoGenerationResult>());
        expect(result.mediaKind, GenerationMediaKind.image);
        expect(result.originalImagePath, plan.vehicle.assetPath);
      },
    );
  }

  test('Inactive Generate fields never become edits in another mode', () {
    final custom = GenerationRequest(
      mode: GenerateMode.customEdit,
      vehicleId: _vehicle,
      description: '  Jant değişsin\nArka plan kalsın  ',
      style: 'invalid',
      extra: 'invalid',
      color: 'invalid',
      angle: 'invalid',
      parts: {'invalid': -1},
    );
    final plan = _resolver.resolve(custom);
    expect(plan.request, same(custom));
    expect((plan.request as GenerationRequest).description, custom.description);
    expect([
      plan.styleId,
      plan.extraId,
      plan.angleId,
      plan.color,
      plan.option,
      plan.reference,
    ], everyElement(isNull));
    expect(plan.parts, isEmpty);
    final style = _resolver.resolve(
      GenerationRequest(
        mode: GenerateMode.styleBuilder,
        vehicleId: _vehicle,
        color: 'Mavi',
        angle: 'invalid',
        parts: {'invalid': -1},
      ),
    );
    expect(style.parts, isEmpty);
    expect(style.angleId, isNull);
    final detail = _resolver.resolve(
      GenerationRequest(
        mode: GenerateMode.detailEdit,
        vehicleId: _vehicle,
        angle: 'Front',
        style: 'invalid',
        extra: 'invalid',
      ),
    );
    expect(detail.styleId, isNull);
    expect(detail.extraId, isNull);
  });

  test('Invalid active fields fail explicitly without invented fallbacks', () {
    final invalid = <(GenerationInput, String)>[
      (
        GenerationRequest(
          mode: GenerateMode.styleBuilder,
          vehicleId: 'unknown',
          color: 'Mavi',
        ),
        'vehicleId',
      ),
      (
        GenerationRequest(mode: GenerateMode.styleBuilder, vehicleId: _vehicle),
        'styleChoice',
      ),
      (
        GenerationRequest(
          mode: GenerateMode.styleBuilder,
          vehicleId: _vehicle,
          style: 'unknown',
        ),
        'style',
      ),
      (
        GenerationRequest(
          mode: GenerateMode.styleBuilder,
          vehicleId: _vehicle,
          extra: 'unknown',
        ),
        'extra',
      ),
      (
        GenerationRequest(
          mode: GenerateMode.styleBuilder,
          vehicleId: _vehicle,
          color: 'unknown',
        ),
        'color',
      ),
      (
        GenerationRequest(
          mode: GenerateMode.customEdit,
          vehicleId: _vehicle,
          description: ' \n ',
        ),
        'description',
      ),
      (
        GenerationRequest(
          mode: GenerateMode.detailEdit,
          vehicleId: _vehicle,
          angle: 'unknown',
        ),
        'angle',
      ),
      (
        const ExploreGenerationRequest(
          operation: ExploreOperation.changeColor,
          vehicleId: _vehicle,
        ),
        'color',
      ),
      (
        const ExploreGenerationRequest(
          operation: ExploreOperation.customizeRims,
          vehicleId: _vehicle,
          optionId: 'tint.dark',
        ),
        'optionId',
      ),
      (
        const ExploreGenerationRequest(
          operation: ExploreOperation.cloneCarStyle,
          vehicleId: _vehicle,
          referenceId: _vehicle,
        ),
        'referenceId',
      ),
    ];
    for (final (request, field) in invalid) {
      expect(() => _resolver.resolve(request), invalidField(field));
    }
  });

  test(
    'Invalid service input does not consume fail-first; retry keeps snapshot',
    () async {
      final service = FakeGenerationService(
        delay: Duration.zero,
        failuresBeforeSuccess: 1,
      );
      final invalid = GenerationRequest(
        mode: GenerateMode.detailEdit,
        vehicleId: _vehicle,
        angle: 'Rear',
        parts: {'Hood': 0},
      );
      final valid = GenerationRequest(
        mode: GenerateMode.detailEdit,
        vehicleId: _vehicle,
        angle: 'Rear',
        parts: {'Spoiler': 0},
      );
      Matcher fails(GenerationFailureKind kind) => throwsA(
        isA<GenerationException>().having((e) => e.kind, 'kind', kind),
      );
      await expectLater(
        service.generate(invalid),
        fails(GenerationFailureKind.unavailable),
      );
      await expectLater(
        service.generate(valid),
        fails(GenerationFailureKind.demo),
      );
      final result = await service.generate(valid);
      expect(result.request, same(valid));
      expect(result, isA<DemoGenerationResult>());
    },
  );

  test('Resolved values include all semantic fields in equality', () {
    final request = GenerationRequest(
      mode: GenerateMode.detailEdit,
      vehicleId: _vehicle,
      angle: 'Rear',
      parts: {'Spoiler': 0},
    );
    final first = _resolver.resolve(request);
    expect(first, _resolver.resolve(request));
    expect(
      first,
      isNot(
        GenerationPlan(
          request: request,
          vehicle: first.vehicle,
          expectedMedia: GenerationMediaKind.video,
        ),
      ),
    );
    expect(
      const GenerationAsset(id: 'a', assetPath: 'one'),
      isNot(const GenerationAsset(id: 'a', assetPath: 'two')),
    );
    expect(
      const GenerationColor(id: 'a', categoryId: 'matte', argb: 1),
      isNot(const GenerationColor(id: 'a', categoryId: 'matte', argb: 2)),
    );
    final ref = first.parts.single.reference;
    expect(
      GenerationPart(reference: ref, instruction: 'one'),
      isNot(GenerationPart(reference: ref, instruction: 'two')),
    );
  });
}
