import 'package:equatable/equatable.dart';
import 'package:perasoft_staj/product/model/ai_video_template.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';

enum GenerateMode { styleBuilder, customEdit, detailEdit }

/// Editors share a demo service, not each other's form fields.
sealed class GenerationInput extends Equatable {
  const GenerationInput();
  String get vehicleId;
}

/// A detached snapshot of the active mode, not a reference to form state.
final class GenerationRequest extends GenerationInput {
  GenerationRequest({
    required this.mode,
    required this.vehicleId,
    this.style = '',
    this.extra = '',
    this.color = '',
    this.angle = '',
    Map<String, int> parts = const {},
    this.description = '',
  }) : parts = Map.unmodifiable(parts);

  final GenerateMode mode;
  @override
  final String vehicleId;
  final String style;
  final String extra;
  final String color;
  final String angle;
  final Map<String, int> parts;
  final String description;

  @override
  List<Object> get props => [
    mode,
    vehicleId,
    style,
    extra,
    color,
    angle,
    parts,
    parts.keys.toList(growable: false),
    description,
  ];
}

final class ExploreGenerationRequest extends GenerationInput {
  const ExploreGenerationRequest({
    required this.operation,
    required this.vehicleId,
    this.optionId = '',
    this.color = '',
    this.referenceId = '',
  });
  final ExploreOperation operation;
  @override
  final String vehicleId;
  final String optionId;
  final String color;
  final String referenceId;
  @override
  List<Object> get props => [
    operation,
    vehicleId,
    optionId,
    color,
    referenceId,
  ];
}

/// A video-template request; the fake service still returns an original photo.
final class AiVideoGenerationRequest extends GenerationInput {
  const AiVideoGenerationRequest({
    required this.template,
    required this.vehicleId,
  });

  final AiVideoTemplate template;
  @override
  final String vehicleId;

  @override
  List<Object> get props => [template, vehicleId];
}
