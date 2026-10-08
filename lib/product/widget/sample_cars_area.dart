import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';

// Shared presentation; each screen owns its selection and persistence.
class SampleCarsArea extends StatelessWidget {
  const SampleCarsArea({super.key, this.onSelected, this.selectedId = ''});

  final ValueChanged<String>? onSelected;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Örnek Arabalar', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: SizeItems.smallSpace),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: VehicleCatalog.samples.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: SizeItems.normalSpace),
            itemBuilder: (context, index) => _SampleCar(
              path: VehicleCatalog.samples[index].imagePath,
              selected: selectedId == VehicleCatalog.samples[index].id,
              label: 'Örnek Araç ${index + 1}',
              onPressed: onSelected == null
                  ? null
                  : () => onSelected!(VehicleCatalog.samples[index].id),
            ),
          ),
        ),
      ],
    );
  }
}

class _SampleCar extends StatelessWidget {
  const _SampleCar({
    required this.path,
    required this.label,
    required this.selected,
    this.onPressed,
  });

  final bool selected;
  final String path;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: SizedBox(
      width: 72,
      child: Material(
        color: ColorItems.sampleColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeItems.normalRadius),
          side: BorderSide(
            color: selected ? ColorItems.primaryBlue : ColorItems.softBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Semantics(
          selected: selected,
          child: InkWell(
            onTap: onPressed,
            child: ModyAssetImage(path: path, semanticLabel: label),
          ),
        ),
      ),
    ),
  );
}
