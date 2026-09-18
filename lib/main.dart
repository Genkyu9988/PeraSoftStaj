import 'package:flutter/material.dart';
import 'package:perasoft_staj/demos/mody_home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.contentIndex = 0, this.panelIndex = 0});

  final int contentIndex;
  final int panelIndex;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mody AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: ModyHomeView(contentIndex: contentIndex, panelIndex: panelIndex),
    );
  }
}
