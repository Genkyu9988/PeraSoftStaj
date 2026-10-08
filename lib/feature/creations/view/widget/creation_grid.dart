import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';

/// Presentation only: no services, persistence or navigation in a card.
class CreationGrid extends StatelessWidget {
  const CreationGrid({
    super.key,
    required this.records,
    required this.onSelected,
    this.selectedId,
    this.emptyMessage = 'Henüz oluşturulmuş bir görsel yok.',
  });
  final List<CreationRecord> records;
  final ValueChanged<CreationRecord> onSelected;
  final String? selectedId;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(emptyMessage, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = scale > 1.4 || constraints.maxWidth < 280
            ? 1
            : constraints.maxWidth >= 600
            ? 3
            : 2;
        return GridView.builder(
          key: const Key('creationGrid'),
          padding: const EdgeInsets.all(8),
          itemCount: records.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 112 + 132 * scale,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) => _CreationCard(
            record: records[index],
            selected: selectedId == records[index].id,
            onTap: () => onSelected(records[index]),
          ),
        );
      },
    );
  }
}

class _CreationCard extends StatelessWidget {
  const _CreationCard({
    required this.record,
    required this.selected,
    required this.onTap,
  });
  final CreationRecord record;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final vehicle = VehicleCatalog.find(record.vehicleId)!.label;
    final date = record.createdAt.toLocal();
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final badge = record.isVideoDemo
        ? 'Video demosu • Orijinal fotoğraf'
        : 'Demo • Orijinal fotoğraf';
    return Semantics(
      selected: selected,
      label: '${record.source}, ${record.title}, $vehicle, $badge, $dateLabel',
      child: Material(
        color: ColorItems.cardBackground,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? ColorItems.primaryBlue : ColorItems.softBorder,
            width: 2,
          ),
        ),
        child: InkWell(
          key: ValueKey('creation-${record.id}'),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ModyAssetImage(
                  path: record.result.originalImagePath,
                  semanticLabel: 'Orijinal araç; AI ile üretilmedi',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      vehicle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorItems.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ColorItems.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
