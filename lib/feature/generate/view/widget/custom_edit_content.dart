import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generation_submit_button.dart';
import 'package:perasoft_staj/product/widget/mody_text_form_field.dart';

class CustomEditContent extends StatelessWidget {
  const CustomEditContent({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onDescriptionChanged,
    required this.onSuggestDescription,
    required this.onClearDescription,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onSuggestDescription;
  final VoidCallback onClearDescription;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: SizeItems.normalSpace),
          _DescriptionArea(
            controller: controller,
            onChanged: onDescriptionChanged,
            onSuggest: onSuggestDescription,
            onClear: onClearDescription,
          ),
          const SizedBox(height: SizeItems.normalSpace),
          GenerationSubmitButton(
            title: 'Arabamı Modifiye Et',
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _DescriptionArea extends StatelessWidget {
  const _DescriptionArea({
    required this.controller,
    required this.onChanged,
    required this.onSuggest,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSuggest;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.textScalerOf(context).scale(190),
      padding: PaddingItems.card,
      decoration: BoxDecoration(
        color: ColorItems.cardBackground,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: Border.all(color: ColorItems.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Modifikasyonunuzu tanımlayın',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) => value.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        key: const Key('clearDescription'),
                        tooltip: 'Açıklamayı temizle',
                        onPressed: onClear,
                        icon: const Icon(Icons.close),
                      ),
              ),
            ],
          ),
          const SizedBox(height: SizeItems.smallSpace),
          Expanded(
            child: Stack(
              children: [
                ModyTextFormField(
                  fieldKey: const Key('customEditDescriptionField'),
                  controller: controller,
                  onChanged: onChanged,
                  hintText: 'Örneğin: Spor görünümlü, koyu renkli bir araba...',
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _DescriptionIconArea(onPressed: onSuggest),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionIconArea extends StatelessWidget {
  const _DescriptionIconArea({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('suggestDescription'),
      tooltip: 'Modifikasyon fikri ver',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: ColorItems.primaryBlue,
        foregroundColor: ColorItems.primaryText,
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeItems.smallRadius),
        ),
      ),
      icon: const Icon(
        Icons.auto_awesome,
        color: ColorItems.primaryText,
        size: SizeItems.smallIcon,
      ),
    );
  }
}
