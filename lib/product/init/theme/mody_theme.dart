import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';

/// The existing app theme, shared without changing Flutter's other defaults.
abstract final class ModyTheme {
  static ThemeData dark() {
    final darkTheme = ThemeData.dark();
    final textTheme = darkTheme.textTheme.apply(
      bodyColor: ColorItems.primaryText,
      displayColor: ColorItems.primaryText,
    );

    return darkTheme.copyWith(
      scaffoldBackgroundColor: Colors.black,
      textTheme: textTheme.copyWith(
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        labelLarge: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
