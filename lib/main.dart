import 'package:flutter/material.dart';
import 'package:perasoft_staj/demos/mody_home_view.dart';
import 'package:perasoft_staj/product/color_items.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData.dark();
    final textTheme = darkTheme.textTheme.apply(
      bodyColor: ColorItems.primaryText,
      displayColor: ColorItems.primaryText,
    );

    return MaterialApp(
      title: 'Mody AI',
      debugShowCheckedModeBanner: false,
      theme: darkTheme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: textTheme.copyWith(
          titleLarge: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          titleMedium: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          labelLarge: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const ModyHomeView(),
    );
  }
}
