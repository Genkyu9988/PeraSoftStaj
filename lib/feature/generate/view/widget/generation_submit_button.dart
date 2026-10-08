import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perasoft_staj/feature/generate/view_model/generate_cubit.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generate_state.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';

class GenerationSubmitButton extends StatelessWidget {
  const GenerationSubmitButton({
    super.key,
    required this.title,
    required this.onPressed,
  });
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<GenerateCubit, GenerateState, bool>(
        selector: (state) => state.generation.blocksForm,
        builder: (context, blocked) => ModyActionButton(
          title: title,
          onPressed: blocked ? null : onPressed,
          appearance: ModyButtonAppearance.gradient,
          icon: Icons.auto_awesome,
        ),
      );
}
