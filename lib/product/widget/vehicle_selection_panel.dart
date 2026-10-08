import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perasoft_staj/feature/creations/view_model/creation_history_cubit.dart';
import 'package:perasoft_staj/feature/creations/view/widget/creation_grid.dart';
import 'package:perasoft_staj/feature/creations/view/widget/history_persistence_notice.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/widget/selection_sheet.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';

class VehicleSelectionPanel extends StatefulWidget {
  const VehicleSelectionPanel({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onApply,
  });
  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onApply;

  @override
  State<VehicleSelectionPanel> createState() => _VehicleSelectionPanelState();
}

class _VehicleSelectionPanelState extends State<VehicleSelectionPanel> {
  bool _creations = false;
  String? _selectedCreationId;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CreationHistoryCubit, CreationHistoryState>(
        builder: (context, history) => OptionsPanelFrame(
          title: 'Resim Seçin',
          child: Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    for (final creations in [false, true])
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: _creations == creations
                                ? ColorItems.sampleColor
                                : Colors.transparent,
                          ),
                          onPressed: () =>
                              setState(() => _creations = creations),
                          child: Text(
                            creations ? 'Your Creations' : 'Hazır Arabalar',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_creations) const HistoryPersistenceNotice(),
                Expanded(
                  child: _creations
                      ? CreationGrid(
                          records: history.records,
                          selectedId: _selectedCreationId,
                          emptyMessage: history.loading
                              ? 'Geçmiş yükleniyor…'
                              : 'Henüz oluşturulmuş bir görsel yok.',
                          onSelected: (record) {
                            setState(() => _selectedCreationId = record.id);
                            widget.onSelected(record.vehicleId);
                          },
                        )
                      : GridView.builder(
                          itemCount: VehicleCatalog.all.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisExtent: 136,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemBuilder: (context, index) {
                            final vehicle = VehicleCatalog.all[index];
                            final selected = widget.selected == vehicle.id;
                            return Semantics(
                              selected: selected,
                              child: Material(
                                color: ColorItems.sampleColor,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: selected
                                        ? ColorItems.primaryBlue
                                        : ColorItems.softBorder,
                                    width: 2,
                                  ),
                                ),
                                child: InkWell(
                                  key: ValueKey('vehicle-${vehicle.id}'),
                                  onTap: () {
                                    setState(() => _selectedCreationId = null);
                                    widget.onSelected(vehicle.id);
                                  },
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ModyAssetImage(
                                            path: vehicle.imagePath,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Text(
                                          vehicle.label,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                ModyActionButton(
                  title: 'Uygula',
                  onPressed:
                      (!_creations ||
                              history.records.any(
                                (r) =>
                                    r.id == _selectedCreationId &&
                                    r.vehicleId == widget.selected,
                              )) &&
                          VehicleCatalog.find(widget.selected) != null
                      ? widget.onApply
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
}
