import 'package:perasoft_staj/product/service/generation/fake_generation_service.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'package:perasoft_staj/product/service/backend/mody_api_client.dart';
import 'cloudflare_generation_service.dart';

bool get realColorEnabled =>
    const bool.fromEnvironment('MODY_REAL_AI') &&
    const String.fromEnvironment('MODY_DATA_SOURCE', defaultValue: 'django') ==
        'django';

GenerationService createGenerationService() {
  final demo = createDemoGenerationService();
  if (!realColorEnabled) return demo;
  return CloudflareGenerationService(
    client: ModyApiClient(
      baseUrl: const String.fromEnvironment(
        'MODY_API_URL',
        defaultValue: 'http://10.0.2.2:8765',
      ),
      token: const String.fromEnvironment('MODY_API_TOKEN'),
      timeout: const Duration(seconds: 120),
    ),
    demo: demo,
  );
}

/// Each default editor session owns its deterministic demo scenario.
GenerationService createDemoGenerationService() => FakeGenerationService(
  failuresBeforeSuccess: const bool.fromEnvironment('MODY_DEMO_FAIL_FIRST')
      ? 1
      : 0,
);
