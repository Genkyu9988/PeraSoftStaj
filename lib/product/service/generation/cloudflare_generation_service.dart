import 'dart:math';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/backend/mody_api_client.dart';
import 'generation_service.dart';

/// Calls our Django API only. The provider credential never enters Flutter.
class CloudflareGenerationService implements GenerationService {
  CloudflareGenerationService({required this.client, required this.demo});
  final ModyApiClient client;
  final GenerationService demo;
  ExploreGenerationRequest? _request;
  String? _id;

  @override
  Future<GenerationResult> generate(GenerationInput request) async {
    if (request is! ExploreGenerationRequest ||
        (request.operation != ExploreOperation.changeColor &&
            request.operation != ExploreOperation.spoiler)) {
      return demo.generate(request);
    }
    if (_request != request || _id == null) {
      _request = request;
      final random = Random.secure();
      _id = List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
    }
    try {
      final response = await client.request(
        'POST',
        request.operation == ExploreOperation.spoiler
            ? 'ai/spoiler'
            : 'ai/change-color',
        body: {
          'id': _id,
          'vehicleId': request.vehicleId,
          if (request.operation == ExploreOperation.spoiler)
            'optionId': request.optionId
          else
            'color': request.color,
        },
      );
      final record = CreationRecord.fromJson(
        Map<String, dynamic>.from(response.data['record'] as Map),
      );
      if (record.result is! AiImageGenerationResult ||
          record.result.request != request ||
          record.id != 'ai-$_id') {
        throw const GenerationException(GenerationFailureKind.unavailable);
      }
      _id = null;
      return record.result;
    } on BackendException catch (error) {
      // Transport/unknown failures retain the key: retry cannot duplicate inference.
      // Definitive provider failure permits the user's explicit retry as a new attempt.
      if (error.status == 502) _id = null;
      throw GenerationException(
        error.status == 429
            ? GenerationFailureKind.limit
            : GenerationFailureKind.unavailable,
      );
    }
  }
}
