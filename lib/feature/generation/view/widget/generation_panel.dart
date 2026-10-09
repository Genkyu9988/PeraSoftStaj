import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/service/generation/generation_service_factory.dart';
import 'package:perasoft_staj/feature/generation/view_model/generation_activity.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';

/// Presentation only, following lessons 4/5: data in, callbacks out.
class GenerationPanel extends StatelessWidget {
  const GenerationPanel({
    super.key,
    required this.activity,
    required this.onRetry,
    required this.onDismiss,
    required this.onShowResult,
  });
  final GenerationActivity activity;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;
  final VoidCallback onShowResult;
  @override
  Widget build(BuildContext context) {
    if (!activity.blocksForm) return const SizedBox.shrink();
    final loading = activity.isLoading;
    final failed = activity.status == GenerationStatus.failure;
    final isReal =
        realColorEnabled &&
        activity.request is ExploreGenerationRequest &&
        const {
          ExploreOperation.changeColor,
          ExploreOperation.spoiler,
        }.contains((activity.request! as ExploreGenerationRequest).operation);
    final loadingMessage = isReal
        ? 'Hazır araç fotoğrafı Cloudflare ile düzenleniyor. Vazgeçmek gönderilmiş API çağrısını durdurmaz; deneme sayılır.'
        : activity.request is AiVideoGenerationRequest
        ? 'Bu bir akış denemesidir. Gerçek video üretilmiyor.'
        : 'Bu bir akış denemesidir. Gerçek AI üretimi yapılmıyor.';
    final message = switch (activity.failure) {
      GenerationFailureKind.limit =>
        '15 ortak deneme sınırına ulaşıldı veya başka bir işlem sürüyor. Ücretli kullanıma geçilmedi.',
      GenerationFailureKind.demo =>
        'Demo hata senaryosu çalıştırıldı. Aynı seçimlerle tekrar deneyebilirsiniz.',
      GenerationFailureKind.timeout =>
        'İşlem zaman aşımına uğradı. Seçimleriniz korundu; tekrar deneyebilirsiniz.',
      _ =>
        'İşlem tamamlanamadı. Seçimleriniz korundu; tekrar deneyebilirsiniz.',
    };
    return ColoredBox(
      key: const Key('generationOverlay'),
      color: Colors.black87,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Material(
                color: ColorItems.cardBackground,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (loading)
                        CircularProgressIndicator(
                          semanticsLabel: isReal
                              ? 'AI hazırlanıyor'
                              : 'Demo hazırlanıyor',
                        )
                      else
                        Icon(
                          failed
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          size: 40,
                          color: failed
                              ? ColorItems.warningRed
                              : ColorItems.primaryBlue,
                        ),
                      const SizedBox(height: 20),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          loading
                              ? (isReal
                                    ? 'AI görseli hazırlanıyor…'
                                    : 'Demo hazırlanıyor…')
                              : failed
                              ? 'İşlem tamamlanamadı'
                              : (isReal
                                    ? 'AI sonucu hazır'
                                    : 'Demo sonucu hazır'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loading
                            ? loadingMessage
                            : failed
                            ? message
                            : 'Sonucu açıp gönderdiğiniz seçimleri inceleyebilirsiniz.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (failed)
                        ModyActionButton(
                          key: const Key('retryGeneration'),
                          title: 'Tekrar Dene',
                          onPressed: onRetry,
                        ),
                      if (activity.status == GenerationStatus.success)
                        ModyActionButton(
                          key: const Key('showGenerationResult'),
                          title: isReal
                              ? 'AI Sonucunu Gör'
                              : 'Demo Sonucunu Gör',
                          onPressed: onShowResult,
                        ),
                      TextButton(
                        key: const Key('dismissGeneration'),
                        onPressed: onDismiss,
                        child: Text(loading ? 'Vazgeç' : 'Seçimlere Dön'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GenerationInteractionGuard extends StatelessWidget {
  const GenerationInteractionGuard({
    super.key,
    required this.blocked,
    required this.child,
  });
  final bool blocked;
  final Widget child;
  @override
  Widget build(BuildContext context) => ExcludeFocus(
    excluding: blocked,
    child: ExcludeSemantics(
      excluding: blocked,
      child: AbsorbPointer(absorbing: blocked, child: child),
    ),
  );
}
