import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/catalog/generate_option_catalog.dart';

class ColorOptionsPanel extends StatefulWidget {
  const ColorOptionsPanel({
    super.key,
    this.selectedTitle = '',
    this.initialCategory = 0,
    this.onSelected,
    this.onApply,
  });

  final String selectedTitle;
  final int initialCategory;
  final void Function(String, int)? onSelected;
  final VoidCallback? onApply;

  @override
  State<ColorOptionsPanel> createState() => ColorOptionsPanelState();
}

class ColorOptionsPanelState extends State<ColorOptionsPanel> {
  late int _categoryIndex;

  @override
  void initState() {
    super.initState();
    _categoryIndex = widget.initialCategory;
  }

  Widget _colorRow(String name, Color color) {
    final title = GenerateOptionCatalog.colorTitle(name, _categoryIndex);
    return _MockColorRow(
      title: title,
      color: color,
      isSelected: widget.selectedTitle == title,
      onPressed: widget.onSelected == null
          ? null
          : () => widget.onSelected!(title, _categoryIndex),
    );
  }

  void _updateCategory(int index) {
    if (_categoryIndex == index) return;

    setState(() {
      _categoryIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OptionsPanelFrame(
      title: 'Renk seçin',
      child: Expanded(
        child: Column(
          children: [
            _ColorCategories(
              selectedIndex: _categoryIndex,
              onSelected: _updateCategory,
            ),
            const SizedBox(height: SizeItems.smallSpace),
            Expanded(
              child: ListView(
                children: [
                  for (final color in GenerateOptionCatalog.baseColors.entries)
                    _colorRow(color.key, Color(color.value)),
                ],
              ),
            ),
            if (widget.onApply != null)
              Padding(
                padding: const EdgeInsets.only(top: SizeItems.normalSpace),
                child: SizedBox(
                  width: double.infinity,
                  child: ModyActionButton(
                    onPressed: widget.selectedTitle.isEmpty
                        ? null
                        : widget.onApply,
                    title: 'Uygula',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorCategories extends StatelessWidget {
  const _ColorCategories({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (
            var i = 0;
            i < GenerateOptionCatalog.colorCategories.length;
            i++
          ) ...[
            if (i > 0) const SizedBox(width: SizeItems.smallSpace),
            Expanded(
              child: _ColorCategory(
                title: GenerateOptionCatalog.colorCategories[i],
                isSelected: selectedIndex == i,
                onPressed: () => onSelected(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ColorCategory extends StatelessWidget {
  const _ColorCategory({
    required this.title,
    required this.onPressed,
    this.isSelected = false,
  });

  final String title;
  final bool isSelected;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? ColorItems.sampleColor : Colors.black,
        borderRadius: BorderRadius.circular(SizeItems.smallRadius),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _MockColorRow extends StatelessWidget {
  const _MockColorRow({
    required this.title,
    required this.color,
    this.isSelected = false,
    this.onPressed,
  });

  final bool isSelected;
  final VoidCallback? onPressed;

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: Key('color$title'),
      selected: isSelected,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: ColorItems.softBorder)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(34),
                ),
              ),
              const SizedBox(width: SizeItems.normalSpace),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: SizeItems.smallSpace),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorItems.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ColorItems.primaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
