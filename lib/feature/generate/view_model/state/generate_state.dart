import 'package:equatable/equatable.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generation_activity.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';

export 'package:perasoft_staj/product/model/generation_request.dart'
    show GenerateMode;

enum GenerateFeedbackKind { warning, message }

/// An attempt identity lets the listener show the same warning again.
final class GenerateFeedback extends Equatable {
  const GenerateFeedback({
    required this.id,
    required this.message,
    required this.kind,
  });

  final int id;
  final String message;
  final GenerateFeedbackKind kind;

  @override
  List<Object> get props => [id, message, kind];
}

/// Confirmed choices and transient generation. Modal drafts stay in the UI.
final class GenerateState extends Equatable {
  GenerateState({
    this.vehicleId = '',
    this.style = '',
    this.extra = '',
    this.color = '',
    this.colorCategory = 0,
    this.angle = '',
    Map<String, int> parts = const {},
    this.detailColor = '',
    this.detailColorCategory = 0,
    this.feedback,
    this.generation = const GenerationActivity.idle(),
  }) : parts = Map.unmodifiable(parts);

  factory GenerateState.fromSelection(GenerateSelection selection) =>
      GenerateState(
        vehicleId: VehicleCatalog.restoreId(selection.vehicleId),
        style: selection.style,
        extra: selection.extra,
        color: selection.color,
        colorCategory: selection.colorCategory,
        angle: selection.angle,
        parts: DetailPartCatalog.restoreSelections(
          selection.angle,
          selection.parts,
        ),
        detailColor: selection.detailColor,
        detailColorCategory: selection.detailColorCategory,
      );

  final String vehicleId;
  final String style;
  final String extra;
  final String color;
  final int colorCategory;
  final String angle;
  final Map<String, int> parts;
  final String detailColor;
  final int detailColorCategory;
  final GenerateFeedback? feedback;
  final GenerationActivity generation;

  String get partsLabel =>
      parts.entries.map((part) => '${part.key} ${part.value + 1}').join(', ');

  GenerateState copyWith({
    String? vehicleId,
    String? style,
    String? extra,
    String? color,
    int? colorCategory,
    String? angle,
    Map<String, int>? parts,
    String? detailColor,
    int? detailColorCategory,
    GenerateFeedback? feedback,
    bool clearFeedback = false,
    GenerationActivity? generation,
  }) => GenerateState(
    vehicleId: vehicleId ?? this.vehicleId,
    style: style ?? this.style,
    extra: extra ?? this.extra,
    color: color ?? this.color,
    colorCategory: colorCategory ?? this.colorCategory,
    angle: angle ?? this.angle,
    parts: parts ?? this.parts,
    detailColor: detailColor ?? this.detailColor,
    detailColorCategory: detailColorCategory ?? this.detailColorCategory,
    feedback: clearFeedback ? null : feedback ?? this.feedback,
    generation: generation ?? this.generation,
  );

  /// Keep the existing cache schema and detach the map given to the caller.
  GenerateSelection toSelection() => GenerateSelection(
    vehicleId: vehicleId,
    style: style,
    extra: extra,
    color: color,
    colorCategory: colorCategory,
    angle: angle,
    parts: Map.of(parts),
    detailColor: detailColor,
    detailColorCategory: detailColorCategory,
  );

  @override
  List<Object?> get props => [
    vehicleId,
    style,
    extra,
    color,
    colorCategory,
    angle,
    parts,
    // Map equality alone ignores order; the displayed selection does not.
    partsLabel,
    detailColor,
    detailColorCategory,
    feedback,
    generation,
  ];
}
