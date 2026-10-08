import 'dart:async';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';

/// Each request is completed explicitly; no network or real-time sleeps.
class ControlledGenerationService implements GenerationService {
  final requests = <GenerationInput>[];
  final pending = <Completer<GenerationResult>>[];

  @override
  Future<GenerationResult> generate(GenerationInput request) {
    requests.add(request);
    final completer = Completer<GenerationResult>();
    pending.add(completer);
    return completer.future;
  }

  void succeed([int index = 0]) => pending[index].complete(
    DemoGenerationResult(
      request: requests[index],
      originalImagePath: VehicleCatalog.find(
        requests[index].vehicleId,
      )!.imagePath,
    ),
  );

  void fail([int index = 0, Object? error]) => pending[index].completeError(
    error ?? const GenerationException(GenerationFailureKind.demo),
  );
}
