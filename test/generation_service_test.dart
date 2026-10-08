import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/fake_generation_service.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';

void main() {
  for (final mode in GenerateMode.values) {
    test('Fake $mode returns the selected ORIGINAL local image', () async {
      final service = FakeGenerationService(delay: Duration.zero);
      for (final vehicle in VehicleCatalog.all) {
        final request = GenerationRequest(
          mode: mode,
          vehicleId: vehicle.id,
          style: mode == GenerateMode.styleBuilder ? 'Sportif' : '',
          description: mode == GenerateMode.customEdit ? 'Yeni jant' : '',
          angle: mode == GenerateMode.detailEdit ? 'Rear' : '',
        );
        final result = await service.generate(request);
        expect(result.request, same(request));
        expect(result.originalImagePath, vehicle.imagePath);
      }
    });
  }

  test(
    'Failure scenario is explicit and succeeds after configured failures',
    () async {
      final service = FakeGenerationService(
        delay: Duration.zero,
        failuresBeforeSuccess: 1,
      );
      final request = GenerationRequest(
        mode: GenerateMode.styleBuilder,
        vehicleId: 'mustang_classic',
        color: 'Mavi',
      );
      await expectLater(
        service.generate(request),
        throwsA(
          isA<GenerationException>().having(
            (e) => e.kind,
            'kind',
            GenerationFailureKind.demo,
          ),
        ),
      );
      expect(await service.generate(request), isA<GenerationResult>());
      expect(await service.generate(request), isA<GenerationResult>());
    },
  );

  test(
    'Unknown vehicle has a typed failure, never a made-up fallback result',
    () async {
      await expectLater(
        FakeGenerationService(delay: Duration.zero).generate(
          GenerationRequest(
            mode: GenerateMode.customEdit,
            vehicleId: 'unknown',
          ),
        ),
        throwsA(
          isA<GenerationException>().having(
            (e) => e.kind,
            'kind',
            GenerationFailureKind.unavailable,
          ),
        ),
      );
    },
  );

  test(
    'Request detaches parts, exposes immutable data and preserves order',
    () {
      final parts = {'Spoiler': 1, 'Exhaust': 2};
      final request = GenerationRequest(
        mode: GenerateMode.detailEdit,
        vehicleId: 'mustang_classic',
        parts: parts,
      );
      parts.clear();
      expect(request.parts, {'Spoiler': 1, 'Exhaust': 2});
      expect(() => request.parts.clear(), throwsUnsupportedError);
      expect(
        request,
        isNot(
          GenerationRequest(
            mode: request.mode,
            vehicleId: request.vehicleId,
            parts: {'Exhaust': 2, 'Spoiler': 1},
          ),
        ),
      );
    },
  );
}
