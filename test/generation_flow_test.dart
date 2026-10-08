import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/generate/logic/generate_suggestions.dart';
import 'package:perasoft_staj/feature/generate/view_model/generate_cubit.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generate_state.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generation_activity.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';

import 'helpers/controlled_generation_service.dart';

const _selection = GenerateSelection(
  vehicleId: 'mustang_classic',
  style: 'Sportif',
  extra: 'Jant',
  color: 'Mavi',
  angle: 'Rear',
  parts: {'Spoiler': 2, 'Exhaust': 0},
  detailColor: 'Mor',
);

void main() {
  late ControlledGenerationService service;
  late List<GenerateSelection> writes;
  GenerateCubit make({
    GenerateSelection selection = _selection,
    Duration? timeout,
  }) {
    final cubit = GenerateCubit(
      initialSelection: selection,
      suggestions: GenerateSuggestions(),
      generationService: service,
      onApplied: writes.add,
      generationTimeout: timeout ?? const Duration(seconds: 20),
    );
    addTearDown(cubit.close);
    return cubit;
  }

  setUp(() {
    service = ControlledGenerationService();
    writes = [];
  });

  for (final mode in GenerateMode.values) {
    test(
      'Missing input for $mode never invokes service or writes cache',
      () async {
        final cubit = make(selection: const GenerateSelection());
        await cubit.submit(mode);
        expect(service.requests, isEmpty);
        expect(cubit.state.feedback?.kind, GenerateFeedbackKind.warning);
        expect(cubit.state.generation.status, GenerationStatus.idle);
        expect(writes, isEmpty);
      },
    );

    test(
      'Missing mode-specific choice for $mode never invokes service',
      () async {
        final cubit = make(
          selection: const GenerateSelection(vehicleId: 'mustang_classic'),
        );
        await cubit.submit(mode, description: ' \n ');
        expect(service.requests, isEmpty);
        expect(cubit.state.feedback?.kind, GenerateFeedbackKind.warning);
      },
    );

    test(
      '$mode: loading -> success, active-mode snapshot only, no persistence',
      () async {
        final cubit = make();
        final statuses = <GenerationStatus>[];
        final sub = cubit.stream.listen(
          (s) => statuses.add(s.generation.status),
        );
        final future = cubit.submit(
          mode,
          description: '  Yeni jant\nMat boya  ',
        );
        expect(cubit.state.generation.status, GenerationStatus.loading);
        final request = service.requests.single as GenerationRequest;
        expect(request.mode, mode);
        expect(request.vehicleId, _selection.vehicleId);
        switch (mode) {
          case GenerateMode.styleBuilder:
            expect(
              [request.style, request.extra, request.color],
              ['Sportif', 'Jant', 'Mavi'],
            );
            expect(request.angle, '');
            expect(request.parts, isEmpty);
            expect(request.description, '');
          case GenerateMode.customEdit:
            expect(request.description, 'Yeni jant\nMat boya');
            expect(
              [request.style, request.extra, request.color, request.angle],
              ['', '', '', ''],
            );
            expect(request.parts, isEmpty);
          case GenerateMode.detailEdit:
            expect(request.angle, 'Rear');
            expect(request.parts, _selection.parts);
            expect(request.color, 'Mor');
            expect(
              [request.style, request.extra, request.description],
              ['', '', ''],
            );
        }
        service.succeed();
        await future;
        expect(cubit.state.generation.result?.request, same(request));
        expect(cubit.state.feedback, isNull);
        expect(cubit.state.toSelection().toJson(), _selection.toJson());
        expect(writes, isEmpty);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        expect(statuses, [GenerationStatus.loading, GenerationStatus.success]);
      },
    );
  }

  test(
    'Duplicate submission, retry, suggestions and choice changes are blocked while loading',
    () async {
      final cubit = make();
      final future = cubit.submit(GenerateMode.detailEdit);
      for (var i = 0; i < 5; i++) {
        await cubit.submit(GenerateMode.styleBuilder);
        await cubit.retryGeneration();
        cubit.selectAngle('Front');
        cubit.selectVehicle('');
        cubit.selectStyleColor('Sarı');
        cubit.selectParts({'Hood': 0});
        cubit.suggestIdea(GenerateMode.styleBuilder);
      }
      expect(cubit.canOpenDetailOptions(), isFalse);
      expect(service.requests, hasLength(1));
      expect(cubit.state.toSelection().toJson(), _selection.toJson());
      expect(writes, isEmpty);
      service.succeed();
      await future;
    },
  );

  test(
    'Failure/retry keeps identical request and clears transient failure',
    () async {
      final cubit = make();
      final first = cubit.submit(
        GenerateMode.customEdit,
        description: '  Mat siyah  ',
      );
      service.fail();
      await first;
      final old = cubit.state.generation;
      expect(old.status, GenerationStatus.failure);
      expect(old.failure, GenerationFailureKind.demo);
      final retry = cubit.retryGeneration();
      expect(service.requests[1], same(service.requests[0]));
      expect(cubit.state.generation.failure, isNull);
      expect(cubit.state.generation.result, isNull);
      expect(cubit.state.generation.attemptId, greaterThan(old.attemptId));
      service.succeed(1);
      await retry;
      expect(cubit.state.generation.status, GenerationStatus.success);
      expect(cubit.state.toSelection().toJson(), _selection.toJson());
      expect(writes, isEmpty);
    },
  );

  test(
    'Repeated failures have distinct identity; dismiss enables edited request',
    () async {
      final cubit = make();
      var future = cubit.submit(GenerateMode.styleBuilder);
      service.fail();
      await future;
      final first = cubit.state;
      future = cubit.retryGeneration();
      service.fail(1);
      await future;
      expect(cubit.state, isNot(first));
      cubit.dismissGeneration();
      cubit.selectStyleColor('Sarı');
      future = cubit.submit(GenerateMode.styleBuilder);
      expect((service.requests.last as GenerationRequest).color, 'Sarı');
      service.succeed(2);
      await future;
      expect(writes, hasLength(1));
    },
  );

  test(
    'Unexpected errors become safe typed failures; loading always ends',
    () async {
      final cubit = make();
      final future = cubit.submit(GenerateMode.styleBuilder);
      service.fail(0, StateError('private token/raw response'));
      await future;
      expect(cubit.state.generation.failure, GenerationFailureKind.unavailable);
      expect(cubit.state.generation.isLoading, isFalse);
    },
  );

  test(
    'Timeout releases loading; late result cannot overwrite a retry',
    () async {
      final cubit = make(timeout: const Duration(milliseconds: 10));
      await cubit.submit(GenerateMode.styleBuilder);
      expect(cubit.state.generation.failure, GenerationFailureKind.timeout);
      final retry = cubit.retryGeneration();
      service.succeed();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.generation.status, GenerationStatus.loading);
      service.succeed(1);
      await retry;
      expect(cubit.state.generation.status, GenerationStatus.success);
    },
  );

  for (final oldFails in [false, true]) {
    test(
      'Cancelled old future (failure=$oldFails) cannot overwrite next result',
      () async {
        final cubit = make();
        final first = cubit.submit(GenerateMode.styleBuilder);
        cubit.dismissGeneration();
        cubit.selectVehicle('fiat_500');
        final second = cubit.submit(GenerateMode.styleBuilder);
        service.succeed(1);
        await second;
        final current = cubit.state;
        if (oldFails) {
          service.fail();
        } else {
          service.succeed();
        }
        await first;
        expect(cubit.state, same(current));
        expect(cubit.state.generation.result?.request.vehicleId, 'fiat_500');
      },
    );

    test('Closed owner ignores late future (failure=$oldFails)', () async {
      final cubit = make();
      final future = cubit.submit(GenerateMode.styleBuilder);
      await cubit.close();
      final before = cubit.state;
      if (oldFails) {
        service.fail();
      } else {
        service.succeed();
      }
      await future;
      expect(cubit.state, same(before));
    });
  }

  test(
    'Only matching success can be consumed; same inputs can generate again',
    () async {
      final cubit = make();
      var future = cubit.submit(GenerateMode.styleBuilder);
      service.succeed();
      await future;
      final first = cubit.state.generation;
      cubit.consumeResult(first.attemptId + 1);
      await cubit.submit(GenerateMode.styleBuilder);
      expect(service.requests, hasLength(1));
      cubit.consumeResult(first.attemptId);
      expect(cubit.state.generation, const GenerationActivity.idle());
      future = cubit.submit(GenerateMode.styleBuilder);
      service.succeed(1);
      await future;
      expect(cubit.state.generation, isNot(first));
      expect(cubit.state.generation.result, first.result);
    },
  );

  test(
    'Mismatched service response is not displayed as this request result',
    () async {
      final cubit = make();
      final future = cubit.submit(GenerateMode.styleBuilder);
      service.pending.single.complete(
        DemoGenerationResult(
          request: GenerationRequest(
            mode: GenerateMode.customEdit,
            vehicleId: 'fiat_500',
          ),
          originalImagePath: 'unrelated.jpg',
        ),
      );
      await future;
      expect(cubit.state.generation.failure, GenerationFailureKind.unavailable);
    },
  );

  test(
    'Generation state is transient and never restored from selection cache',
    () async {
      final cubit = make();
      final future = cubit.submit(GenerateMode.styleBuilder);
      service.fail();
      await future;
      final restored = GenerateState.fromSelection(
        GenerateSelection.fromJson(cubit.state.toSelection().toJson()),
      );
      expect(restored.generation, const GenerationActivity.idle());
      expect(restored.toSelection().toJson(), _selection.toJson());
    },
  );
}
