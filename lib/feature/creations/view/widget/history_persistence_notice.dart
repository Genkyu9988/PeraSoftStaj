import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perasoft_staj/feature/creations/view_model/creation_history_cubit.dart';

/// A storage failure is not a generation failure; retain this session's records.
class HistoryPersistenceNotice extends StatelessWidget {
  const HistoryPersistenceNotice({super.key});
  @override
  Widget build(BuildContext context) {
    final history = context.read<CreationHistoryCubit?>();
    if (history == null) return const SizedBox.shrink();
    return BlocBuilder<CreationHistoryCubit, CreationHistoryState>(
      bloc: history,
      builder: (context, state) {
        if (!state.loadFailed && !state.saveFailed) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                state.loadFailed
                    ? 'Geçmiş okunamadı. Eski kayıtların üzerine yazılmadı; yeni demolar yalnız bu oturumda korunuyor.'
                    : 'Demo geçmişi cihaza kaydedilemedi. Kayıtlar bu oturumda korunuyor.',
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: state.loading || state.saving
                    ? null
                    : history.retryPersistence,
                child: const Text('Kaydı tekrar dene'),
              ),
            ],
          ),
        );
      },
    );
  }
}
