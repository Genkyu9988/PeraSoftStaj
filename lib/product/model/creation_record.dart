import 'package:equatable/equatable.dart';
import 'package:perasoft_staj/product/model/ai_video_template.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/generation_input_resolver.dart';

/// A completed demo operation, NOT a generated image or playable video.
final class CreationRecord extends Equatable {
  const CreationRecord({
    required this.id,
    required this.createdAt,
    required this.result,
  });

  final String id;
  final DateTime createdAt;
  final DemoGenerationResult result;
  String get vehicleId => result.request.vehicleId;
  bool get isVideoDemo => result.request is AiVideoGenerationRequest;
  String get source => switch (result.request) {
    GenerationRequest() => 'Üret',
    ExploreGenerationRequest() => 'Explore',
    AiVideoGenerationRequest() => 'AI Video',
  };
  String get title => switch (result.request) {
    GenerationRequest(:final mode) => switch (mode) {
      GenerateMode.styleBuilder => 'Style Builder',
      GenerateMode.customEdit => 'Custom Edit',
      GenerateMode.detailEdit => 'Detail Edit',
    },
    ExploreGenerationRequest(:final operation) => operation.title,
    AiVideoGenerationRequest(:final template) => template.title,
  };

  Map<String, Object?> toJson() => {
    'id': id,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'kind': 'demo',
    'originalImagePath': result.originalImagePath,
    'input': switch (result.request) {
      GenerationRequest r => {
        'type': 'generate',
        'vehicleId': r.vehicleId,
        'mode': r.mode.name,
        'style': r.style,
        'extra': r.extra,
        'color': r.color,
        'angle': r.angle,
        'parts': r.parts,
        'description': r.description,
      },
      ExploreGenerationRequest r => {
        'type': 'explore',
        'vehicleId': r.vehicleId,
        'operation': r.operation.name,
        'optionId': r.optionId,
        'color': r.color,
        'referenceId': r.referenceId,
      },
      AiVideoGenerationRequest r => {
        'type': 'video',
        'vehicleId': r.vehicleId,
        'template': r.template.name,
      },
    },
  };

  factory CreationRecord.fromJson(Map<String, dynamic> json) {
    final id = _string(json, 'id');
    final date = DateTime.tryParse(_string(json, 'createdAt'));
    if (id.isEmpty || date == null || json['kind'] != 'demo') {
      throw const FormatException('Geçersiz demo kaydı');
    }
    final input = json['input'];
    if (input is! Map<String, dynamic>) {
      throw const FormatException('Geçersiz işlem');
    }
    final vehicleId = _string(input, 'vehicleId');
    final GenerationInput request = switch (_string(input, 'type')) {
      'generate' => GenerationRequest(
        mode: _enum(GenerateMode.values, _string(input, 'mode')),
        vehicleId: vehicleId,
        style: _string(input, 'style'),
        extra: _string(input, 'extra'),
        color: _string(input, 'color'),
        angle: _string(input, 'angle'),
        parts: _parts(input['parts']),
        description: _string(input, 'description'),
      ),
      'explore' => ExploreGenerationRequest(
        operation: _enum(ExploreOperation.values, _string(input, 'operation')),
        vehicleId: vehicleId,
        optionId: _string(input, 'optionId'),
        color: _string(input, 'color'),
        referenceId: _string(input, 'referenceId'),
      ),
      'video' => AiVideoGenerationRequest(
        template: _enum(AiVideoTemplate.values, _string(input, 'template')),
        vehicleId: vehicleId,
      ),
      _ => throw const FormatException('Bilinmeyen işlem'),
    };
    final path = _string(json, 'originalImagePath');
    // Do not restore unknown assets or silently repair a historical request.
    try {
      final plan = const GenerationInputResolver().resolve(request);
      if (path != plan.vehicle.assetPath) {
        throw const FormatException('Geçersiz orijinal görsel');
      }
    } on GenerationInputException {
      throw const FormatException('Geçersiz geçmiş seçimi');
    }
    return CreationRecord(
      id: id,
      createdAt: date.toUtc(),
      result: DemoGenerationResult(request: request, originalImagePath: path),
    );
  }

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) throw FormatException('Geçersiz alan: $key');
    return value;
  }

  static T _enum<T extends Enum>(List<T> values, String name) =>
      values.firstWhere(
        (value) => value.name == name,
        orElse: () => throw const FormatException('Bilinmeyen seçim'),
      );

  static Map<String, int> _parts(Object? value) {
    if (value is! Map<String, dynamic> || value.values.any((v) => v is! int)) {
      throw const FormatException('Geçersiz parça seçimi');
    }
    return value.cast<String, int>();
  }

  @override
  List<Object> get props => [id, createdAt, result];
}
