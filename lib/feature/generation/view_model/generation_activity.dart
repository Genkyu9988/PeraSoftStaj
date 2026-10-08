import 'package:equatable/equatable.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';

enum GenerationStatus { idle, loading, success, failure }

/// Named constructors keep transient fields consistent on every transition.
final class GenerationActivity extends Equatable {
  const GenerationActivity.idle()
    : status = GenerationStatus.idle,
      attemptId = 0,
      request = null,
      result = null,
      failure = null;

  const GenerationActivity.loading(this.attemptId, GenerationInput this.request)
    : status = GenerationStatus.loading,
      result = null,
      failure = null;

  GenerationActivity.success(this.attemptId, GenerationResult this.result)
    : status = GenerationStatus.success,
      request = result.request,
      failure = null;

  const GenerationActivity.failure(
    this.attemptId,
    GenerationInput this.request,
    GenerationFailureKind this.failure,
  ) : status = GenerationStatus.failure,
      result = null;

  final GenerationStatus status;
  final int attemptId;
  final GenerationInput? request;
  final GenerationResult? result;
  final GenerationFailureKind? failure;

  bool get isLoading => status == GenerationStatus.loading;
  bool get blocksForm => status != GenerationStatus.idle;

  @override
  List<Object?> get props => [status, attemptId, request, result, failure];
}
