import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';

enum ModyButtonAppearance { primary, gradient, themed }

// İşlem ve doğrulama ekranda kalır. null callback, pasif buton demektir.
class ModyActionButton extends StatelessWidget {
  const ModyActionButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.appearance = ModyButtonAppearance.primary,
    this.icon,
  });

  final String title;
  final VoidCallback? onPressed;
  final ModyButtonAppearance appearance;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final gradient = appearance == ModyButtonAppearance.gradient;
    final enabled = onPressed != null;
    final label = Text(
      title,
      textAlign: TextAlign.center,
      style: gradient
          ? Theme.of(context).textTheme.titleMedium?.copyWith(
              color: enabled
                  ? ColorItems.primaryText
                  : ColorItems.secondaryText,
            )
          : null,
    );
    final content = icon == null
        ? label
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: label),
              const SizedBox(width: SizeItems.normalSpace),
              Icon(icon, size: SizeItems.normalIcon),
            ],
          );

    if (gradient) {
      return Container(
        constraints: const BoxConstraints(minHeight: 60),
        width: double.infinity,
        decoration: BoxDecoration(
          color: enabled ? null : ColorItems.softBorder,
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xff12C8E9), Color(0xff087BFF)],
                )
              : null,
          borderRadius: BorderRadius.circular(60),
          boxShadow: enabled
              ? const [
                  BoxShadow(
                    color: Color(0xff0B3159),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            shape: const StadiumBorder(),
            foregroundColor: ColorItems.primaryText,
            disabledForegroundColor: ColorItems.secondaryText,
          ),
          child: content,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: appearance == ModyButtonAppearance.primary
            ? ElevatedButton.styleFrom(
                backgroundColor: ColorItems.primaryBlue,
                foregroundColor: ColorItems.primaryText,
              )
            : null,
        child: content,
      ),
    );
  }
}
