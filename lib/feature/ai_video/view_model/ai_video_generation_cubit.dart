import 'dart:async';
import 'package:perasoft_staj/feature/editor/view_model/editor_generation_cubit.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/ai_video_template.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/validation/explore_validator.dart';

/// Only video submission rules; the shared flow owns retries and cancellation.
final class AiVideoGenerationCubit extends EditorGenerationCubit {
  AiVideoGenerationCubit({
    required super.generationService,
    super.generationTimeout,
    super.onCompleted,
    ExploreValidator validator = const ExploreValidator(),
  }) : _validator = validator;

  final ExploreValidator _validator;

  @override
  String? submit({required String title, required ExploreSelection selection}) {
    if (isClosed || state.blocksForm) return null;
    final template = AiVideoTemplate.fromTitle(title);
    if (template == null) return 'Bu video şablonu şu anda kullanılamıyor.';
    final vehicleId = VehicleCatalog.restoreId(selection.image);
    final error = _validator.validate(
      ExploreValidationRule.imageOnly,
      image: vehicleId,
    );
    if (error != null) return error;
    unawaited(
      startGeneration(
        AiVideoGenerationRequest(template: template, vehicleId: vehicleId),
      ),
    );
    return null;
  }
}
