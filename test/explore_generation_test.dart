import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/explore/view_model/explore_generation_cubit.dart';
import 'package:perasoft_staj/feature/generation/view_model/generation_activity.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/explore_items.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/service/generation/fake_generation_service.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'package:perasoft_staj/product/validation/explore_validation_messages.dart';
import 'helpers/controlled_generation_service.dart';

ExploreSelection validExploreSelection(ExploreOperation operation) =>
    ExploreSelection(
      image: VehicleCatalog.samples.first.id,
      option: switch (operation.input) {
        ExploreInput.color => 'Özel Mor',
        ExploreInput.option => CarModCatalog.groups[operation.title]!.first.id,
        _ => 'ignored inactive field',
      },
      referenceImage: ReferenceCarCatalog.items.first.id,
    );

Future<void> flushGeneration() => Future<void>.delayed(Duration.zero);

void main() {
  late ControlledGenerationService service;
  ExploreGenerationCubit make({Duration? timeout}) {
    final cubit = ExploreGenerationCubit(
      generationService: service,
      generationTimeout: timeout ?? const Duration(seconds: 20),
    );
    addTearDown(cubit.close);
    return cubit;
  }

  setUp(() => service = ControlledGenerationService());

  test(
    'Every visible Explore operation has one stable identity and input rule',
    () {
      final titles = [
        ...ExploreItems.carMods,
        ...ExploreItems.styleBuilder,
        ...ExploreItems.wallpaperMaker,
        ...ExploreItems.aiEdits,
      ];
      expect(
        ExploreOperation.values.map((e) => e.title),
        unorderedEquals(titles),
      );
      expect(
        ExploreOperation.values.map((e) => e.name).toSet().length,
        titles.length,
      );
      expect(ExploreOperation.fromTitle('unknown'), isNull);
    },
  );

  for (final operation in ExploreOperation.values) {
    test(
      '${operation.name}: validates before service, correct detached input and demo photo',
      () async {
        final cubit = make();
        expect(
          cubit.submit(
            title: operation.title,
            selection: const ExploreSelection(),
          ),
          operation.input == ExploreInput.reference
              ? ExploreValidationMessages.cloneImage
              : ExploreValidationMessages.image,
        );
        expect(service.requests, isEmpty);
        final selection = validExploreSelection(operation);
        final original = selection.toJson();
        final states = <GenerationStatus>[];
        final sub = cubit.stream.listen((s) => states.add(s.status));
        addTearDown(sub.cancel);
        expect(
          cubit.submit(title: operation.title, selection: selection),
          isNull,
        );
        expect(cubit.state.status, GenerationStatus.loading);
        final request = service.requests.single as ExploreGenerationRequest;
        expect(request.operation, operation);
        expect(request.vehicleId, selection.image);
        expect(
          request.optionId,
          operation.input == ExploreInput.option ? selection.option : '',
        );
        expect(
          request.color,
          operation.input == ExploreInput.color ? selection.option : '',
        );
        expect(
          request.referenceId,
          operation.input == ExploreInput.reference
              ? selection.referenceImage
              : '',
        );
        final demo = await FakeGenerationService(
          delay: Duration.zero,
        ).generate(request);
        expect(
          demo.originalImagePath,
          VehicleCatalog.find(selection.image)!.imagePath,
        );
        expect(demo.request, same(request));
        service.succeed();
        await flushGeneration();
        expect(states, [GenerationStatus.loading, GenerationStatus.success]);
        expect(selection.toJson(), original);
        cubit.consumeResult(cubit.state.attemptId);
        expect(cubit.state.status, GenerationStatus.idle);
      },
    );
    if (operation.input != ExploreInput.image) {
      test(
        '${operation.name}: missing/foreign second input never invokes service',
        () {
          final cubit = make();
          for (final value in ['', 'invalid.option']) {
            final error = cubit.submit(
              title: operation.title,
              selection: ExploreSelection(
                image: VehicleCatalog.samples.first.id,
                option: value,
                referenceImage: value,
              ),
            );
            expect(error, switch (operation.input) {
              ExploreInput.color => ExploreValidationMessages.color,
              ExploreInput.reference =>
                ExploreValidationMessages.referenceImage,
              _ => ExploreValidationMessages.targetImage,
            });
          }
          expect(service.requests, isEmpty);
        },
      );
    }
  }

  test(
    'Same vehicle with a different operation/target is a different request',
    () {
      final a = ExploreGenerationRequest(
        operation: ExploreOperation.japanese,
        vehicleId: 'mustang_classic',
      );
      final b = ExploreGenerationRequest(
        operation: ExploreOperation.american,
        vehicleId: a.vehicleId,
      );
      expect(a, isNot(b));
      expect(
        const ExploreGenerationRequest(
          operation: ExploreOperation.changeColor,
          vehicleId: 'mustang_classic',
          color: 'Mavi',
        ),
        isNot(
          const ExploreGenerationRequest(
            operation: ExploreOperation.changeColor,
            vehicleId: 'mustang_classic',
            color: 'Mor',
          ),
        ),
      );
    },
  );

  test(
    'Duplicate submit blocked; retry uses identical failed snapshot',
    () async {
      final cubit = make();
      final selection = validExploreSelection(ExploreOperation.customizeRims);
      cubit.submit(title: 'Customize Rims', selection: selection);
      cubit.submit(title: 'Japanese', selection: selection);
      expect(service.requests, hasLength(1));
      service.fail();
      await flushGeneration();
      expect(cubit.state.failure, GenerationFailureKind.demo);
      cubit.submit(title: 'Japanese', selection: selection);
      expect(service.requests, hasLength(1));
      final retry = cubit.retryGeneration();
      expect(service.requests[1], same(service.requests[0]));
      service.succeed(1);
      await retry;
      expect(cubit.state.status, GenerationStatus.success);
    },
  );

  for (final lateError in [false, true]) {
    test(
      'Canceled response (error=$lateError) cannot overwrite a newer job',
      () async {
        final cubit = make();
        cubit.submit(
          title: 'Japanese',
          selection: validExploreSelection(ExploreOperation.japanese),
        );
        cubit.dismissGeneration();
        cubit.submit(
          title: 'Change Color',
          selection: validExploreSelection(ExploreOperation.changeColor),
        );
        final current = cubit.state;
        lateError ? service.fail() : service.succeed();
        await flushGeneration();
        expect(cubit.state, current);
        service.succeed(1);
        await flushGeneration();
        expect(cubit.state.result!.request, same(service.requests.last));
      },
    );
  }

  test(
    'Closed editor ignores late result; timeout is a typed failure',
    () async {
      final closed = make();
      closed.submit(
        title: 'Japanese',
        selection: validExploreSelection(ExploreOperation.japanese),
      );
      await closed.close();
      service.succeed();
      await flushGeneration();
      final timed = make(timeout: Duration.zero);
      timed.submit(
        title: 'Japanese',
        selection: validExploreSelection(ExploreOperation.japanese),
      );
      await flushGeneration();
      expect(timed.state.failure, GenerationFailureKind.timeout);
      final failed = timed.state;
      service.succeed(1);
      await flushGeneration();
      expect(timed.state, failed);
    },
  );

  test('Unsupported operation and invalid vehicle do not call service', () {
    final cubit = make();
    expect(
      cubit.submit(title: 'Unknown', selection: const ExploreSelection()),
      isNotNull,
    );
    expect(
      cubit.submit(
        title: 'Japanese',
        selection: const ExploreSelection(image: 'bad-id'),
      ),
      ExploreValidationMessages.image,
    );
    expect(service.requests, isEmpty);
  });
}
