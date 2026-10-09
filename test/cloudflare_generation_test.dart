import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/backend/mody_api_client.dart';
import 'package:perasoft_staj/product/service/generation/cloudflare_generation_service.dart';
import 'package:perasoft_staj/product/service/generation/fake_generation_service.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'package:perasoft_staj/feature/creations/view_model/creation_history_cubit.dart';
import 'package:perasoft_staj/product/cache/creation_repository.dart';

const request = ExploreGenerationRequest(
  operation: ExploreOperation.changeColor,
  vehicleId: 'mustang_classic',
  color: 'Mavi',
);

Map<String, dynamic> record(String id) => {
  'id': 'ai-$id',
  'createdAt': '2026-10-09T12:00:00.123456Z',
  'kind': 'aiImage',
  'originalImagePath': VehicleCatalog.find(request.vehicleId)!.imagePath,
  'outputImagePath': 'mody-media:$id',
  'input': {
    'type': 'explore',
    'vehicleId': request.vehicleId,
    'operation': 'changeColor',
    'color': 'Mavi',
    'optionId': '',
    'referenceId': '',
  },
};

CloudflareGenerationService service(
  Future<http.Response> Function(http.Request) handler,
) => CloudflareGenerationService(
  client: ModyApiClient(
    baseUrl: 'http://127.0.0.1:8765',
    token: 'test-backend-token',
    client: MockClient(handler),
  ),
  demo: FakeGenerationService(delay: Duration.zero),
);

void main() {
  test(
    'spoiler sends selected catalog part and round trips real history',
    () async {
      const spoiler = ExploreGenerationRequest(
        operation: ExploreOperation.spoiler,
        vehicleId: 'mustang_classic',
        optionId: 'spoiler.race_wing',
      );
      final api = service((r) async {
        expect(r.url.path, '/api/v1/ai/spoiler');
        final body = jsonDecode(r.body) as Map<String, dynamic>;
        expect(body.keys.toSet(), {'id', 'vehicleId', 'optionId'});
        expect(body['optionId'], spoiler.optionId);
        final raw = record(body['id'] as String);
      (raw['input'] as Map<String, String>).addAll({
          'operation': 'spoiler',
          'optionId': spoiler.optionId,
          'color': '',
        });
        return http.Response(jsonEncode({'record': raw}), 200);
      });
      final result = await api.generate(spoiler);
      expect(result, isA<AiImageGenerationResult>());
      expect(result.request, spoiler);
      api.client.close();
    },
  );

  test('real result round trips and publishes only once in history', () async {
    final api = service((r) async {
      expect(r.headers['Authorization'], 'Bearer test-backend-token');
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      expect(body.keys.toSet(), {'id', 'vehicleId', 'color'});
      return http.Response(
        jsonEncode({'record': record(body['id'] as String)}),
        200,
      );
    });
    final result = await api.generate(request);
    expect(result, isA<AiImageGenerationResult>());
    expect(result.displayImagePath, isNot(result.originalImagePath));
    final history = CreationHistoryCubit(
      repository: MemoryCreationRepository(),
    );
    await history.load();
    history.record(result);
    history.record(result);
    await history.pendingSave;
    expect(history.state.records, hasLength(1));
    final saved = history.state.records.single;
    expect(CreationRecord.fromJson(saved.toJson()), saved);
    await history.close();
    api.client.close();
  });

  test('other operations still use fake service without HTTP', () async {
    final api = service((_) async => throw StateError('Must not call API'));
    final result = await api.generate(
      const ExploreGenerationRequest(
        operation: ExploreOperation.american,
        vehicleId: 'mustang_classic',
      ),
    );
    expect(result, isA<DemoGenerationResult>());
    api.client.close();
  });

  test('unknown transport failure reuses ID on explicit retry', () async {
    final ids = <String>[];
    final api = service((r) async {
      ids.add((jsonDecode(r.body) as Map)['id'] as String);
      if (ids.length == 1) throw http.ClientException('offline');
      return http.Response(jsonEncode({'record': record(ids.last)}), 200);
    });
    await expectLater(
      api.generate(request),
      throwsA(isA<GenerationException>()),
    );
    await api.generate(request);
    expect(ids[0], ids[1]);
    api.client.close();
  });

  test(
    'definitive failed attempt only retries when explicitly requested',
    () async {
      final ids = <String>[];
      final api = service((r) async {
        ids.add((jsonDecode(r.body) as Map)['id'] as String);
        return http.Response('{}', 502);
      });
      await expectLater(
        api.generate(request),
        throwsA(isA<GenerationException>()),
      );
      expect(ids, hasLength(1));
      await expectLater(
        api.generate(request),
        throwsA(isA<GenerationException>()),
      );
      expect(ids[0], isNot(ids[1]));
      api.client.close();
    },
  );

  test('limit is typed and does not masquerade as a demo', () async {
    final api = service((_) async => http.Response('{}', 429));
    await expectLater(
      api.generate(request),
      throwsA(
        isA<GenerationException>().having(
          (e) => e.kind,
          'kind',
          GenerationFailureKind.limit,
        ),
      ),
    );
    api.client.close();
  });

  test('forged media URL is rejected', () {
    final raw = record('a' * 32)
      ..['outputImagePath'] = 'https://example.com/a.jpg';
    expect(() => CreationRecord.fromJson(raw), throwsFormatException);
  });
}
