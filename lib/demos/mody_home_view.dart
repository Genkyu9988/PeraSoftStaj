import 'package:flutter/material.dart';

class ModyHomeView extends StatelessWidget {
  const ModyHomeView({super.key});

  final String _uploadText = 'Araç Fotoğrafı Yüklemek İçin Dokunun';
  final String _sampleCarsTitle = 'Örnek Arabalar';
  final String _modifyCarText = 'Arabamı Modifiye Et';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12),
        child: Column(
          children: [
            Padding(
              padding: PaddingItems.pageHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ModyHeader(),
                  const SizedBox(height: SizeItems.normalSpace),
                  const _ModeTabs(),
                  _UploadArea(uploadText: _uploadText),
                  const SizedBox(height: SizeItems.normalSpace),
                  const _OptionBoxes(),
                  const SizedBox(height: SizeItems.smallSpace),
                  Text(
                    _sampleCarsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ColorItems.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: SizeItems.smallSpace),
                  const _SampleCars(),
                  const SizedBox(height: SizeItems.largeSpace),
                  _ModifyCarArea(title: _modifyCarText),
                ],
              ),
            ),
            const Spacer(),
            const _BottomBar(),
          ],
        ),
      ),
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
  const _ModeTabs();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeItems.tabHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            child: _ModeTab(title: 'Style Builder', color: Color(0xff00AEEF)),
          ),
          Expanded(
            child: _ModeTab(title: 'Custom Edit', color: Color(0xff4B1FA5)),
          ),
          Expanded(
            child: _ModeTab(title: 'Detail Edit', color: Color(0xffB63819)),
          ),
          SizedBox(width: SizeItems.smallSpace),
          _HelpArea(),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeItems.tabHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
      ),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: ColorItems.primaryText),
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
  const _UploadArea({required this.uploadText});

  final String uploadText;

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
                  uploadText,
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

class _OptionBoxes extends StatelessWidget {
  const _OptionBoxes();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 88,
      child: Row(
        children: [
          Expanded(
            child: _OptionBox(title: 'Stil', icon: Icons.keyboard_arrow_down),
          ),
          SizedBox(width: SizeItems.smallSpace),
          Expanded(
            child: _OptionBox(title: 'Ekstra', icon: Icons.add),
          ),
          SizedBox(width: SizeItems.smallSpace),
          Expanded(
            child: _OptionBox(title: 'Renk', icon: Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }
}

class _OptionBox extends StatelessWidget {
  const _OptionBox({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: ColorItems.cardBackground,
        borderRadius: BorderRadius.circular(SizeItems.normalRadius),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ColorItems.primaryText),
          ),
          const Spacer(),
          Icon(icon, color: ColorItems.primaryText, size: SizeItems.smallIcon),
        ],
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
  const _ModifyCarArea({required this.title});

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

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: const Row(
        children: [
          Expanded(
            child: _BottomBarItem(
              title: 'Üret',
              iconArea: Icon(
                Icons.generating_tokens_outlined,
                color: ColorItems.primaryText,
                size: SizeItems.normalIcon,
              ),
              textColor: ColorItems.primaryText,
            ),
          ),
          Expanded(
            child: _BottomBarItem(
              title: 'Explore',
              iconArea: Icon(
                Icons.layers_outlined,
                color: ColorItems.passiveText,
                size: SizeItems.normalIcon,
              ),
              textColor: ColorItems.passiveText,
            ),
          ),
          Expanded(
            child: _BottomBarItem(
              title: 'AI Video',
              iconArea: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.video_collection_outlined,
                      color: ColorItems.passiveText,
                      size: SizeItems.normalIcon,
                    ),
                  ),
                  Positioned(top: 0, right: 0, child: _NewBadge()),
                ],
              ),
              textColor: ColorItems.passiveText,
            ),
          ),
          Expanded(
            child: _BottomBarItem(
              title: 'Garaj',
              iconArea: Icon(
                Icons.garage_outlined,
                color: ColorItems.passiveText,
                size: SizeItems.normalIcon,
              ),
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
    required this.iconArea,
    required this.textColor,
  });

  final String title;
  final Widget iconArea;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 32, height: 32, child: iconArea),
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
