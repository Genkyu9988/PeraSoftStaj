import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/ai_video/view_model/ai_video_generation_cubit.dart';
import 'package:perasoft_staj/feature/generation/view_model/generation_activity.dart';
import 'package:perasoft_staj/product/catalog/ai_video_items.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/ai_video_template.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/fake_generation_service.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'package:perasoft_staj/product/validation/explore_validation_messages.dart';
import 'helpers/controlled_generation_service.dart';

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  late ControlledGenerationService service;
  const selection = ExploreSelection(
    image: 'bmw_ix5',
    option: 'inactive option',
    colorCategory: 2,
    referenceImage: 'inactive reference',
  );
  AiVideoGenerationCubit make({Duration? timeout}) {
    final cubit = AiVideoGenerationCubit(
      generationService: service,
      generationTimeout: timeout ?? const Duration(seconds: 20),
    );
    addTearDown(cubit.close);
    return cubit;
  }

  setUp(() => service = ControlledGenerationService());

  test('All 15 visible templates have unique, stable request identities', () {
    final titles = [
      ...AiVideoItems.transformations,
      ...AiVideoItems.driveScenes,
      ...AiVideoItems.filters,
    ];
    expect(titles, hasLength(15));
    expect(AiVideoTemplate.values.map((t) => t.title), unorderedEquals(titles));
    expect(AiVideoTemplate.values.map((t) => t.name).toSet(), hasLength(15));
    expect(AiVideoTemplate.fromTitle('Japanese'), isNull);
  });

  for (final template in AiVideoTemplate.values) {
    test(
      '${template.name}: validation, typed snapshot, state order and original photo',
      () async {
        final cubit = make();
        expect(
          cubit.submit(
            title: template.title,
            selection: const ExploreSelection(),
          ),
          ExploreValidationMessages.image,
        );
        expect(service.requests, isEmpty);
        final original = selection.toJson();
        final statuses = <GenerationStatus>[];
        final subscription = cubit.stream.listen((s) => statuses.add(s.status));
        addTearDown(subscription.cancel);
        expect(
          cubit.submit(title: template.title, selection: selection),
          isNull,
        );
        expect(cubit.state.status, GenerationStatus.loading);
        final request = service.requests.single as AiVideoGenerationRequest;
        expect(request.template, template);
        expect(request.vehicleId, selection.image);
        final result = await FakeGenerationService(
          delay: Duration.zero,
        ).generate(request);
        expect(
          result.originalImagePath,
          VehicleCatalog.find(selection.image)!.imagePath,
        );
        expect(result.request, same(request));
        service.pending.single.complete(result);
        await flush();
        expect(statuses, [GenerationStatus.loading, GenerationStatus.success]);
        expect(selection.toJson(), original);
        cubit.consumeResult(cubit.state.attemptId);
        expect(cubit.state, const GenerationActivity.idle());
        expect(cubit.state.result, isNull);
      },
    );
  }

  test('Unknown template and invalid vehicle never call service', () {
    final cubit = make();
    expect(cubit.submit(title: 'Japanese', selection: selection), isNotNull);
    expect(
      cubit.submit(
        title: 'Race Video',
        selection: const ExploreSelection(image: 'invalid'),
      ),
      ExploreValidationMessages.image,
    );
    expect(service.requests, isEmpty);
  });

  test('Request equality includes vehicle and template', () {
    const request = AiVideoGenerationRequest(
      template: AiVideoTemplate.cliffDrive,
      vehicleId: 'bmw_ix5',
    );
    expect(
      request,
      const AiVideoGenerationRequest(
        template: AiVideoTemplate.cliffDrive,
        vehicleId: 'bmw_ix5',
      ),
    );
    expect(
      request,
      isNot(
        const AiVideoGenerationRequest(
          template: AiVideoTemplate.raceVideo,
          vehicleId: 'bmw_ix5',
        ),
      ),
    );
    expect(
      request,
      isNot(
        const AiVideoGenerationRequest(
          template: AiVideoTemplate.cliffDrive,
          vehicleId: 'fiat_500',
        ),
      ),
    );
  });

  test(
    'Duplicate submit is blocked; retry uses the exact failed snapshot',
    () async {
      final cubit = make();
      cubit.submit(title: 'Cliff Drive', selection: selection);
      cubit.submit(
        title: 'Race Video',
        selection: const ExploreSelection(image: 'fiat_500'),
      );
      expect(service.requests, hasLength(1));
      service.fail();
      await flush();
      expect(cubit.state.failure, GenerationFailureKind.demo);
      final retry = cubit.retryGeneration();
      unawaited(cubit.retryGeneration());
      expect(service.requests, hasLength(2));
      expect(service.requests.last, same(service.requests.first));
      service.succeed(1);
      await retry;
      expect(cubit.state.status, GenerationStatus.success);
      expect(
        (cubit.state.request! as AiVideoGenerationRequest).template,
        AiVideoTemplate.cliffDrive,
      );
    },
  );

  for (final lateError in [false, true]) {
    test(
      'Cancelled old response cannot replace the next job (error=$lateError)',
      () async {
        final cubit = make();
        cubit.submit(title: 'Cliff Drive', selection: selection);
        cubit.dismissGeneration();
        cubit.submit(
          title: 'Race Video',
          selection: const ExploreSelection(image: 'fiat_500'),
        );
        lateError ? service.fail() : service.succeed();
        await flush();
        expect(cubit.state.status, GenerationStatus.loading);
        expect(cubit.state.request, same(service.requests[1]));
        service.succeed(1);
        await flush();
        expect(cubit.state.result!.request, same(service.requests[1]));
      },
    );
    test('Closing Cubit ignores pending response (error=$lateError)', () async {
      final cubit = make();
      cubit.submit(title: 'Race Video', selection: selection);
      await cubit.close();
      final before = cubit.state;
      lateError ? service.fail() : service.succeed();
      await flush();
      expect(cubit.state, same(before));
      cubit.submit(title: 'Race Video', selection: selection);
      expect(service.requests, hasLength(1));
    });
  }

  test('Timeout ends loading and a late success is ignored', () async {
    final cubit = make(timeout: Duration.zero);
    cubit.submit(title: 'Race Video', selection: selection);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state.failure, GenerationFailureKind.timeout);
    service.succeed();
    await flush();
    expect(cubit.state.failure, GenerationFailureKind.timeout);
  });

  test('Unexpected errors and mismatched results are safe failures', () async {
    final cubit = make();
    cubit.submit(title: 'Race Video', selection: selection);
    service.fail(0, StateError('internal implementation detail'));
    await flush();
    expect(cubit.state.failure, GenerationFailureKind.unavailable);
    final retry = cubit.retryGeneration();
    service.pending[1].complete(
      const DemoGenerationResult(
        request: AiVideoGenerationRequest(
          template: AiVideoTemplate.zoomIn,
          vehicleId: 'bmw_ix5',
        ),
        originalImagePath: 'wrong-job.jpg',
      ),
    );
    await retry;
    expect(cubit.state.failure, GenerationFailureKind.unavailable);
    expect(cubit.state.result, isNull);
  });
}
