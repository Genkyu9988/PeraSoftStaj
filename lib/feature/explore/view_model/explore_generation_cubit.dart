import 'dart:async';
import 'package:perasoft_staj/feature/editor/view_model/editor_generation_cubit.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/validation/explore_validator.dart';

/// Production only: selection sheets and persistence keep their current owner.
final class ExploreGenerationCubit extends EditorGenerationCubit {
  ExploreGenerationCubit({
    required super.generationService,
    super.generationTimeout,
    super.onCompleted,
    ExploreValidator validator = const ExploreValidator(),
  }) : _validator = validator;
  final ExploreValidator _validator;

  /// Synchronous validation feedback; valid requests start once.
  @override
  String? submit({required String title, required ExploreSelection selection}) {
    if (isClosed || state.blocksForm) return null;
    final operation = ExploreOperation.fromTitle(title);
    if (operation == null) return 'Bu işlem şu anda kullanılamıyor.';
    final selected = ExploreSelection.fromJson(selection.toJson(), title);
    final rule = switch (operation.input) {
      ExploreInput.image => ExploreValidationRule.imageOnly,
      ExploreInput.option => ExploreValidationRule.targetImage,
      ExploreInput.color => ExploreValidationRule.color,
      ExploreInput.reference => ExploreValidationRule.clone,
    };
    final error = _validator.validate(
      rule,
      image: selected.image,
      option: selected.option,
      referenceImage: selected.referenceImage,
    );
    if (error != null) return error;
    unawaited(
      startGeneration(
        ExploreGenerationRequest(
          operation: operation,
          vehicleId: selected.image,
          optionId: operation.input == ExploreInput.option
              ? selected.option
              : '',
          color: operation.input == ExploreInput.color ? selected.option : '',
          referenceId: operation.input == ExploreInput.reference
              ? selected.referenceImage
              : '',
        ),
      ),
    );
    return null;
  }
}
