import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';

/// No Flutter context, navigation, cache or HTTP client requirement.
abstract interface class GenerationService {
  Future<GenerationResult> generate(GenerationInput request);
}

enum GenerationFailureKind { demo, unavailable, timeout, limit }

final class GenerationException implements Exception {
  const GenerationException(this.kind);
  final GenerationFailureKind kind;
}
