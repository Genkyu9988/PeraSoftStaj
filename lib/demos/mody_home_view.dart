import 'package:flutter/material.dart';

class ModyHomeView extends StatefulWidget {
  const ModyHomeView({super.key});

  @override
  State<ModyHomeView> createState() => _ModyHomeViewState();
}

class _ModyHomeViewState extends State<ModyHomeView> {
  int _contentIndex = 0;
  int _panelIndex = 0;

  void _updateContent(int index) {
    setState(() {
      _contentIndex = index;
      _panelIndex = 0;
    });
  }

  void _updatePanel(int index) {
    setState(() {
      _panelIndex = _panelIndex == index ? 0 : index;
    });
  }

  void _closePanel() {
    setState(() {
      _panelIndex = 0;
    });
  }

  Widget _selectedContent() {
    if (_contentIndex == 1) {
      return const _CustomEditContent();
    }
    if (_contentIndex == 2) {
      return _DetailEditContent(onPanelSelected: _updatePanel);
    }
    return _StyleBuilderContent(onPanelSelected: _updatePanel);
  }

  Widget _selectedPanel() {
    if (_panelIndex == 3) {
      return const _ColorOptionsPanel();
    }
    if (_contentIndex == 2) {
      if (_panelIndex == 1) {
        return const _AngleOptionsPanel();
      }
      return const _AdjustmentOptionsPanel();
    }
    if (_panelIndex == 1) {
      return const _StyleOptionsPanel();
    }
    return const _ExtraOptionsPanel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12),
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: PaddingItems.pageHorizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ModyHeader(),
                      const SizedBox(height: SizeItems.normalSpace),
                      _ModeTabs(onSelected: _updateContent),
                      const _UploadArea(),
                      _selectedContent(),
                    ],
                  ),
                ),
                const Spacer(),
                const _BottomBar(),
              ],
            ),
            if (_panelIndex > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: SizeItems.bottomBarHeight,
                child: Stack(
                  children: [
                    _selectedPanel(),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        tooltip: 'Paneli kapat',
                        onPressed: _closePanel,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StyleBuilderContent extends StatelessWidget {
  const _StyleBuilderContent({required this.onPanelSelected});

  final void Function(int) onPanelSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: SizeItems.normalSpace),
        _OptionBoxes(
          firstTitle: 'Stil',
          secondTitle: 'Ekstra',
          onSelected: onPanelSelected,
        ),
        SizedBox(height: SizeItems.smallSpace),
        _SampleCarsArea(),
        SizedBox(height: SizeItems.largeSpace),
        _ModifyCarArea(),
      ],
    );
  }
}

class _CustomEditContent extends StatelessWidget {
  const _CustomEditContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: SizeItems.normalSpace),
        _DescriptionArea(),
        SizedBox(height: SizeItems.normalSpace),
        _ModifyCarArea(),
      ],
    );
  }
}

class _DetailEditContent extends StatelessWidget {
  const _DetailEditContent({required this.onPanelSelected});

  final void Function(int) onPanelSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: SizeItems.normalSpace),
        _OptionBoxes(
          firstTitle: 'Açı',
          secondTitle: 'Ayarla',
          onSelected: onPanelSelected,
        ),
        SizedBox(height: SizeItems.smallSpace),
        _SampleCarsArea(),
        SizedBox(height: SizeItems.largeSpace),
        Row(
          children: [
            Expanded(child: _LiveEditArea()),
            SizedBox(width: SizeItems.smallSpace),
            Expanded(flex: 2, child: _ModifyCarArea(title: 'Modifiye Et')),
          ],
        ),
      ],
    );
  }
}

class _ModyHeader extends StatelessWidget {
  const _ModyHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: Colors.white70, size: 32),
          const SizedBox(width: SizeItems.smallSpace),
          Text(
            'Mody AI',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: ColorItems.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const _ProArea(),
        ],
      ),
    );
  }
}

class _ProArea extends StatelessWidget {
  const _ProArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: Border.all(color: ColorItems.softBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flag,
            color: ColorItems.primaryText,
            size: SizeItems.smallIcon,
          ),
          const SizedBox(width: SizeItems.smallSpace),
          Text(
            'PRO',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ColorItems.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.onSelected});

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
              onPressed: () => onSelected(0),
            ),
          ),
          Expanded(
            child: _ModeTab(
              title: 'Custom Edit',
              color: const Color(0xff4B1FA5),
              onPressed: () => onSelected(1),
            ),
          ),
          Expanded(
            child: _ModeTab(
              title: 'Detail Edit',
              color: const Color(0xffB63819),
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
    required this.onPressed,
  });

  final String title;
  final Color color;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeItems.tabHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: ColorItems.primaryText),
        ),
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
      child: Text(
        '?',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: ColorItems.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _UploadArea extends StatelessWidget {
  const _UploadArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 238,
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
      child: Text(
        'Fikir Ver',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: ColorItems.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DescriptionArea extends StatelessWidget {
  const _DescriptionArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(SizeItems.normalSpace),
      decoration: BoxDecoration(
        color: ColorItems.cardBackground,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
        border: Border.all(color: ColorItems.softBorder),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifikasyonunuzu tanımlayın',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ColorItems.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: SizeItems.normalSpace),
              Text(
                'Örneğin: Spor görünümlü, koyu renkli bir araba...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ColorItems.secondaryText,
                ),
              ),
            ],
          ),
          const Positioned(right: 0, bottom: 0, child: _DescriptionIconArea()),
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
  });

  final String firstTitle;
  final String secondTitle;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Row(
        children: [
          Expanded(
            child: _OptionBox(
              title: firstTitle,
              icon: Icons.keyboard_arrow_down,
              onPressed: () => onSelected(1),
            ),
          ),
          const SizedBox(width: SizeItems.smallSpace),
          Expanded(
            child: _OptionBox(
              title: secondTitle,
              icon: Icons.add,
              onPressed: () => onSelected(2),
            ),
          ),
          const SizedBox(width: SizeItems.smallSpace),
          Expanded(
            child: _OptionBox(
              title: 'Renk',
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
        Text(
          'Örnek Arabalar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: ColorItems.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
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
  });

  final String title;
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
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: ColorItems.primaryText),
            ),
            const Spacer(),
            Icon(
              icon,
              color: ColorItems.primaryText,
              size: SizeItems.smallIcon,
            ),
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

class _ModifyCarArea extends StatelessWidget {
  const _ModifyCarArea({this.title = 'Arabamı Modifiye Et'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff12C8E9), Color(0xff087BFF)],
        ),
        borderRadius: BorderRadius.circular(60),
        boxShadow: const [
          BoxShadow(
            color: Color(0xff0B3159),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ColorItems.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: SizeItems.normalSpace),
          const Icon(
            Icons.auto_awesome,
            color: ColorItems.primaryText,
            size: SizeItems.normalIcon,
          ),
        ],
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

class _StyleOptionsPanel extends StatelessWidget {
  const _StyleOptionsPanel();

  @override
  Widget build(BuildContext context) {
    return const _OptionsPanelFrame(
      title: 'Stil seçin',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _MockOptionCard(title: 'Klasik')),
              SizedBox(width: SizeItems.smallSpace),
              Expanded(child: _MockOptionCard(title: 'Sportif')),
              SizedBox(width: SizeItems.smallSpace),
              Expanded(child: _MockOptionCard(title: 'Off Road')),
            ],
          ),
          SizedBox(height: SizeItems.smallSpace),
          Row(
            children: [
              Expanded(child: _MockOptionCard(title: 'SUV')),
              SizedBox(width: SizeItems.smallSpace),
              Expanded(child: _MockOptionCard(title: 'Yarış')),
              SizedBox(width: SizeItems.smallSpace),
              Expanded(child: _MockOptionCard(title: 'Şehir')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExtraOptionsPanel extends StatelessWidget {
  const _ExtraOptionsPanel();

  @override
  Widget build(BuildContext context) {
    return const _OptionsPanelFrame(
      title: 'Ekstra seçin',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _MockOptionCard(title: 'Jant')),
              SizedBox(width: SizeItems.smallSpace),
              Expanded(child: _MockOptionCard(title: 'Spoiler')),
              SizedBox(width: SizeItems.smallSpace),
              Expanded(child: _MockOptionCard(title: 'Boya')),
            ],
          ),
          SizedBox(height: SizeItems.smallSpace),
          Row(
            children: [
              Expanded(child: _MockOptionCard(title: 'Neon')),
              SizedBox(width: SizeItems.smallSpace),
              Expanded(child: _MockOptionCard(title: 'Kaput')),
              SizedBox(width: SizeItems.smallSpace),
              Expanded(child: _MockOptionCard(title: 'Gövde Kiti')),
            ],
          ),
        ],
      ),
    );
  }
}

class _AngleOptionsPanel extends StatelessWidget {
  const _AngleOptionsPanel();

  @override
  Widget build(BuildContext context) {
    return const _OptionsPanelFrame(
      title: 'Açı seçin',
      child: Row(
        children: [
          Expanded(child: _MockOptionCard(title: 'Ön Görünüm')),
          SizedBox(width: SizeItems.smallSpace),
          Expanded(child: _MockOptionCard(title: 'Arka Görünüm')),
          SizedBox(width: SizeItems.smallSpace),
          Expanded(child: _MockOptionCard(title: 'Yan Görünüm')),
        ],
      ),
    );
  }
}

class _AdjustmentOptionsPanel extends StatelessWidget {
  const _AdjustmentOptionsPanel();

  @override
  Widget build(BuildContext context) {
    return const _OptionsPanelFrame(
      title: 'Yapılandırma seçin',
      child: Column(
        children: [
          _MockPartSection(title: 'Spoiler'),
          SizedBox(height: SizeItems.smallSpace),
          _MockPartSection(title: 'Egzoz'),
          SizedBox(height: SizeItems.smallSpace),
          _MockPartSection(title: 'Arka Tampon'),
        ],
      ),
    );
  }
}

class _ColorOptionsPanel extends StatefulWidget {
  const _ColorOptionsPanel();

  @override
  State<_ColorOptionsPanel> createState() => _ColorOptionsPanelState();
}

class _ColorOptionsPanelState extends State<_ColorOptionsPanel> {
  int _categoryIndex = 0;

  void _updateCategory(int index) {
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
    return _OptionsPanelFrame(
      title: 'Renk seçin',
      child: Column(
        children: [
          _ColorCategories(
            selectedIndex: _categoryIndex,
            onSelected: _updateCategory,
          ),
          const SizedBox(height: SizeItems.smallSpace),
          _MockColorRow(
            title: _colorTitle('Kırmızı'),
            color: const Color(0xffD51F18),
          ),
          _MockColorRow(
            title: _colorTitle('Mavi'),
            color: const Color(0xff126EDB),
          ),
          _MockColorRow(
            title: _colorTitle('Mor'),
            color: const Color(0xff7E32B8),
          ),
          _MockColorRow(
            title: _colorTitle('Gri'),
            color: const Color(0xff646A72),
          ),
        ],
      ),
    );
  }
}

class _OptionsPanelFrame extends StatelessWidget {
  const _OptionsPanelFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 430,
      padding: const EdgeInsets.all(SizeItems.normalSpace),
      decoration: BoxDecoration(
        color: ColorItems.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border.all(color: ColorItems.softBorder),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: ColorItems.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SizeItems.smallSpace),
          Container(width: 90, height: 3, color: ColorItems.primaryBlue),
          const SizedBox(height: SizeItems.normalSpace),
          child,
        ],
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: ColorItems.primaryText),
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
  const _MockPartSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ColorItems.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          children: [
            Expanded(child: _MockPartCard()),
            SizedBox(width: SizeItems.smallSpace),
            Expanded(child: _MockPartCard()),
            SizedBox(width: SizeItems.smallSpace),
            Expanded(child: _MockPartCard()),
          ],
        ),
      ],
    );
  }
}

class _MockPartCard extends StatelessWidget {
  const _MockPartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(SizeItems.smallRadius),
        border: Border.all(color: ColorItems.softBorder),
      ),
      child: const Icon(
        Icons.build_outlined,
        color: ColorItems.secondaryText,
        size: SizeItems.normalIcon,
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
            title: 'Metalik',
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
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ColorItems.primaryText),
          ),
        ),
      ),
    );
  }
}

class _MockColorRow extends StatelessWidget {
  const _MockColorRow({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: ColorItems.primaryText),
          ),
          const Spacer(),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorItems.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeItems.bottomBarHeight,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: const Row(
        children: [
          Expanded(
            child: _BottomBarItem(
              title: 'Üret',
              icon: Icons.generating_tokens_outlined,
              textColor: ColorItems.primaryText,
            ),
          ),
          Expanded(
            child: _BottomBarItem(
              title: 'Explore',
              icon: Icons.layers_outlined,
              textColor: ColorItems.passiveText,
            ),
          ),
          Expanded(
            child: _BottomBarItem(
              title: 'AI Video',
              icon: Icons.video_collection_outlined,
              textColor: ColorItems.passiveText,
              showBadge: true,
            ),
          ),
          Expanded(
            child: _BottomBarItem(
              title: 'Garaj',
              icon: Icons.garage_outlined,
              textColor: ColorItems.passiveText,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.title,
    required this.icon,
    required this.textColor,
    this.showBadge = false,
  });

  final String title;
  final IconData icon;
  final Color textColor;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            children: [
              Center(
                child: Icon(icon, color: textColor, size: SizeItems.normalIcon),
              ),
              if (showBadge)
                const Positioned(top: 0, right: 0, child: _NewBadge()),
            ],
          ),
        ),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: textColor, fontSize: 10),
        ),
      ],
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: ColorItems.badge,
        borderRadius: BorderRadius.circular(SizeItems.smallRadius),
      ),
      child: Text(
        'Yeni',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: ColorItems.primaryText,
          fontSize: 8,
        ),
      ),
    );
  }
}

class ColorItems {
  static const Color primaryText = Color(0xffF5F5F7);
  static const Color secondaryText = Color(0xff7A7A80);
  static const Color primaryBlue = Color(0xff03AEF5);
  static const Color cardBackground = Color(0xff171717);
  static const Color softBorder = Color(0xff353535);
  static const Color passiveText = Color(0xff55555B);
  static const Color badge = Color(0xffFF382F);
  static const Color sampleColor = Color(0xff3D4248);
}

class PaddingItems {
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 12);
}

class SizeItems {
  static const double bottomBarHeight = 78;
  static const double tabHeight = 48;
  static const double sampleCircleSize = 55;
  static const double normalIcon = 24;
  static const double smallIcon = 18;
  static const double normalRadius = 13;
  static const double smallRadius = 8;
  static const double smallSpace = 8;
  static const double normalSpace = 14;
  static const double largeSpace = 22;
}
