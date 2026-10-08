import 'package:equatable/equatable.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';

enum GenerationMediaKind { image, video }

/// A bundled image reference, NOT a public URL or uploaded provider file.
final class GenerationAsset extends Equatable {
  const GenerationAsset({required this.id, required this.assetPath});
  final String id;
  final String assetPath;

  @override
  List<Object> get props => [id, assetPath];
}

/// Category is the existing UI category, not a promised physical paint finish.
final class GenerationColor extends Equatable {
  const GenerationColor({
    required this.id,
    required this.categoryId,
    required this.argb,
  });
  final String id;
  final String categoryId;
  final int argb;

  @override
  List<Object> get props => [id, categoryId, argb];
}

final class GenerationPart extends Equatable {
  const GenerationPart({required this.reference, this.instruction});
  final GenerationAsset reference;
  String get id => reference.id;

  /// Only existing catalog instructions are reused; no provider prompt invented.
  final String? instruction;

  @override
  List<Object?> get props => [reference, instruction];
}

/// Provider-independent selection intent. It is not an HTTP/JSON payload.
/// The original snapshot remains available for summaries and request matching.
final class GenerationPlan extends Equatable {
  GenerationPlan({
    required this.request,
    required this.vehicle,
    required this.expectedMedia,
    this.styleId,
    this.extraId,
    this.angleId,
    this.color,
    this.option,
    this.reference,
    List<GenerationPart> parts = const [],
  }) : parts = List.unmodifiable(parts);

  final GenerationInput request;
  final GenerationAsset vehicle;
  final GenerationMediaKind expectedMedia;
  final String? styleId;
  final String? extraId;
  final String? angleId;
  final GenerationColor? color;
  final GenerationPart? option;
  final GenerationAsset? reference;
  final List<GenerationPart> parts;

  @override
  List<Object?> get props => [
    request,
    vehicle,
    expectedMedia,
    styleId,
    extraId,
    angleId,
    color,
    option,
    reference,
    parts,
  ];
}
