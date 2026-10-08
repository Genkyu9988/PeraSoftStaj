import 'package:perasoft_staj/feature/generation/view_model/generation_flow_cubit.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generation_activity.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/feature/generate/logic/generate_suggestions.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generate_state.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/validation/generate_validator.dart';

/// Owns Generate choices, not BuildContext, controllers or storage technology.
final class GenerateCubit extends GenerationFlowCubit<GenerateState> {
  GenerateCubit({
    GenerateSelection initialSelection = const GenerateSelection(),
    required GenerateSuggestions suggestions,
    required super.generationService,
    super.generationTimeout,
    GenerateValidator validator = const GenerateValidator(),
    void Function(GenerateSelection)? onApplied,
  }) : _suggestions = suggestions,
       _validator = validator,
       _onApplied = onApplied,
       super(initialState: GenerateState.fromSelection(initialSelection));

  final GenerateSuggestions _suggestions;
  final GenerateValidator _validator;
  final void Function(GenerateSelection)? _onApplied;
  int _feedbackSequence = 0;
  @override
  GenerationActivity get activity => state.generation;

  @override
  void emitActivity(GenerationActivity activity) =>
      emit(state.copyWith(clearFeedback: true, generation: activity));

  void selectVehicle(String id) =>
      _apply(state.copyWith(vehicleId: VehicleCatalog.restoreId(id)));

  void selectStyle(String style) => _apply(state.copyWith(style: style));

  void selectExtra(String extra) => _apply(state.copyWith(extra: extra));

  void selectStyleColor(String color) => _apply(
    state.copyWith(color: color, colorCategory: colorCategoryOf(color)),
  );

  void selectDetailColor(String color) => _apply(
    state.copyWith(
      detailColor: color,
      detailColorCategory: colorCategoryOf(color),
    ),
  );

  void selectAngle(String angle) => _apply(
    state.copyWith(
      angle: angle,
      parts: state.angle == angle ? state.parts : const {},
    ),
  );

  void selectParts(Map<String, int> parts) {
    final allowed = DetailPartCatalog.restoreSelections(state.angle, parts);
    _apply(
      state.copyWith(
        // Keep the user's selection order while rejecting wrong-angle parts.
        parts: {
          for (final part in parts.entries)
            if (allowed[part.key] == part.value) part.key: part.value,
        },
      ),
    );
  }

  void suggestIdea(GenerateMode mode) {
    if (isClosed || state.generation.blocksForm) return;
    switch (mode) {
      case GenerateMode.styleBuilder:
        final idea = _suggestions.styleBuilder();
        _apply(
          state.copyWith(
            vehicleId: idea.vehicleId,
            style: idea.style,
            extra: idea.extra,
            color: idea.color,
            colorCategory: colorCategoryOf(idea.color),
          ),
        );
      case GenerateMode.customEdit:
        selectVehicle(_suggestions.vehicle().id);
      case GenerateMode.detailEdit:
        final idea = _suggestions.detailEdit();
        _apply(
          state.copyWith(
            vehicleId: idea.vehicleId,
            angle: idea.angle,
            // Replace, never merge old-angle parts with the new idea.
            parts: {idea.category.title: idea.partIndex},
            detailColor: idea.color,
            detailColorCategory: colorCategoryOf(idea.color),
          ),
        );
    }
  }

  bool canOpenDetailOptions() {
    if (isClosed || state.generation.blocksForm) return false;
    final error = _validator.detailOptions(angle: state.angle);
    if (error == null) return true;
    _feedback(error, GenerateFeedbackKind.warning);
    return false;
  }

  /// Custom text remains an unsaved UI draft; validate the current snapshot.
  Future<void> submit(GenerateMode mode, {String description = ''}) async {
    if (isClosed || state.generation.blocksForm) return;
    final error = switch (mode) {
      GenerateMode.styleBuilder => _validator.styleBuilder(
        vehicleId: state.vehicleId,
        style: state.style,
        extra: state.extra,
        color: state.color,
      ),
      GenerateMode.customEdit => _validator.customEdit(
        vehicleId: state.vehicleId,
        description: description,
      ),
      GenerateMode.detailEdit => _validator.detailEdit(
        vehicleId: state.vehicleId,
        angle: state.angle,
      ),
    };
    if (error != null) {
      _feedback(error, GenerateFeedbackKind.warning);
      return;
    }
    final request = switch (mode) {
      GenerateMode.styleBuilder => GenerationRequest(
        mode: mode,
        vehicleId: state.vehicleId,
        style: state.style,
        extra: state.extra,
        color: state.color,
      ),
      GenerateMode.customEdit => GenerationRequest(
        mode: mode,
        vehicleId: state.vehicleId,
        description: description.trim(),
      ),
      GenerateMode.detailEdit => GenerationRequest(
        mode: mode,
        vehicleId: state.vehicleId,
        angle: state.angle,
        parts: state.parts,
        color: state.detailColor,
      ),
    };
    await startGeneration(request);
  }

  void _apply(GenerateState next) {
    if (isClosed || state.generation.blocksForm) return;
    emit(next.copyWith(clearFeedback: true));
    // Exactly one snapshot per confirmed action, even if an equal random
    // choice suppresses a state emission. Never save from a widget builder.
    _onApplied?.call(next.toSelection());
  }

  void dismissFeedback() {
    if (isClosed || state.feedback == null) return;
    emit(state.copyWith(clearFeedback: true));
  }

  void _feedback(String message, GenerateFeedbackKind kind) {
    emit(
      state.copyWith(
        feedback: GenerateFeedback(
          id: ++_feedbackSequence,
          message: message,
          kind: kind,
        ),
      ),
    );
  }
}
