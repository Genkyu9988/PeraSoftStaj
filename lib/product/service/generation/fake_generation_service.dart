import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_plan.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'package:perasoft_staj/product/service/generation/generation_input_resolver.dart';

/// Like lesson 18's ready-model service, this never performs network I/O.
/// Failures are opt-in and deterministic, not random user-facing errors.
final class FakeGenerationService implements GenerationService {
  FakeGenerationService({
    this.delay = const Duration(milliseconds: 1500),
    int failuresBeforeSuccess = 0,
  }) : assert(failuresBeforeSuccess >= 0),
       _failuresRemaining = failuresBeforeSuccess;

  final Duration delay;
  int _failuresRemaining;

  @override
  Future<DemoGenerationResult> generate(GenerationInput request) async {
    // Resolve before consuming the failure scenario; invalid input is not a job.
    final GenerationPlan plan;
    try {
      plan = const GenerationInputResolver().resolve(request);
    } on GenerationInputException {
      throw const GenerationException(GenerationFailureKind.unavailable);
    }
    // Consume the scenario at invocation, so overlapping cancelled requests
    // cannot change which attempt is meant to fail.
    final shouldFail = _failuresRemaining > 0;
    if (shouldFail) _failuresRemaining--;
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw const GenerationException(GenerationFailureKind.demo);
    }
    return DemoGenerationResult(
      request: request,
      originalImagePath: plan.vehicle.assetPath,
    );
  }
}
