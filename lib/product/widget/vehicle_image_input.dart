import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/widget/selection_image_box.dart';

// Catalog lookup stays outside the reusable visual component.
class VehicleImageInput extends StatelessWidget {
  const VehicleImageInput({
    super.key,
    required this.selectedId,
    required this.onSelect,
    required this.onClear,
    this.height = 160,
    this.footer,
  });

  final String selectedId;
  final VoidCallback onSelect;
  final VoidCallback onClear;
  final double height;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final vehicle = VehicleCatalog.find(selectedId);
    return SelectionImageBox(
      imagePath: vehicle?.imagePath,
      semanticLabel: vehicle == null ? '' : 'Seçilen araç: ${vehicle.label}',
      inputKey: const Key('vehicleInput'),
      imageKey: const Key('selectedVehicleImage'),
      clearLabel: 'Araç seçimini kaldır',
      onSelect: onSelect,
      onClear: onClear,
      height: height,
      footer: footer,
      emptyChild: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Resim Seçin'), SizedBox(height: 8), Icon(Icons.add)],
      ),
    );
  }
}
