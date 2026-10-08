import 'package:bloc_test/bloc_test.dart';
import 'package:perasoft_staj/product/service/generation/fake_generation_service.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generation_activity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/generate/logic/generate_suggestions.dart';
import 'package:perasoft_staj/feature/generate/view_model/generate_cubit.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generate_state.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/validation/generate_validation_messages.dart';
import 'package:perasoft_staj/product/validation/generate_validator.dart';

import 'helpers/sequence_random.dart';

const _initial = GenerateSelection(
  vehicleId: 'mustang_classic',
  style: 'Klasik',
  extra: 'Jant',
  color: 'Premium Mavi',
  colorCategory: 1,
  angle: 'Rear',
  parts: {'Spoiler': 0, 'Exhaust': 1},
  detailColor: 'Özel Mor',
  detailColorCategory: 2,
);

class _RejectingValidator extends GenerateValidator {
  @override
  String? styleBuilder({
    required String vehicleId,
    required String style,
    required String extra,
    required String color,
  }) => 'Injected validation';
}

void main() {
  late List<GenerateSelection> saved;
  GenerateCubit make({
    GenerateSelection initial = _initial,
    List<int> random = const [],
  }) => GenerateCubit(
    generationService: FakeGenerationService(delay: Duration.zero),
    initialSelection: initial,
    suggestions: GenerateSuggestions(random: SequenceRandom(random)),
    onApplied: saved.add,
  );
  setUp(() => saved = []);

  test(
    'Initial state preserves the cache schema and does not save on load',
    () {
      final cubit = make();
      addTearDown(cubit.close);
      expect(cubit.state.toSelection().toJson(), _initial.toJson());
      expect(cubit.state.feedback, isNull);
      expect(saved, isEmpty);
    },
  );

  test('Restore sanitizes vehicle and wrong-angle parts as before', () {
    final cubit = make(
      initial: const GenerateSelection(
        vehicleId: 'unknown',
        angle: 'Front',
        parts: {'Spoiler': 0, 'Hood': 1, 'Headlights': 99},
        detailColor: 'Mavi',
      ),
    );
    addTearDown(cubit.close);
    expect(cubit.state.vehicleId, '');
    expect(cubit.state.parts, {'Hood': 1});
    expect(cubit.state.detailColor, 'Mavi');
    expect(saved, isEmpty);
  });

  test('State owns immutable parts; cache snapshots cannot mutate state', () {
    final source = {'Spoiler': 1};
    final state = GenerateState(angle: 'Rear', parts: source);
    source['Spoiler'] = 2;
    expect(state.parts, {'Spoiler': 1});
    expect(() => state.parts['Spoiler'] = 0, throwsUnsupportedError);
    final copy = state.copyWith();
    final selection = state.toSelection();
    selection.parts.clear();
    expect(state.parts, {'Spoiler': 1});
    expect(copy, state);
    expect(copy.hashCode, state.hashCode);
  });

  test('Every visible field and feedback participates in state equality', () {
    final state = GenerateState.fromSelection(_initial);
    final changes = [
      state.copyWith(vehicleId: ''),
      state.copyWith(style: ''),
      state.copyWith(extra: ''),
      state.copyWith(color: ''),
      state.copyWith(colorCategory: 0),
      state.copyWith(angle: ''),
      state.copyWith(parts: {'Spoiler': 2}),
      state.copyWith(parts: {'Exhaust': 1, 'Spoiler': 0}),
      state.copyWith(detailColor: ''),
      state.copyWith(detailColorCategory: 0),
      state.copyWith(
        feedback: const GenerateFeedback(
          id: 1,
          message: 'warning',
          kind: GenerateFeedbackKind.warning,
        ),
      ),
    ];
    for (final changed in changes) {
      expect(changed, isNot(state));
    }
    expect(state.copyWith(), state);
  });

  for (final from in DetailPartCatalog.byAngle.keys) {
    for (final to in DetailPartCatalog.byAngle.keys) {
      if (from == to) continue;
      blocTest<GenerateCubit, GenerateState>(
        '$from -> $to clears only parts and saves one snapshot',
        build: () => make(
          initial: GenerateSelection(
            vehicleId: _initial.vehicleId,
            angle: from,
            parts: {DetailPartCatalog.forAngle(from).first.title: 1},
            detailColor: 'Özel Mor',
            detailColorCategory: 2,
          ),
        ),
        act: (cubit) => cubit.selectAngle(to),
        expect: () => [
          isA<GenerateState>()
              .having((s) => s.angle, 'angle', to)
              .having((s) => s.parts, 'parts', isEmpty)
              .having((s) => s.detailColor, 'color', 'Özel Mor')
              .having((s) => s.detailColorCategory, 'category', 2),
        ],
        verify: (_) => expect(saved, hasLength(1)),
      );
    }
  }

  test(
    'Applying the same angle keeps parts and clearing the car keeps choices',
    () {
      final cubit = make();
      addTearDown(cubit.close);
      cubit.selectAngle('Rear');
      expect(cubit.state.toSelection().toJson(), _initial.toJson());
      cubit.selectVehicle('');
      expect(cubit.state.toSelection().toJson(), {
        ..._initial.toJson(),
        'vehicleId': '',
      });
      expect(saved, hasLength(2));
    },
  );

  test('Colors derive their category and the modes remain independent', () {
    final cubit = make();
    addTearDown(cubit.close);
    cubit.selectStyleColor('Özel Kırmızı');
    cubit.selectDetailColor('Mavi');
    expect(cubit.state.color, 'Özel Kırmızı');
    expect(cubit.state.colorCategory, 2);
    expect(cubit.state.detailColor, 'Mavi');
    expect(cubit.state.detailColorCategory, 0);
    expect(cubit.state.parts, _initial.parts);
    expect(saved, hasLength(2));
    expect(saved.first.detailColor, _initial.detailColor);
  });

  test(
    'Part drafts are copied, filtered by angle and keep selection order',
    () {
      final cubit = make();
      addTearDown(cubit.close);
      final draft = {'Exhaust': 2, 'Spoiler': 1, 'Hood': 0, 'Tail Lights': 99};
      cubit.selectParts(draft);
      draft.clear();
      expect(cubit.state.parts, {'Exhaust': 2, 'Spoiler': 1});
      expect(cubit.state.partsLabel, 'Exhaust 3, Spoiler 2');
      expect(saved.single.parts.keys, ['Exhaust', 'Spoiler']);
      saved.single.parts.clear();
      expect(cubit.state.parts.length, 2);
    },
  );

  blocTest<GenerateCubit, GenerateState>(
    'Style idea emits one complete selection and preserves Detail',
    build: () => make(random: [11, 5, 5, 11]),
    act: (cubit) => cubit.suggestIdea(GenerateMode.styleBuilder),
    expect: () => [
      GenerateState.fromSelection(_initial).copyWith(
        vehicleId: 'buick_classic',
        style: 'Şehir',
        extra: 'Gövde Kiti',
        color: 'Özel Gri',
        colorCategory: 2,
      ),
    ],
    verify: (cubit) {
      expect(saved, hasLength(1));
      expect(saved.single.toJson(), cubit.state.toSelection().toJson());
      expect(cubit.state.feedback, isNull);
    },
  );

  blocTest<GenerateCubit, GenerateState>(
    'Custom idea changes only the shared car',
    build: () => make(random: [0]),
    act: (cubit) => cubit.suggestIdea(GenerateMode.customEdit),
    expect: () => [
      GenerateState.fromSelection(
        _initial,
      ).copyWith(vehicleId: VehicleCatalog.all.first.id),
    ],
    verify: (_) => expect(saved, hasLength(1)),
  );

  for (var angleIndex = 0; angleIndex < 3; angleIndex++) {
    final angle = DetailPartCatalog.byAngle.keys.elementAt(angleIndex);
    final categories = DetailPartCatalog.forAngle(angle);
    for (
      var categoryIndex = 0;
      categoryIndex < categories.length;
      categoryIndex++
    ) {
      final category = categories[categoryIndex];
      blocTest<GenerateCubit, GenerateState>(
        'Detail idea: $angle / ${category.title} replaces all previous parts',
        build: () => make(random: [0, angleIndex, categoryIndex, 2, 0]),
        act: (cubit) => cubit.suggestIdea(GenerateMode.detailEdit),
        expect: () => [
          GenerateState.fromSelection(_initial).copyWith(
            vehicleId: VehicleCatalog.all.first.id,
            angle: angle,
            parts: {category.title: 2},
            detailColor: 'Kırmızı',
            detailColorCategory: 0,
          ),
        ],
        verify: (_) => expect(saved, hasLength(1)),
      );
    }
  }

  blocTest<GenerateCubit, GenerateState>(
    'Repeated identical ideas still notify once per tap, not once per field',
    build: () => make(random: [11, 5, 5, 11, 11, 5, 5, 11]),
    act: (cubit) {
      cubit.suggestIdea(GenerateMode.styleBuilder);
      cubit.suggestIdea(GenerateMode.styleBuilder);
    },
    expect: () => [isA<GenerateState>()],
    verify: (_) {
      expect(saved, hasLength(2));
      expect(saved.first.toJson(), saved.last.toJson());
    },
  );

  for (final mode in GenerateMode.values) {
    blocTest<GenerateCubit, GenerateState>(
      '$mode: repeated missing-car warnings have distinct identities, no saves',
      build: () => make(initial: const GenerateSelection()),
      act: (cubit) {
        cubit.submit(mode);
        cubit.submit(mode);
      },
      expect: () => [
        for (final id in [1, 2])
          isA<GenerateState>().having(
            (s) => s.feedback,
            'feedback',
            GenerateFeedback(
              id: id,
              message: GenerateValidationMessages.vehicle,
              kind: GenerateFeedbackKind.warning,
            ),
          ),
      ],
      verify: (_) => expect(saved, isEmpty),
    );
  }

  test('Validation keeps each mode priority and does not persist attempts', () {
    final cubit = make(
      initial: GenerateSelection(vehicleId: _initial.vehicleId),
    );
    addTearDown(cubit.close);
    cubit.submit(GenerateMode.styleBuilder);
    expect(
      cubit.state.feedback?.message,
      GenerateValidationMessages.styleChoice,
    );
    cubit.submit(GenerateMode.customEdit, description: '   ');
    expect(
      cubit.state.feedback?.message,
      GenerateValidationMessages.description,
    );
    cubit.submit(GenerateMode.detailEdit);
    expect(cubit.state.feedback?.message, GenerateValidationMessages.angle);
    expect(saved, isEmpty);
  });

  test(
    'Detail panel needs angle only; valid submits reach demo service',
    () async {
      final cubit = make(initial: const GenerateSelection());
      addTearDown(cubit.close);
      expect(cubit.canOpenDetailOptions(), isFalse);
      expect(cubit.state.feedback?.message, GenerateValidationMessages.angle);
      cubit.selectAngle('Front');
      expect(cubit.canOpenDetailOptions(), isTrue);
      cubit.selectVehicle(_initial.vehicleId);
      cubit.selectStyle('Klasik');
      final writes = saved.length;
      for (final mode in GenerateMode.values) {
        await cubit.submit(mode, description: 'Mat siyah');
        expect(cubit.state.generation.status, GenerationStatus.success);
        expect(cubit.state.feedback, isNull);
        cubit.consumeResult(cubit.state.generation.attemptId);
      }
      expect(saved.length, writes);
      expect(cubit.state.parts, isEmpty);
      expect(cubit.state.detailColor, '');
    },
  );

  test('Dismissal and later attempts do not reuse feedback identities', () {
    final cubit = make(initial: const GenerateSelection());
    addTearDown(cubit.close);
    cubit.submit(GenerateMode.styleBuilder);
    final first = cubit.state.feedback!;
    cubit.dismissFeedback();
    expect(cubit.state.feedback, isNull);
    cubit.submit(GenerateMode.styleBuilder);
    expect(cubit.state.feedback?.id, greaterThan(first.id));
    cubit.selectVehicle(_initial.vehicleId);
    expect(cubit.state.feedback, isNull);
    expect(saved, hasLength(1));
    expect(saved.single.toJson().containsKey('feedback'), isFalse);
  });

  test('Rapid changes create independent, ordered persistence snapshots', () {
    final cubit = make();
    addTearDown(cubit.close);
    cubit.selectParts({'Spoiler': 2});
    cubit.selectAngle('Front');
    cubit.selectStyleColor('Mor');
    expect(saved, hasLength(3));
    expect(saved[0].parts, {'Spoiler': 2});
    expect(saved[0].angle, 'Rear');
    expect(saved[1].parts, isEmpty);
    expect(saved[1].color, _initial.color);
    expect(saved[2].color, 'Mor');
    expect(
      GenerateSelection.fromJson(saved.last.toJson()).toJson(),
      saved.last.toJson(),
    );
  });

  test('Validator is injected rather than looked up through global state', () {
    final cubit = GenerateCubit(
      generationService: FakeGenerationService(delay: Duration.zero),
      suggestions: GenerateSuggestions(random: SequenceRandom([])),
      validator: _RejectingValidator(),
    );
    addTearDown(cubit.close);
    cubit.submit(GenerateMode.styleBuilder);
    expect(cubit.state.feedback?.message, 'Injected validation');
  });

  test(
    'Closed Cubit ignores late actions without saving or consuming Random',
    () async {
      final random = SequenceRandom([]);
      final cubit = GenerateCubit(
        generationService: FakeGenerationService(delay: Duration.zero),
        initialSelection: _initial,
        suggestions: GenerateSuggestions(random: random),
        onApplied: saved.add,
      );
      final before = cubit.state;
      await cubit.close();
      cubit.selectVehicle('');
      cubit.selectParts({'Spoiler': 2});
      cubit.suggestIdea(GenerateMode.detailEdit);
      cubit.submit(GenerateMode.customEdit);
      cubit.dismissFeedback();
      expect(cubit.canOpenDetailOptions(), isFalse);
      expect(cubit.state, before);
      expect(saved, isEmpty);
      expect(random.bounds, isEmpty);
    },
  );
}
