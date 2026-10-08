import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perasoft_staj/feature/generate/view_model/generate_cubit.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generate_state.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generation_activity.dart';
import 'package:perasoft_staj/feature/generation/view/widget/generation_panel.dart';

/// Selector rebuilds the guard, not the existing form subtree.
class GenerationFormGuard extends StatelessWidget {
  const GenerationFormGuard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<GenerateCubit, GenerateState, bool>(
        selector: (state) => state.generation.blocksForm,
        builder: (context, blocked) =>
            GenerationInteractionGuard(blocked: blocked, child: child),
      );
}

class GenerationOverlay extends StatelessWidget {
  const GenerationOverlay({super.key, required this.onShowResult});
  final ValueChanged<GenerationActivity> onShowResult;
  @override
  Widget build(BuildContext context) =>
      BlocSelector<GenerateCubit, GenerateState, GenerationActivity>(
        selector: (state) => state.generation,
        builder: (context, activity) {
          final cubit = context.read<GenerateCubit>();
          return GenerationPanel(
            activity: activity,
            onRetry: cubit.retryGeneration,
            onDismiss: cubit.dismissGeneration,
            onShowResult: () => onShowResult(activity),
          );
        },
      );
}
