import 'package:perasoft_staj/product/mody_action_button.dart';
import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/selection_sheet.dart';
import 'package:perasoft_staj/product/color_items.dart';
import 'package:perasoft_staj/product/color_options_panel.dart';
import 'package:perasoft_staj/product/layout_items.dart';
import 'package:perasoft_staj/product/mock_selection_panels.dart';
import 'package:perasoft_staj/product/cache/generate_selection.dart';
import 'package:perasoft_staj/product/explore_selection.dart';

class ExploreDetailView extends StatefulWidget {
  const ExploreDetailView({
    super.key,
    required this.title,
    required this.isCarMod,
    this.onBack,
    this.initialSelection = const ExploreSelection(),
    this.onApplied,
    this.isVideo = false,
  });

  final String title;
  final bool isCarMod;
  final VoidCallback? onBack;
  final bool isVideo;
  final ExploreSelection initialSelection;
  final ValueChanged<ExploreSelection>? onApplied;

  @override
  State<ExploreDetailView> createState() => _ExploreDetailViewState();
}

class _ExploreDetailViewState extends State<ExploreDetailView> {
  String _image = '';
  bool _sheetOpen = false;
  String _option = '';
  int _colorCategory = 0;

  @override
  void initState() {
    super.initState();
    _image = widget.initialSelection.image;
    _option = widget.initialSelection.option;
    _colorCategory = widget.initialSelection.colorCategory;
  }

  void _saveSelection() {
    widget.onApplied?.call(
      ExploreSelection(
        image: _image,
        option: _option,
        colorCategory: _colorCategory,
      ),
    );
  }

  Future<void> _openImages({String? example}) async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    try {
      final result = await showSelectionSheet<String>(
        context: context,
        initialValue: example ?? _image,
        builder: (context, draft, change, apply) => MockImageSelectionPanel(
          selected: draft,
          onSelected: change,
          onApply: apply,
        ),
      );
      if (!mounted || result == null) return;
      setState(() => _image = result);
      _saveSelection();
    } finally {
      _sheetOpen = false;
    }
  }

  String get _optionTitle {
    switch (widget.title) {
      case 'Change Color':
        return 'Renk';
      case 'Customize Rims':
        return 'Rim';
      case 'Suspension':
        return 'Suspension';
      case 'Neons':
        return 'Neon';
      default:
        return 'Tire';
    }
  }

  Future<void> _openOptions() async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    try {
      final result = await showSelectionSheet<String>(
        context: context,
        initialValue: _option,
        builder: (context, draft, change, apply) =>
            widget.title == 'Change Color'
            ? ColorOptionsPanel(
                selectedTitle: draft,
                initialCategory: _colorCategory,
                onSelected: (name, category) => change(name),
                onApply: apply,
              )
            : MockOptionsSelectionPanel(
                title: _optionTitle,
                selected: draft,
                onSelected: change,
                onApply: apply,
              ),
      );
      if (!mounted || result == null) return;
      setState(() {
        _option = result;
        _colorCategory = colorCategoryOf(result);
      });
      _saveSelection();
    } finally {
      _sheetOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: PaddingItems.pageHorizontal,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: widget.isVideo
                        ? 'AI Video’ya dön'
                        : 'Explore’a dön',
                    onPressed:
                        widget.onBack ?? () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                const SizedBox(
                  height: 150,
                  child: Icon(
                    Icons.directions_car_outlined,
                    size: 80,
                    color: ColorItems.secondaryText,
                  ),
                ),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: SizeItems.largeSpace),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!widget.isCarMod) const Spacer(),
                    Expanded(
                      flex: widget.isCarMod ? 1 : 2,
                      child: _DetailBox(
                        title: 'Resim Seçin',
                        value: _image,
                        icon: Icons.add,
                        onPressed: _openImages,
                      ),
                    ),
                    if (widget.isCarMod) ...[
                      const SizedBox(width: SizeItems.normalSpace),
                      Expanded(
                        child: _DetailBox(
                          title: _optionTitle,
                          value: _option,
                          icon: Icons.keyboard_arrow_down,
                          onPressed: _openOptions,
                        ),
                      ),
                    ],
                    if (!widget.isCarMod) const Spacer(),
                  ],
                ),
                const SizedBox(height: SizeItems.largeSpace),
                Text(
                  'Örnek Arabalar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: SizeItems.smallSpace),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: SizeItems.normalSpace),
                    itemBuilder: (context, index) => SizedBox(
                      width: 72,
                      child: IconButton(
                        tooltip: 'Örnek Araç ${index + 1}',
                        onPressed: () =>
                            _openImages(example: 'Örnek Araç ${index + 1}'),
                        style: IconButton.styleFrom(
                          backgroundColor: ColorItems.sampleColor,
                          foregroundColor: ColorItems.secondaryText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SizeItems.normalRadius,
                            ),
                            side: const BorderSide(
                              color: ColorItems.softBorder,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.directions_car_outlined),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SizeItems.largeSpace),
                ModyActionButton(
                  onPressed:
                      _image.isEmpty || (widget.isCarMod && _option.isEmpty)
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.isVideo
                                    ? 'Bu bir mock önizlemedir; gerçek video üretilmez.'
                                    : 'Bu bir mock önizlemedir; gerçek görsel üretilmez.',
                              ),
                            ),
                          );
                        },
                  title: widget.isVideo
                      ? 'Video Oluştur'
                      : 'Arabamı Modifiye Et',
                ),
                const SizedBox(height: SizeItems.largeSpace),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  const _DetailBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.onPressed,
  });
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: ColorItems.cardBackground,
          foregroundColor: ColorItems.primaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeItems.normalRadius),
          ),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            const SizedBox(height: SizeItems.smallSpace),
            Icon(icon),
            if (value.isNotEmpty)
              Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColorItems.secondaryText,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
