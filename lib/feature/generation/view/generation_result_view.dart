import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:flutter/material.dart';
import 'package:perasoft_staj/feature/creations/view/widget/history_persistence_notice.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';

class GenerationResultView extends StatelessWidget {
  const GenerationResultView({
    super.key,
    required this.result,
    this.fromHistory = false,
  });
  final GenerationResult result;
  final bool fromHistory;

  @override
  Widget build(BuildContext context) {
    // Exhaustive: adding real media cannot silently render it as a demo photo.
    final originalImagePath = result.displayImagePath;
    final isReal = result is AiImageGenerationResult;
    final summary = _summary(result.request);
    final isVideo = result.request is AiVideoGenerationRequest;
    return Scaffold(
      key: const Key('generationResultPage'),
      appBar: AppBar(title: Text(isReal ? 'AI sonucu' : 'Demo sonuç')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const HistoryPersistenceNotice(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorItems.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isReal
                              ? 'AI ile düzenlendi'
                              : 'Demo sonuç — AI ile üretilmedi',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isReal
                              ? 'Cloudflare ile görsel düzenleme denemesi. AI diğer ayrıntıları da değiştirmiş olabilir.'
                              : isVideo
                              ? 'Aşağıdaki fotoğraf seçtiğiniz orijinal araçtır. Seçilen şablon uygulanmadı; gerçek video üretilmedi.'
                              : 'Aşağıdaki fotoğraf seçtiğiniz orijinal araçtır. İstenen değişiklikler görsele uygulanmadı.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ModyAssetImage(
                        path: originalImagePath,
                        semanticLabel: isReal
                            ? 'AI ile düzenlenen araç'
                            : 'Seçilen orijinal araç; AI ile üretilmedi',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Gönderilen seçimler',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  for (final entry in summary.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(entry.value.isEmpty ? 'Seçilmedi' : entry.value),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  ModyActionButton(
                    title: fromHistory ? 'Garaja Dön' : 'Seçimlere Dön',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Map<String, String> _summary(GenerationInput input) {
  // Exhaustiveness makes new request types require an explicit summary.
  return switch (input) {
    AiVideoGenerationRequest request => {
      'Kaynak': 'AI Video',
      'Şablon': request.template.title,
      'Araç':
          VehicleCatalog.find(request.vehicleId)?.label ?? request.vehicleId,
    },
    ExploreGenerationRequest request => _exploreSummary(request),
    GenerationRequest request => _generateSummary(request),
  };
}

Map<String, String> _exploreSummary(ExploreGenerationRequest request) {
  return {
    'Kaynak': 'Explore',
    'İşlem': request.operation.title,
    'Araç': VehicleCatalog.find(request.vehicleId)?.label ?? request.vehicleId,
    if (request.optionId.isNotEmpty)
      'Hedef':
          CarModCatalog.find(
            request.operation.title,
            request.optionId,
          )?.label ??
          request.optionId,
    if (request.color.isNotEmpty) 'Renk': request.color,
    if (request.referenceId.isNotEmpty)
      'Referans':
          ReferenceCarCatalog.find(request.referenceId)?.label ??
          request.referenceId,
  };
}

Map<String, String> _generateSummary(GenerationRequest request) {
  final modeLabel = switch (request.mode) {
    GenerateMode.styleBuilder => 'Style Builder',
    GenerateMode.customEdit => 'Custom Edit',
    GenerateMode.detailEdit => 'Detail Edit',
  };
  return <String, String>{
    'Mod': modeLabel,
    'Araç': VehicleCatalog.find(request.vehicleId)?.label ?? request.vehicleId,
    if (request.mode == GenerateMode.styleBuilder) ...{
      'Stil': request.style,
      'Ekstra': request.extra,
      'Renk': request.color,
    },
    if (request.mode == GenerateMode.customEdit)
      'Açıklama': request.description,
    if (request.mode == GenerateMode.detailEdit) ...{
      'Açı': request.angle,
      'Parçalar': request.parts.entries
          .map((p) => '${p.key} ${p.value + 1}')
          .join(', '),
      'Renk': request.color,
    },
  };
}
