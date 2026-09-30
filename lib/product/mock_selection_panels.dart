import 'package:perasoft_staj/product/mody_action_button.dart';
import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/color_items.dart';
import 'package:perasoft_staj/product/layout_items.dart';
import 'package:perasoft_staj/product/mock_options.dart';
import 'package:perasoft_staj/product/selection_sheet.dart';

class MockImageSelectionPanel extends StatefulWidget {
  const MockImageSelectionPanel({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onApply,
  });
  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onApply;

  @override
  State<MockImageSelectionPanel> createState() =>
      _MockImageSelectionPanelState();
}

class _MockImageSelectionPanelState extends State<MockImageSelectionPanel> {
  late int _imageTab;
  @override
  void initState() {
    super.initState();
    _imageTab = widget.selected.startsWith('Mock Üretim') ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return OptionsPanelFrame(
      title: 'Resim Seçin',
      child: Expanded(
        child: Column(
          children: [
            Row(
              children: [
                for (var index = 0; index < 2; index++)
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: _imageTab == index
                            ? ColorItems.sampleColor
                            : Colors.transparent,
                      ),
                      onPressed: () => setState(() => _imageTab = index),
                      child: Text(
                        index == 0 ? 'Son Kullanılanlar' : 'Your Creations',
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SizeItems.smallSpace),
            if (widget.selected.isNotEmpty)
              Text(
                'Seçilen: ${widget.selected}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisExtent: 144,
                crossAxisSpacing: SizeItems.smallSpace,
                mainAxisSpacing: SizeItems.smallSpace,
                children: [
                  for (var index = 1; index <= 5; index++)
                    _choice(
                      '${_imageTab == 0 ? 'Mock Araç' : 'Mock Üretim'} $index',
                      widget.selected,
                      widget.onSelected,
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ModyActionButton(
                onPressed: widget.selected.isEmpty ? null : widget.onApply,
                title: 'Uygula',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MockOptionsSelectionPanel extends StatelessWidget {
  const MockOptionsSelectionPanel({
    super.key,
    required this.title,
    required this.selected,
    required this.onSelected,
    required this.onApply,
  });
  final String title;
  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onApply;
  @override
  Widget build(BuildContext context) {
    return OptionsPanelFrame(
      title: '$title seçin',
      child: Expanded(
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisExtent: 144,
                crossAxisSpacing: SizeItems.smallSpace,
                mainAxisSpacing: SizeItems.smallSpace,
                children: [
                  for (var index = 1; index <= 5; index++)
                    _choice('$title $index', selected, onSelected),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ModyActionButton(
                onPressed: selected.isEmpty ? null : onApply,
                appearance: ModyButtonAppearance.themed,
                title: 'Uygula',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _choice(String name, String selected, ValueChanged<String> onSelected) {
  return Semantics(
    selected: name == selected,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: Border.all(
          color: name == selected ? ColorItems.primaryBlue : Colors.transparent,
          width: 2,
        ),
      ),
      child: MockOptionCard(title: name, onPressed: () => onSelected(name)),
    ),
  );
}
