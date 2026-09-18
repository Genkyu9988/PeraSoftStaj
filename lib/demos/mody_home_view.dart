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
              padding: ModyPaddings.pageHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ModyHeader(),
                  const SizedBox(height: ModySizes.normalSpace),
                  const _ModeTabs(),
                  _UploadArea(uploadText: _uploadText),
                  const SizedBox(height: ModySizes.normalSpace),
                  const _OptionBoxes(),
                  const SizedBox(height: ModySizes.smallSpace),
                  Text(
                    _sampleCarsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ModyColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: ModySizes.smallSpace),
                  const _SampleCars(),
                  const SizedBox(height: ModySizes.largeSpace),
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
      height: ModySizes.headerHeight,
      child: Row(
        children: [
          const Icon(
            Icons.directions_car,
            color: ModyColors.logoColor,
            size: ModySizes.logoSize,
          ),
          const SizedBox(width: ModySizes.smallSpace),
          Text(
            'Mody AI',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: ModyColors.primaryText,
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
      padding: ModyPaddings.proArea,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(ModySizes.normalRadius),
        border: Border.all(color: ModyColors.softBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flag,
            color: ModyColors.primaryText,
            size: ModySizes.smallIcon,
          ),
          const SizedBox(width: ModySizes.smallSpace),
          Text(
            'PRO',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ModyColors.primaryText,
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
      height: ModySizes.tabHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            child: _ModeTab(
              title: 'Style Builder',
              color: ModyColors.styleBuilder,
            ),
          ),
          Expanded(
            child: _ModeTab(title: 'Custom Edit', color: ModyColors.customEdit),
          ),
          Expanded(
            child: _ModeTab(title: 'Detail Edit', color: ModyColors.detailEdit),
          ),
          SizedBox(width: ModySizes.smallSpace),
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
      height: ModySizes.tabHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ModySizes.normalRadius),
      ),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: ModyColors.primaryText),
      ),
    );
  }
}

class _HelpArea extends StatelessWidget {
  const _HelpArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ModySizes.helpSize,
      height: ModySizes.helpSize,
      margin: ModyPaddings.helpArea,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ModyColors.cardBackground,
        borderRadius: BorderRadius.circular(ModySizes.helpSize),
      ),
      child: Text(
        '?',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: ModyColors.primaryText,
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
      height: ModySizes.uploadAreaHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ModyColors.uploadLeft,
            ModyColors.uploadCenter,
            ModyColors.uploadRight,
          ],
        ),
        borderRadius: BorderRadius.circular(ModySizes.normalRadius),
        border: Border.all(
          color: ModyColors.primaryBlue,
          width: ModySizes.borderWidth,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: ModyColors.secondaryText,
                  size: ModySizes.uploadIconSize,
                ),
                const SizedBox(height: ModySizes.normalSpace),
                Text(
                  uploadText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: ModyColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: ModySizes.smallSpace,
            bottom: ModySizes.smallSpace,
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
      padding: ModyPaddings.ideaArea,
      decoration: BoxDecoration(
        color: ModyColors.primaryBlue,
        borderRadius: BorderRadius.circular(ModySizes.smallRadius),
      ),
      child: Text(
        'Fikir Ver',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: ModyColors.primaryText,
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
      height: ModySizes.optionHeight,
      child: Row(
        children: [
          Expanded(
            child: _OptionBox(title: 'Stil', icon: Icons.keyboard_arrow_down),
          ),
          SizedBox(width: ModySizes.smallSpace),
          Expanded(
            child: _OptionBox(title: 'Ekstra', icon: Icons.add),
          ),
          SizedBox(width: ModySizes.smallSpace),
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
      padding: ModyPaddings.optionArea,
      decoration: BoxDecoration(
        color: ModyColors.cardBackground,
        borderRadius: BorderRadius.circular(ModySizes.normalRadius),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ModyColors.primaryText),
          ),
          const Spacer(),
          Icon(icon, color: ModyColors.primaryText, size: ModySizes.smallIcon),
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
      height: ModySizes.sampleCircleSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SampleCircle(color: ModyColors.sampleOne),
          _SampleCircle(color: ModyColors.sampleTwo),
          _SampleCircle(color: ModyColors.sampleThree),
          _SampleCircle(color: ModyColors.sampleFour),
          _SampleCircle(color: ModyColors.sampleFive),
        ],
      ),
    );
  }
}

class _SampleCircle extends StatelessWidget {
  const _SampleCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ModySizes.sampleCircleSize,
      height: ModySizes.sampleCircleSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ModySizes.sampleCircleSize),
        border: Border.all(color: ModyColors.softBorder),
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
      height: ModySizes.modifyAreaHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ModyColors.buttonLeft, ModyColors.buttonRight],
        ),
        borderRadius: BorderRadius.circular(ModySizes.modifyAreaHeight),
        boxShadow: const [
          BoxShadow(
            color: ModyColors.buttonShadow,
            blurRadius: ModySizes.shadowBlur,
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
              color: ModyColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: ModySizes.normalSpace),
          const Icon(
            Icons.auto_awesome,
            color: ModyColors.primaryText,
            size: ModySizes.normalIcon,
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
      height: ModySizes.bottomBarHeight,
      color: Colors.black,
      padding: ModyPaddings.bottomBar,
      child: const Row(
        children: [
          Expanded(
            child: _BottomBarItem(
              title: 'Üret',
              icon: Icons.generating_tokens_outlined,
              isActive: true,
            ),
          ),
          Expanded(
            child: _BottomBarItem(
              title: 'Explore',
              icon: Icons.layers_outlined,
            ),
          ),
          Expanded(
            child: _BottomBarItem(
              title: 'AI Video',
              icon: Icons.video_collection_outlined,
              showBadge: true,
            ),
          ),
          Expanded(
            child: _BottomBarItem(title: 'Garaj', icon: Icons.garage_outlined),
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
    this.isActive = false,
    this.showBadge = false,
  });

  final String title;
  final IconData icon;
  final bool isActive;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isActive
        ? ModyColors.primaryText
        : ModyColors.bottomPassive;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: ModySizes.bottomIconArea,
          height: ModySizes.bottomIconArea,
          child: Stack(
            children: [
              Center(
                child: Icon(icon, color: itemColor, size: ModySizes.normalIcon),
              ),
              if (showBadge)
                const Positioned(top: 0, right: 0, child: _NewBadge()),
            ],
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: itemColor,
            fontSize: ModySizes.bottomBarFontSize,
          ),
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
      padding: ModyPaddings.badge,
      decoration: BoxDecoration(
        color: ModyColors.badge,
        borderRadius: BorderRadius.circular(ModySizes.smallRadius),
      ),
      child: Text(
        'Yeni',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: ModyColors.primaryText,
          fontSize: ModySizes.badgeFontSize,
        ),
      ),
    );
  }
}

class ModyColors {
  static const Color primaryText = Color(0xffF5F5F7);
  static const Color secondaryText = Color(0xff7A7A80);
  static const Color logoColor = Color(0xffD7D7D7);
  static const Color primaryBlue = Color(0xff03AEF5);
  static const Color styleBuilder = Color(0xff00AEEF);
  static const Color customEdit = Color(0xff4B1FA5);
  static const Color detailEdit = Color(0xffB63819);
  static const Color cardBackground = Color(0xff171717);
  static const Color softBorder = Color(0xff353535);
  static const Color uploadLeft = Color(0xff07111C);
  static const Color uploadCenter = Color(0xff102945);
  static const Color uploadRight = Color(0xff070B11);
  static const Color buttonLeft = Color(0xff12C8E9);
  static const Color buttonRight = Color(0xff087BFF);
  static const Color buttonShadow = Color(0xff0B3159);
  static const Color bottomPassive = Color(0xff55555B);
  static const Color badge = Color(0xffFF382F);
  static const Color sampleOne = Color(0xff30343A);
  static const Color sampleTwo = Color(0xff4A4F56);
  static const Color sampleThree = Color(0xff686D73);
  static const Color sampleFour = Color(0xff8B9096);
  static const Color sampleFive = Color(0xff3D4248);
}

class ModyPaddings {
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets proArea = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );
  static const EdgeInsets helpArea = EdgeInsets.only(top: 8);
  static const EdgeInsets ideaArea = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );
  static const EdgeInsets optionArea = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets bottomBar = EdgeInsets.symmetric(vertical: 4);
  static const EdgeInsets badge = EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 1,
  );
}

class ModySizes {
  static const double headerHeight = 42;
  static const double tabHeight = 48;
  static const double uploadAreaHeight = 238;
  static const double optionHeight = 88;
  static const double sampleCircleSize = 55;
  static const double modifyAreaHeight = 60;
  static const double bottomBarHeight = 78;
  static const double bottomIconArea = 32;
  static const double helpSize = 24;
  static const double logoSize = 32;
  static const double uploadIconSize = 54;
  static const double normalIcon = 24;
  static const double smallIcon = 18;
  static const double normalRadius = 13;
  static const double smallRadius = 8;
  static const double borderWidth = 1.4;
  static const double smallSpace = 8;
  static const double normalSpace = 14;
  static const double largeSpace = 22;
  static const double shadowBlur = 18;
  static const double badgeFontSize = 8;
  static const double bottomBarFontSize = 10;
}
