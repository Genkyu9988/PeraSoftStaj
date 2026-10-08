import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/catalog/generate_option_catalog.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/model/generation_plan.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';

/// A malformed local selection, not a network/provider failure.
final class GenerationInputException implements Exception {
  const GenerationInputException(this.field);
  final String field;
}

/// Resolves existing UI/cache values without mutating or serializing them.
/// No BuildContext, file upload, network client or provider prompt belongs here.
final class GenerationInputResolver {
  const GenerationInputResolver();

  GenerationPlan resolve(GenerationInput request) {
    final vehicle = VehicleCatalog.find(request.vehicleId);
    if (vehicle == null) throw const GenerationInputException('vehicleId');
    final source = GenerationAsset(
      id: vehicle.id,
      assetPath: vehicle.imagePath,
    );
    return switch (request) {
      GenerationRequest input => _generate(input, source),
      ExploreGenerationRequest input => _explore(input, source),
      AiVideoGenerationRequest input => GenerationPlan(
        request: input,
        vehicle: source,
        expectedMedia: GenerationMediaKind.video,
      ),
    };
  }

  GenerationPlan _generate(GenerationRequest request, GenerationAsset vehicle) {
    switch (request.mode) {
      case GenerateMode.styleBuilder:
        final style = _choice(
          request.style,
          GenerateOptionCatalog.styleIds,
          'style',
        );
        final extra = _choice(
          request.extra,
          GenerateOptionCatalog.extraIds,
          'extra',
        );
        final color = _color(request.color);
        if (style == null && extra == null && color == null) {
          throw const GenerationInputException('styleChoice');
        }
        return GenerationPlan(
          request: request,
          vehicle: vehicle,
          expectedMedia: GenerationMediaKind.image,
          styleId: style,
          extraId: extra,
          color: color,
        );
      case GenerateMode.customEdit:
        if (request.description.trim().isEmpty) {
          throw const GenerationInputException('description');
        }
        return GenerationPlan(
          request: request,
          vehicle: vehicle,
          expectedMedia: GenerationMediaKind.image,
        );
      case GenerateMode.detailEdit:
        final angle = GenerateOptionCatalog.angleIds[request.angle];
        if (angle == null) throw const GenerationInputException('angle');
        final allowed = {
          for (final category in DetailPartCatalog.forAngle(request.angle))
            category.title: category,
        };
        final parts = <GenerationPart>[];
        for (final entry in request.parts.entries) {
          final category = allowed[entry.key];
          if (category == null ||
              entry.value < 0 ||
              entry.value >= category.options.length) {
            // Never silently lose a requested edit or substitute another part.
            throw const GenerationInputException('parts');
          }
          parts.add(GenerationPart(reference: category.options[entry.value]));
        }
        return GenerationPlan(
          request: request,
          vehicle: vehicle,
          expectedMedia: GenerationMediaKind.image,
          angleId: angle,
          parts: parts,
          color: _color(request.color),
        );
    }
  }

  GenerationPlan _explore(
    ExploreGenerationRequest request,
    GenerationAsset vehicle,
  ) {
    GenerationPart? option;
    GenerationColor? color;
    GenerationAsset? reference;
    switch (request.operation.input) {
      case ExploreInput.image:
        break;
      case ExploreInput.option:
        final selected = CarModCatalog.find(
          request.operation.title,
          request.optionId,
        );
        if (selected == null) throw const GenerationInputException('optionId');
        option = GenerationPart(
          reference: GenerationAsset(
            id: selected.id,
            assetPath: selected.imagePath,
          ),
          instruction: selected.instruction,
        );
      case ExploreInput.color:
        color = _color(request.color);
        if (color == null) throw const GenerationInputException('color');
      case ExploreInput.reference:
        final selected = ReferenceCarCatalog.find(request.referenceId);
        if (selected == null) {
          throw const GenerationInputException('referenceId');
        }
        reference = GenerationAsset(
          id: selected.id,
          assetPath: selected.imagePath,
        );
    }
    return GenerationPlan(
      request: request,
      vehicle: vehicle,
      expectedMedia: GenerationMediaKind.image,
      option: option,
      color: color,
      reference: reference,
    );
  }

  String? _choice(String value, Map<String, String> choices, String field) {
    if (value.isEmpty) return null;
    return choices[value] ?? (throw GenerationInputException(field));
  }

  GenerationColor? _color(String title) {
    if (title.isEmpty) return null;
    for (
      var index = 0;
      index < GenerateOptionCatalog.colorCategories.length;
      index++
    ) {
      for (final entry in GenerateOptionCatalog.baseColors.entries) {
        if (GenerateOptionCatalog.colorTitle(entry.key, index) != title) {
          continue;
        }
        final category = GenerateOptionCatalog
            .colorCategoryIds[GenerateOptionCatalog.colorCategories[index]]!;
        return GenerationColor(
          id: 'color.$category.${GenerateOptionCatalog.colorIds[entry.key]!}',
          categoryId: category,
          argb: entry.value,
        );
      }
    }
    throw const GenerationInputException('color');
  }
}
