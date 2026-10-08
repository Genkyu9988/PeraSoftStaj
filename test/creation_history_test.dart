import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/creations/view_model/creation_history_cubit.dart';
import 'package:perasoft_staj/feature/generate/logic/generate_suggestions.dart';
import 'package:perasoft_staj/feature/generate/view_model/generate_cubit.dart';
import 'package:perasoft_staj/feature/ai_video/view_model/ai_video_generation_cubit.dart';
import 'package:perasoft_staj/feature/explore/view_model/explore_generation_cubit.dart';
import 'package:perasoft_staj/product/cache/creation_cache_manager.dart';
import 'package:perasoft_staj/product/cache/creation_repository.dart';
import 'package:perasoft_staj/product/cache/shared_manager.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'package:perasoft_staj/product/model/ai_video_template.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/model/generation_plan.dart';
import 'helpers/controlled_generation_service.dart';

const vehicle = 'porsche_911';
DemoGenerationResult demo([GenerationInput? input]) => DemoGenerationResult(
  request:
      input ??
      GenerationRequest(
        mode: GenerateMode.customEdit,
        vehicleId: vehicle,
        description: 'Mat boya',
      ),
  originalImagePath: VehicleCatalog.find(
    input?.vehicleId ?? vehicle,
  )!.imagePath,
);
CreationRecord record(String id, [GenerationInput? input]) => CreationRecord(
  id: id,
  createdAt: DateTime.utc(2026, 10, 8),
  result: demo(input),
);

class KeyStorage extends SharedManager {
  final values = <SharedKeys, String>{};
  int writes = 0;
  @override
  Future<String?> getString(SharedKeys key) async => values[key];
  @override
  Future<void> saveString(SharedKeys key, String value) async {
    writes++;
    values[key] = value;
  }
}

class ControlledRepository implements CreationRepository {
  Completer<List<CreationRecord>>? read;
  bool failRead = false;
  bool failSave = false;
  List<CreationRecord> stored = [];
  final writes = <List<CreationRecord>>[];
  final gates = <Completer<void>>[];
  bool holdWrites = false;
  @override
  Future<List<CreationRecord>> load() async {
    if (failRead) throw StateError('read failed');
    return read == null ? stored : read!.future;
  }

  @override
  Future<void> save(List<CreationRecord> records) async {
    writes.add(records);
    if (holdWrites) {
      final gate = Completer<void>();
      gates.add(gate);
      await gate.future;
    }
    if (failSave) throw StateError('write failed');
    stored = records;
  }
}

void main() {
  final inputs = <GenerationInput>[
    GenerationRequest(
      mode: GenerateMode.styleBuilder,
      vehicleId: vehicle,
      style: 'Sportif',
      extra: 'Jant',
      color: 'Özel Mor',
    ),
    GenerationRequest(
      mode: GenerateMode.customEdit,
      vehicleId: vehicle,
      description: 'Yeni jant\nMat boya',
    ),
    GenerationRequest(
      mode: GenerateMode.detailEdit,
      vehicleId: vehicle,
      angle: 'Rear',
      parts: {'Spoiler': 2, 'Exhaust': 0},
      color: 'Mavi',
    ),
    for (final operation in ExploreOperation.values)
      ExploreGenerationRequest(
        operation: operation,
        vehicleId: vehicle,
        optionId: operation.input == ExploreInput.option
            ? CarModCatalog.groups[operation.title]!.first.id
            : '',
        color: operation.input == ExploreInput.color ? 'Özel Mor' : '',
        referenceId: operation.input == ExploreInput.reference
            ? ReferenceCarCatalog.items.first.id
            : '',
      ),
    for (final template in AiVideoTemplate.values)
      AiVideoGenerationRequest(template: template, vehicleId: vehicle),
  ];

  for (var i = 0; i < inputs.length; i++) {
    test('Record $i survives JSON round trip with exact request snapshot', () {
      final original = record('$i', inputs[i]);
      final restored = CreationRecord.fromJson(
        jsonDecode(jsonEncode(original.toJson())),
      );
      expect(restored, original);
      expect(restored.result.mediaKind, GenerationMediaKind.image);
      expect(restored.isVideoDemo, inputs[i] is AiVideoGenerationRequest);
    });
  }

  test('Cache uses a separate key; fresh manager restores all modes', () async {
    final storage = KeyStorage()..values[SharedKeys.selections] = 'unchanged';
    final records = [
      for (var i = 0; i < inputs.length; i++) record('$i', inputs[i]),
    ];
    await CreationCacheManager(storage).save(records);
    expect(await CreationCacheManager(storage).load(), records);
    expect(storage.values[SharedKeys.selections], 'unchanged');
    expect(storage.writes, 1);
  });

  for (final corruption in [
    'json',
    'version',
    'vehicle',
    'kind',
    'path',
    'date',
    'mode',
    'parts',
    'duplicate',
  ]) {
    test(
      'Unreadable $corruption history is not replaced on new generation',
      () async {
        final storage = KeyStorage();
        final raw = record('old').toJson();
        final input = raw['input'] as Map<String, Object?>;
        switch (corruption) {
          case 'vehicle':
            input['vehicleId'] = 'missing';
          case 'kind':
            raw['kind'] = 'realVideo';
          case 'path':
            raw['originalImagePath'] = 'https://not-an-asset';
          case 'date':
            raw['createdAt'] = 'not-a-date';
          case 'mode':
            input['mode'] = 'unknown';
          case 'parts':
            input['parts'] = {'Spoiler': 'wrong'};
        }
        final text = corruption == 'json'
            ? '{'
            : jsonEncode({
                'version': corruption == 'version' ? 2 : 1,
                'records': [raw, if (corruption == 'duplicate') raw],
              });
        storage.values[SharedKeys.creations] = text;
        final history = CreationHistoryCubit(
          repository: CreationCacheManager(storage),
        );
        addTearDown(history.close);
        await history.load();
        expect(history.state.loadFailed, isTrue);
        history.record(demo());
        await history.pendingSave;
        expect(history.state.records, hasLength(1));
        expect(storage.values[SharedKeys.creations], text);
        expect(storage.writes, 0);
      },
    );
  }

  test(
    'Late initial read merges new successes before the first save',
    () async {
      final repo = ControlledRepository()..read = Completer();
      final history = CreationHistoryCubit(
        repository: repo,
        clock: () => DateTime.utc(2026, 10, 9),
      );
      addTearDown(history.close);
      final loading = history.load();
      history.record(demo());
      history.record(demo(inputs.last));
      expect(repo.writes, isEmpty);
      repo.read!.complete([record('previous')]);
      await loading;
      await history.pendingSave;
      expect(history.state.records, hasLength(3));
      expect(history.state.records.last.id, 'previous');
      expect(repo.stored, history.state.records);
      expect(history.state.images, hasLength(2));
      expect(history.state.videos, hasLength(1));
      expect(() => history.state.records.clear(), throwsUnsupportedError);
    },
  );

  test(
    'Failed read can recover without losing this session or old records',
    () async {
      final repo = ControlledRepository()..failRead = true;
      final history = CreationHistoryCubit(repository: repo);
      addTearDown(history.close);
      await history.load();
      history.record(demo());
      expect(repo.writes, isEmpty);
      repo.failRead = false;
      repo.stored = [record('previous')];
      await history.retryPersistence();
      expect(history.state.loadFailed, isFalse);
      expect(repo.stored, hasLength(2));
    },
  );

  test(
    'Save failure retains the demo; retry saves without duplicate',
    () async {
      final repo = ControlledRepository()..failSave = true;
      final history = CreationHistoryCubit(repository: repo);
      addTearDown(history.close);
      await history.load();
      history.record(demo());
      await history.pendingSave;
      expect(history.state.saveFailed, isTrue);
      final id = history.state.records.single.id;
      repo.failSave = false;
      await history.retryPersistence();
      expect(history.state.saveFailed, isFalse);
      expect(repo.stored.single.id, id);
      final restarted = CreationHistoryCubit(repository: repo);
      addTearDown(restarted.close);
      await restarted.load();
      expect(restarted.state.records, history.state.records);
    },
  );

  test(
    'Writes are serialized and complete even when the UI owner closes',
    () async {
      final repo = ControlledRepository()..holdWrites = true;
      final history = CreationHistoryCubit(repository: repo);
      await history.load();
      history.record(demo());
      history.record(demo());
      await Future<void>.delayed(Duration.zero);
      expect(repo.writes, hasLength(1));
      await history.close();
      repo.gates.first.complete();
      await Future<void>.delayed(Duration.zero);
      expect(repo.writes, hasLength(2));
      repo.gates.last.complete();
      await history.pendingSave;
      expect(repo.stored, hasLength(2));
      expect(repo.stored.map((r) => r.id).toSet(), hasLength(2));
    },
  );

  for (final mode in GenerateMode.values) {
    test(
      '$mode cancellation, fail/retry, consume and new success record correctly',
      () async {
        final history = CreationHistoryCubit(
          repository: MemoryCreationRepository(),
        );
        final service = ControlledGenerationService();
        final cubit = GenerateCubit(
          initialSelection: const GenerateSelection(
            vehicleId: vehicle,
            style: 'Sportif',
            angle: 'Rear',
            parts: {'Spoiler': 0},
          ),
          suggestions: GenerateSuggestions(),
          generationService: service,
          onCompleted: history.record,
        );
        addTearDown(history.close);
        addTearDown(cubit.close);
        await history.load();
        final first = cubit.submit(mode, description: 'Mat boya');
        cubit.dismissGeneration();
        service.succeed();
        await first;
        expect(history.state.records, isEmpty);
        final failed = cubit.submit(mode, description: 'Mat boya');
        service.fail(1);
        await failed;
        expect(history.state.records, isEmpty);
        final retry = cubit.retryGeneration();
        expect(service.requests[2], same(service.requests[1]));
        service.succeed(2);
        await retry;
        expect(history.state.records, hasLength(1));
        cubit.consumeResult(cubit.activity.attemptId);
        await cubit.retryGeneration();
        expect(history.state.records, hasLength(1));
        final next = cubit.submit(mode, description: 'Mat boya');
        service.succeed(3);
        await next;
        await history.pendingSave;
        expect(history.state.records, hasLength(2));
      },
    );
  }

  for (final video in [false, true]) {
    test(
      'Editor video=$video accepts once; closed owner ignores late result',
      () async {
        final history = CreationHistoryCubit(
          repository: MemoryCreationRepository(),
        );
        final service = ControlledGenerationService();
        final cubit = video
            ? AiVideoGenerationCubit(
                generationService: service,
                onCompleted: history.record,
              )
            : ExploreGenerationCubit(
                generationService: service,
                onCompleted: history.record,
              );
        addTearDown(history.close);
        await history.load();
        final title = video ? 'Cliff Drive' : 'Japanese';
        cubit.submit(
          title: title,
          selection: const ExploreSelection(image: vehicle),
        );
        service.succeed();
        await Future<void>.delayed(Duration.zero);
        expect(history.state.records, hasLength(1));
        expect(history.state.records.single.isVideoDemo, video);
        cubit.dismissGeneration();
        cubit.submit(
          title: title,
          selection: const ExploreSelection(image: vehicle),
        );
        await cubit.close();
        service.succeed(1);
        await Future<void>.delayed(Duration.zero);
        expect(history.state.records, hasLength(1));
      },
    );
  }

  test('Timeout and mismatched result never reach history', () async {
    final history = CreationHistoryCubit(
      repository: MemoryCreationRepository(),
    );
    final service = ControlledGenerationService();
    final cubit = GenerateCubit(
      initialSelection: const GenerateSelection(
        vehicleId: vehicle,
        style: 'Sportif',
      ),
      suggestions: GenerateSuggestions(),
      generationService: service,
      generationTimeout: const Duration(milliseconds: 1),
      onCompleted: history.record,
    );
    addTearDown(history.close);
    addTearDown(cubit.close);
    await history.load();
    await cubit.submit(GenerateMode.styleBuilder);
    service.succeed();
    await Future<void>.delayed(Duration.zero);
    expect(history.state.records, isEmpty);
    cubit.dismissGeneration();
    final next = cubit.submit(GenerateMode.styleBuilder);
    service.pending[1].complete(demo());
    await next;
    expect(history.state.records, isEmpty);
  });
}
