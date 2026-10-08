import 'package:equatable/equatable.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_plan.dart';

/// New real-media results must be explicit subtypes, never demo path fallbacks.
/// Provider response/URL/job parsing is intentionally not invented here.
sealed class GenerationResult extends Equatable {
  const GenerationResult({required this.request});
  final GenerationInput request;
  GenerationMediaKind get mediaKind;
}

/// Original local photo, even when the REQUEST asks for a video.
final class DemoGenerationResult extends GenerationResult {
  const DemoGenerationResult({
    required super.request,
    required this.originalImagePath,
  });

  final String originalImagePath;

  @override
  GenerationMediaKind get mediaKind => GenerationMediaKind.image;

  @override
  List<Object> get props => [request, originalImagePath];
}
