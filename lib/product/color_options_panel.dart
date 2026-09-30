import 'package:perasoft_staj/product/mody_action_button.dart';
import 'package:perasoft_staj/product/selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/color_items.dart';
import 'package:perasoft_staj/product/layout_items.dart';

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
    final title = _colorTitle(name);
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

  String _colorTitle(String name) {
    if (_categoryIndex == 1) {
      return 'Premium $name';
    }
    if (_categoryIndex == 2) {
      return 'Özel $name';
    }
    return name;
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
                  _colorRow('Kırmızı', const Color(0xffD51F18)),
                  _colorRow('Mavi', const Color(0xff126EDB)),
                  _colorRow('Mor', const Color(0xff7E32B8)),
                  _colorRow('Gri', const Color(0xff646A72)),
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
    return Row(
      children: [
        Expanded(
          child: _ColorCategory(
            title: 'Mat',
            isSelected: selectedIndex == 0,
            onPressed: () => onSelected(0),
          ),
        ),
        const SizedBox(width: SizeItems.smallSpace),
        Expanded(
          child: _ColorCategory(
            title: 'Premium',
            isSelected: selectedIndex == 1,
            onPressed: () => onSelected(1),
          ),
        ),
        const SizedBox(width: SizeItems.smallSpace),
        Expanded(
          child: _ColorCategory(
            title: 'Özel',
            isSelected: selectedIndex == 2,
            onPressed: () => onSelected(2),
          ),
        ),
      ],
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
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? ColorItems.sampleColor : Colors.black,
        borderRadius: BorderRadius.circular(SizeItems.smallRadius),
      ),
      child: SizedBox.expand(
        child: TextButton(
          onPressed: onPressed,
          child: Text(title, style: Theme.of(context).textTheme.bodySmall),
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
          height: 58,
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
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
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
