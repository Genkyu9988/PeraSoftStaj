import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/widget/mody_warning_content.dart';

// Sadece sunum: hangi kuralın geçersiz olduğunu çağıran doğrulayıcı belirler.
class ModyFeedback {
  ModyFeedback._();

  static void warning(BuildContext context, String message) {
    _show(
      context,
      SnackBar(
        key: const Key('generateWarning'),
        backgroundColor: ColorItems.warningRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: ModyWarningContent(message: message),
      ),
    );
  }

  static void message(BuildContext context, String message) =>
      _show(context, SnackBar(content: Text(message)));

  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..removeCurrentSnackBar();
  }

  static void _show(BuildContext context, SnackBar snackBar) {
    // Hızlı tekrar basışlarında eski uyarılar kuyrukta birikmesin.
    dismiss(context);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
