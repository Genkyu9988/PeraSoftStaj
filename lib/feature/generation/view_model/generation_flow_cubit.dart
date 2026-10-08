import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perasoft_staj/feature/generation/view_model/generation_activity.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';

/// Shared request lifecycle, independent of choices, storage and UI context.
/// S lets Generate retain its form state without duplicating this flow.
abstract class GenerationFlowCubit<S> extends Cubit<S> {
  GenerationFlowCubit({
    required S initialState,
    required GenerationService generationService,
    Duration generationTimeout = const Duration(seconds: 20),
    void Function(GenerationResult)? onCompleted,
  }) : _service = generationService,
       _timeout = generationTimeout,
       _onCompleted = onCompleted,
       super(initialState);
  final GenerationService _service;
  final Duration _timeout;
  final void Function(GenerationResult)? _onCompleted;
  int _attemptSequence = 0;
  GenerationActivity get activity;
  @protected
  void emitActivity(GenerationActivity activity);

  @protected
  Future<void> startGeneration(GenerationInput request) async {
    if (isClosed || activity.blocksForm) return;
    await _generate(request);
  }

  Future<void> retryGeneration() async {
    if (isClosed || activity.status != GenerationStatus.failure) return;
    await _generate(activity.request!);
  }

  Future<void> _generate(GenerationInput request) async {
    final id = ++_attemptSequence;
    emitActivity(GenerationActivity.loading(id, request));
    try {
      final result = await _service.generate(request).timeout(_timeout);
      if (!_isCurrent(id)) return;
      if (result.request != request) {
        throw const GenerationException(GenerationFailureKind.unavailable);
      }
      // One accepted completion, before any navigation/listener can consume it.
      _onCompleted?.call(result);
      emitActivity(GenerationActivity.success(id, result));
    } on TimeoutException {
      _fail(id, request, GenerationFailureKind.timeout);
    } on GenerationException catch (error) {
      _fail(id, request, error.kind);
    } catch (_) {
      _fail(id, request, GenerationFailureKind.unavailable);
    }
  }

  bool _isCurrent(int id) => !isClosed && id == _attemptSequence;
  void _fail(int id, GenerationInput request, GenerationFailureKind kind) {
    if (_isCurrent(id)) {
      emitActivity(GenerationActivity.failure(id, request, kind));
    }
  }

  /// Logical cancellation only, not cancellation of a future remote AI job.
  void dismissGeneration() {
    if (isClosed) return;
    _attemptSequence++;
    emitActivity(const GenerationActivity.idle());
  }

  void consumeResult(int attemptId) {
    if (isClosed ||
        activity.status != GenerationStatus.success ||
        activity.attemptId != attemptId) {
      return;
    }
    dismissGeneration();
  }
}
