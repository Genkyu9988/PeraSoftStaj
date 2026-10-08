import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/widget/mody_warning_content.dart';

// Sadece sunum. Bildirim kartların alt kenarına bağlıdır; ekran pikseline değil.
// Dokunmaları engellemez, dolayısıyla eksik görsel/panel hemen seçilebilir.
class SelectionWarningFrame extends StatelessWidget {
  const SelectionWarningFrame({
    super.key,
    required this.child,
    required this.message,
  });

  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      child,
      if (message case final text?)
        Positioned(
          left: 0,
          right: 0,
          bottom: 6,
          child: IgnorePointer(
            child: Semantics(
              liveRegion: true,
              child: Material(
                key: const Key('exploreWarning'),
                color: ColorItems.warningRed,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ModyWarningContent(message: text),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
