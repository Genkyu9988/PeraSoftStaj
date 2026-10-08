import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/sample_cars_area.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generation_submit_button.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generate_option_boxes.dart';

class DetailEditContent extends StatelessWidget {
  const DetailEditContent({
    super.key,
    required this.selectedVehicleId,
    required this.onVehicleSelected,
    required this.onPanelSelected,
    required this.selectedAngle,
    required this.selectedParts,
    required this.selectedColor,
    required this.onSubmit,
  });

  final String selectedVehicleId;
  final ValueChanged<String> onVehicleSelected;
  final void Function(int) onPanelSelected;
  final String selectedAngle;
  final String selectedParts;
  final String selectedColor;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: SizeItems.normalSpace),
          GenerateOptionBoxes(
            firstTitle: 'Açı',
            secondTitle: 'Ayarla',
            firstSelection: selectedAngle,
            secondSelection: selectedParts,
            colorSelection: selectedColor,
            onSelected: onPanelSelected,
          ),
          const SizedBox(height: SizeItems.smallSpace),
          SampleCarsArea(
            selectedId: selectedVehicleId,
            onSelected: onVehicleSelected,
          ),
          const SizedBox(height: SizeItems.largeSpace),
          GenerationSubmitButton(title: 'Modifiye Et', onPressed: onSubmit),
        ],
      ),
    );
  }
}
