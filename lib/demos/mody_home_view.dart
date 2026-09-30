import 'package:perasoft_staj/product/mody_action_button.dart';
import 'package:perasoft_staj/product/color_options_panel.dart';
import 'package:perasoft_staj/product/selection_sheet.dart';
import 'package:perasoft_staj/product/form_validator.dart';
import 'package:perasoft_staj/product/mody_text_form_field.dart';
import 'package:perasoft_staj/product/cache/generate_selection.dart';
import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/color_items.dart';
import 'package:perasoft_staj/product/layout_items.dart';
import 'package:perasoft_staj/product/mody_header.dart';
import 'package:perasoft_staj/product/mody_bottom_bar.dart';

class ModyHomeView extends StatefulWidget {
  const ModyHomeView({
    super.key,
    this.showBottomBar = true,
    this.isActive = true,
    this.initialSelection = const GenerateSelection(),
    this.onApplied,
  });
  final bool showBottomBar;
  final bool isActive;
  final GenerateSelection initialSelection;
  final ValueChanged<GenerateSelection>? onApplied;

  @override
  State<ModyHomeView> createState() => _ModyHomeViewState();
}

class _ModyHomeViewState extends State<ModyHomeView> {
  int _contentIndex = 0;
  bool _sheetOpen = false;
  String _selectedStyle = '';
  String _selectedExtra = '';
  String _selectedColor = '';
  int _selectedColorCategory = 0;
  String _selectedAngle = '';
  Map<String, int> _selectedParts = {};
  String _selectedDetailColor = '';
  int _selectedDetailColorCategory = 0;
  late final PageController _pageController;
  late final TextEditingController _descriptionController;
  final _customEditFormKey = GlobalKey<FormState>();

  void _submit(int mode) {
    FocusManager.instance.primaryFocus?.unfocus();
    final missing = <String>[];
    if (mode == 0) {
      if (_selectedStyle.isEmpty) missing.add('Stil');
      if (_selectedExtra.isEmpty) missing.add('Ekstra');
      if (_selectedColor.isEmpty) missing.add('Renk');
    } else if (mode == 1) {
      if (!(_customEditFormKey.currentState?.validate() ?? false)) return;
    } else {
      if (_selectedAngle.isEmpty) missing.add('Açı');
      if (_selectedParts.isEmpty) missing.add('Ayarla');
      if (_selectedDetailColor.isEmpty) missing.add('Renk');
    }
    final message = missing.isNotEmpty
        ? '${missing.join(', ')} seçiminizi yapıp Uygula ile onaylayın.'
        : 'Bilgiler hazır. Bu ekran mock; gerçek görsel üretimi henüz bağlı değil.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    final selection = widget.initialSelection;
    _selectedStyle = selection.style;
    _selectedExtra = selection.extra;
    _selectedColor = selection.color;
    _selectedColorCategory = selection.colorCategory;
    _selectedAngle = selection.angle;
    _selectedParts = Map.of(selection.parts);
    _selectedDetailColor = selection.detailColor;
    _selectedDetailColorCategory = selection.detailColorCategory;
    _pageController = PageController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateContent(int index) {
    _setContent(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _setContent(int index) {
    if (_contentIndex == index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    setState(() {
      _contentIndex = index;
    });
  }

  Future<void> _updatePanel(int index) async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    final detail = _contentIndex == 2;
    try {
      if (detail && index == 2) {
        final result = await showSelectionSheet<Map<String, int>>(
          context: context,
          initialValue: Map.of(_selectedParts),
          builder: (context, draft, change, apply) => _AdjustmentOptionsPanel(
            selections: draft,
            onSelected: (part, value) => change({...draft, part: value}),
            onApply: apply,
          ),
        );
        if (!mounted || result == null) return;
        setState(() => _selectedParts = Map.of(result));
      } else {
        final initial = index == 3
            ? (detail ? _selectedDetailColor : _selectedColor)
            : detail
            ? _selectedAngle
            : index == 1
            ? _selectedStyle
            : _selectedExtra;
        final result = await showSelectionSheet<String>(
          context: context,
          initialValue: initial,
          builder: (context, draft, change, apply) {
            if (index == 3) {
              return ColorOptionsPanel(
                selectedTitle: draft,
                initialCategory: colorCategoryOf(initial),
                onSelected: (name, category) => change(name),
                onApply: apply,
              );
            }
            return _SelectionOptionsPanel(
              title: detail
                  ? 'Açı seçin'
                  : index == 1
                  ? 'Stil seçin'
                  : 'Ekstra seçin',
              options: detail
                  ? const ['Front', 'Rear', 'Side']
                  : index == 1
                  ? const [
                      'Klasik',
                      'Sportif',
                      'Off Road',
                      'SUV',
                      'Yarış',
                      'Şehir',
                    ]
                  : const [
                      'Jant',
                      'Spoiler',
                      'Boya',
                      'Neon',
                      'Kaput',
                      'Gövde Kiti',
                    ],
              selectedTitle: draft,
              onSelected: change,
              showApply: true,
              onApply: apply,
            );
          },
        );
        if (!mounted || result == null) return;
        setState(() {
          if (index == 3) {
            if (detail) {
              _selectedDetailColor = result;
              _selectedDetailColorCategory = colorCategoryOf(result);
            } else {
              _selectedColor = result;
              _selectedColorCategory = colorCategoryOf(result);
            }
          } else if (detail) {
            _selectedAngle = result;
          } else if (index == 1) {
            _selectedStyle = result;
          } else {
            _selectedExtra = result;
          }
        });
      }
      _notifyApplied();
    } finally {
      _sheetOpen = false;
    }
  }

  void _notifyApplied() => widget.onApplied?.call(
    GenerateSelection(
      style: _selectedStyle,
      extra: _selectedExtra,
      color: _selectedColor,
      colorCategory: _selectedColorCategory,
      angle: _selectedAngle,
      parts: Map.of(_selectedParts),
      detailColor: _selectedDetailColor,
      detailColorCategory: _selectedDetailColorCategory,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: PaddingItems.pageHorizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ModyHeader(),
                        const SizedBox(height: SizeItems.normalSpace),
                        _ModeTabs(
                          selectedIndex: _contentIndex,
                          onSelected: _updateContent,
                        ),
                        const _UploadArea(),
                        Expanded(
                          child: PageView(
                            key: const Key('generateModes'),
                            controller: _pageController,
                            onPageChanged: _setContent,
                            children: [
                              _StyleBuilderContent(
                                onPanelSelected: _updatePanel,
                                selectedStyle: _selectedStyle,
                                selectedExtra: _selectedExtra,
                                selectedColor: _selectedColor,
                                onSubmit: () => _submit(0),
                              ),
                              _CustomEditContent(
                                controller: _descriptionController,
                                formKey: _customEditFormKey,
                                onSubmit: () => _submit(1),
                              ),
                              _DetailEditContent(
                                onPanelSelected: _updatePanel,
                                selectedAngle: _selectedAngle,
                                selectedParts: _selectedParts.entries
                                    .map(
                                      (part) => '${part.key} ${part.value + 1}',
                                    )
                                    .join(', '),
                                selectedColor: _selectedDetailColor,
                                onSubmit: () => _submit(2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.showBottomBar) const ModyBottomBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleBuilderContent extends StatelessWidget {
  const _StyleBuilderContent({
    required this.onPanelSelected,
    required this.selectedStyle,
    required this.selectedExtra,
    required this.selectedColor,
    required this.onSubmit,
  });

  final void Function(int) onPanelSelected;
  final String selectedStyle;
  final String selectedExtra;
  final String selectedColor;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SizeItems.normalSpace),
          _OptionBoxes(
            firstTitle: 'Stil',
            secondTitle: 'Ekstra',
            firstSelection: selectedStyle,
            secondSelection: selectedExtra,
            colorSelection: selectedColor,
            onSelected: onPanelSelected,
          ),
          const SizedBox(height: SizeItems.smallSpace),
          const _SampleCarsArea(),
          const SizedBox(height: SizeItems.largeSpace),
          ModyActionButton(
            title: 'Arabamı Modifiye Et',
            onPressed: onSubmit,
            appearance: ModyButtonAppearance.gradient,
            icon: Icons.auto_awesome,
          ),
        ],
      ),
    );
  }
}

class _CustomEditContent extends StatelessWidget {
  const _CustomEditContent({
    required this.controller,
    required this.formKey,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: SizeItems.normalSpace),
            _DescriptionArea(controller: controller),
            const SizedBox(height: SizeItems.normalSpace),
            ModyActionButton(
              title: 'Arabamı Modifiye Et',
              onPressed: onSubmit,
              appearance: ModyButtonAppearance.gradient,
              icon: Icons.auto_awesome,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailEditContent extends StatelessWidget {
  const _DetailEditContent({
    required this.onPanelSelected,
    required this.selectedAngle,
    required this.selectedParts,
    required this.selectedColor,
    required this.onSubmit,
  });

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
          _OptionBoxes(
            firstTitle: 'Açı',
            secondTitle: 'Ayarla',
            firstSelection: selectedAngle,
            secondSelection: selectedParts,
            colorSelection: selectedColor,
            onSelected: onPanelSelected,
          ),
          const SizedBox(height: SizeItems.smallSpace),
          const _SampleCarsArea(),
          const SizedBox(height: SizeItems.largeSpace),
          Row(
            children: [
              const Expanded(child: _LiveEditArea()),
              const SizedBox(width: SizeItems.smallSpace),
              Expanded(
                flex: 2,
                child: ModyActionButton(
                  appearance: ModyButtonAppearance.gradient,
                  icon: Icons.auto_awesome,
                  title: 'Modifiye Et',
                  onPressed: onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeItems.tabHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _ModeTab(
              title: 'Style Builder',
              color: const Color(0xff00AEEF),
              isSelected: selectedIndex == 0,
              onPressed: () => onSelected(0),
            ),
          ),
          Expanded(
            child: _ModeTab(
              title: 'Custom Edit',
              color: const Color(0xff4B1FA5),
              isSelected: selectedIndex == 1,
              onPressed: () => onSelected(1),
            ),
          ),
          Expanded(
            child: _ModeTab(
              title: 'Detail Edit',
              color: const Color(0xffB63819),
              isSelected: selectedIndex == 2,
              onPressed: () => onSelected(2),
            ),
          ),
          SizedBox(width: SizeItems.smallSpace),
          _HelpArea(),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.title,
    required this.color,
    required this.isSelected,
    required this.onPressed,
  });

  final String title;
  final Color color;
  final bool isSelected;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeItems.tabHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? color : color.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: isSelected ? Border.all(color: ColorItems.primaryText) : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _HelpArea extends StatelessWidget {
  const _HelpArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(top: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorItems.cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text('?', style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _UploadArea extends StatelessWidget {
  const _UploadArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.viewInsetsOf(context).bottom > 0 ? 100 : 238,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff07111C), Color(0xff102945), Color(0xff070B11)],
        ),
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: Border.all(color: ColorItems.primaryBlue, width: 1.4),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (MediaQuery.viewInsetsOf(context).bottom == 0)
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: ColorItems.secondaryText,
                    size: 54,
                  ),
                const SizedBox(height: SizeItems.normalSpace),
                Text(
                  'Araç Fotoğrafı Yüklemek İçin Dokunun',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: ColorItems.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: SizeItems.smallSpace,
            bottom: SizeItems.smallSpace,
            child: _IdeaArea(),
          ),
        ],
      ),
    );
  }
}

class _IdeaArea extends StatelessWidget {
  const _IdeaArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: ColorItems.primaryBlue,
        borderRadius: BorderRadius.circular(SizeItems.smallRadius),
      ),
      child: Text('Fikir Ver', style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _DescriptionArea extends StatelessWidget {
  const _DescriptionArea({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: PaddingItems.card,
      decoration: BoxDecoration(
        color: ColorItems.cardBackground,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: Border.all(color: ColorItems.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modifikasyonunuzu tanımlayın',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: SizeItems.smallSpace),
          Expanded(
            child: Stack(
              children: [
                ModyTextFormField(
                  fieldKey: const Key('customEditDescriptionField'),
                  controller: controller,
                  validator: const FormValidator().description,
                  hintText: 'Örneğin: Spor görünümlü, koyu renkli bir araba...',
                ),
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: _DescriptionIconArea(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionIconArea extends StatelessWidget {
  const _DescriptionIconArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: ColorItems.primaryBlue,
        borderRadius: BorderRadius.circular(SizeItems.smallRadius),
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: ColorItems.primaryText,
        size: SizeItems.smallIcon,
      ),
    );
  }
}

class _OptionBoxes extends StatelessWidget {
  const _OptionBoxes({
    required this.firstTitle,
    required this.secondTitle,
    required this.onSelected,
    this.firstSelection = '',
    this.secondSelection = '',
    this.colorSelection = '',
  });

  final String firstTitle;
  final String secondTitle;
  final String firstSelection;
  final String secondSelection;
  final String colorSelection;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _OptionBox(
              title: firstTitle,
              selection: firstSelection,
              icon: Icons.keyboard_arrow_down,
              onPressed: () => onSelected(1),
            ),
          ),
          const SizedBox(width: SizeItems.smallSpace),
          Expanded(
            child: _OptionBox(
              title: secondTitle,
              selection: secondSelection,
              icon: Icons.add,
              onPressed: () => onSelected(2),
            ),
          ),
          const SizedBox(width: SizeItems.smallSpace),
          Expanded(
            child: _OptionBox(
              title: 'Renk',
              selection: colorSelection,
              icon: Icons.keyboard_arrow_down,
              onPressed: () => onSelected(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleCarsArea extends StatelessWidget {
  const _SampleCarsArea();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Örnek Arabalar', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: SizeItems.smallSpace),
        const _SampleCars(),
      ],
    );
  }
}

class _OptionBox extends StatelessWidget {
  const _OptionBox({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.selection = '',
  });

  final String title;
  final String selection;
  final IconData icon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: ColorItems.cardBackground,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Icon(
                  icon,
                  color: ColorItems.primaryText,
                  size: SizeItems.smallIcon,
                ),
              ],
            ),
            if (selection.isNotEmpty) ...[
              const SizedBox(height: SizeItems.smallSpace),
              Text(
                selection,
                key: ValueKey('selection$title'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColorItems.secondaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SampleCars extends StatelessWidget {
  const _SampleCars();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: SizeItems.sampleCircleSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SampleCircle(),
          _SampleCircle(),
          _SampleCircle(),
          _SampleCircle(),
          _SampleCircle(),
        ],
      ),
    );
  }
}

class _SampleCircle extends StatelessWidget {
  const _SampleCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeItems.sampleCircleSize,
      height: SizeItems.sampleCircleSize,
      decoration: BoxDecoration(
        color: ColorItems.sampleColor,
        borderRadius: BorderRadius.circular(SizeItems.sampleCircleSize),
        border: Border.all(color: ColorItems.softBorder),
      ),
    );
  }
}

class _LiveEditArea extends StatelessWidget {
  const _LiveEditArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: ColorItems.cardBackground,
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: ColorItems.primaryBlue),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.connected_tv_outlined,
            color: ColorItems.primaryText,
            size: SizeItems.smallIcon,
          ),
          const SizedBox(width: SizeItems.smallSpace),
          Text(
            'Canlı\nEdit',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ColorItems.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionOptionsPanel extends StatelessWidget {
  const _SelectionOptionsPanel({
    required this.title,
    required this.options,
    required this.selectedTitle,
    required this.onSelected,
    this.showApply = false,
    this.onApply,
  });

  final String title;
  final List<String> options;
  final String selectedTitle;
  final void Function(String) onSelected;
  final bool showApply;
  final VoidCallback? onApply;

  Widget _option(String name) {
    final selected = selectedTitle == name;
    return Expanded(
      child: Semantics(
        key: Key('option$name'),
        selected: selected,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? ColorItems.primaryBlue : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(SizeItems.normalRadius),
          ),
          child: TextButton(
            onPressed: () => onSelected(name),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: _MockOptionCard(title: name),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OptionsPanelFrame(
      title: title,
      child: Expanded(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _option(options[0]),
                        const SizedBox(width: SizeItems.smallSpace),
                        _option(options[1]),
                        const SizedBox(width: SizeItems.smallSpace),
                        _option(options[2]),
                      ],
                    ),
                    if (options.length > 3) ...[
                      const SizedBox(height: SizeItems.smallSpace),
                      Row(
                        children: [
                          _option(options[3]),
                          const SizedBox(width: SizeItems.smallSpace),
                          _option(options[4]),
                          const SizedBox(width: SizeItems.smallSpace),
                          _option(options[5]),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (showApply)
              Padding(
                padding: const EdgeInsets.only(top: SizeItems.normalSpace),
                child: SizedBox(
                  width: double.infinity,
                  child: ModyActionButton(
                    onPressed: selectedTitle.isEmpty ? null : onApply,
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

class _AdjustmentOptionsPanel extends StatelessWidget {
  const _AdjustmentOptionsPanel({
    required this.selections,
    required this.onSelected,
    required this.onApply,
  });

  final Map<String, int> selections;
  final void Function(String, int) onSelected;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return OptionsPanelFrame(
      title: 'Yapılandırma seçin',
      child: Expanded(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  for (final part in const [
                    'Spoiler',
                    'Exhaust',
                    'Rear Bumper & Diffuser',
                    'Tail Lights',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: SizeItems.normalSpace,
                      ),
                      child: _MockPartSection(
                        title: part,
                        selectedIndex: selections[part],
                        onSelected: (index) => onSelected(part, index),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ModyActionButton(
                onPressed: selections.isEmpty ? null : onApply,
                title: 'Uygula',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockOptionCard extends StatelessWidget {
  const _MockOptionCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 128,
      decoration: BoxDecoration(
        color: ColorItems.sampleColor,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: Border.all(color: ColorItems.softBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car_outlined,
            color: ColorItems.secondaryText,
            size: 36,
          ),
          const SizedBox(height: SizeItems.normalSpace),
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Mock',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ColorItems.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _MockPartSection extends StatelessWidget {
  const _MockPartSection({
    required this.title,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String title;
  final int? selectedIndex;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Row(
          children: [
            for (var index = 0; index < 3; index++) ...[
              if (index > 0) const SizedBox(width: SizeItems.smallSpace),
              Expanded(
                child: Semantics(
                  key: ValueKey('part$title$index'),
                  selected: selectedIndex == index,
                  child: _MockPartCard(
                    title: 'Seçenek ${index + 1}',
                    selected: selectedIndex == index,
                    onPressed: () => onSelected(index),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _MockPartCard extends StatelessWidget {
  const _MockPartCard({
    required this.title,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(SizeItems.smallRadius),
        border: Border.all(
          color: selected ? ColorItems.primaryBlue : ColorItems.softBorder,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build_outlined,
              color: ColorItems.secondaryText,
              size: SizeItems.normalIcon,
            ),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
