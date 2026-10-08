import 'package:perasoft_staj/feature/generation/view_model/generation_activity.dart';
import 'package:perasoft_staj/feature/generation/view_model/generation_flow_cubit.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';

/// The shared detail view needs one form contract, not either concrete Cubit.
abstract class EditorGenerationCubit
    extends GenerationFlowCubit<GenerationActivity> {
  EditorGenerationCubit({
    required super.generationService,
    super.generationTimeout,
  }) : super(initialState: const GenerationActivity.idle());

  @override
  GenerationActivity get activity => state;
  @override
  void emitActivity(GenerationActivity activity) => emit(activity);

  String? submit({required String title, required ExploreSelection selection});
}
