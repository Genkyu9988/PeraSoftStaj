import 'package:perasoft_staj/product/service/generation/fake_generation_service.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';

/// Each default editor session owns its deterministic demo scenario.
GenerationService createDemoGenerationService() => FakeGenerationService(
  failuresBeforeSuccess: const bool.fromEnvironment('MODY_DEMO_FAIL_FIRST')
      ? 1
      : 0,
);
