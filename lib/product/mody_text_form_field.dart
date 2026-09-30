import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/color_items.dart';

// Controller'ın sahibi ekran; bu widget yalnızca alanın görünümünü yönetir.
class ModyTextFormField extends StatelessWidget {
  const ModyTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      expands: true,
      maxLines: null,
      minLines: null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textAlignVertical: TextAlignVertical.top,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: ColorItems.secondaryText),
        border: InputBorder.none,
        errorMaxLines: 3,
        contentPadding: const EdgeInsets.only(right: 48),
      ),
    );
  }
}
