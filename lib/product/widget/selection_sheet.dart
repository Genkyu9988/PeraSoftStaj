import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';

typedef SelectionSheetBuilder<T> =
    Widget Function(
      BuildContext context,
      T draft,
      ValueChanged<T> onChanged,
      VoidCallback onApply,
    );

// null: iptal; T: yalnızca Uygula ile onaylanmış sonuç.
Future<T?> showSelectionSheet<T>({
  required BuildContext context,
  required T initialValue,
  required SelectionSheetBuilder<T> builder,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) => SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _SelectionSheet<T>(initialValue: initialValue, builder: builder),
      ),
    ),
  );
}

class _SelectionSheet<T> extends StatefulWidget {
  const _SelectionSheet({required this.initialValue, required this.builder});
  final T initialValue;
  final SelectionSheetBuilder<T> builder;

  @override
  State<_SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<_SelectionSheet<T>> {
  late T _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    _draft,
    (value) => setState(() => _draft = value),
    () => Navigator.of(context).pop<T>(_draft),
  );
}

class OptionsPanelFrame extends StatelessWidget {
  const OptionsPanelFrame({
    super.key,
    required this.title,
    required this.child,
  });
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Keep a usable list viewport when the header/footer grow with text.
    // Short screens (or the keyboard) scroll the frame instead of hiding Apply.
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final minimumHeight = 300.0 * textScale.clamp(1.0, double.infinity);
    return LayoutBuilder(
      builder: (context, constraints) {
        final preferredHeight = minimumHeight > 430 ? minimumHeight : 430.0;
        final availableHeight = constraints.maxHeight;
        final height = availableHeight.clamp(minimumHeight, preferredHeight);
        final panel = _panel(context, height);
        return availableHeight < minimumHeight
            ? SingleChildScrollView(child: panel)
            : panel;
      },
    );
  }

  Widget _panel(BuildContext context, double height) {
    return Container(
      height: height,
      padding: PaddingItems.card,
      decoration: BoxDecoration(
        color: ColorItems.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: ColorItems.softBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Paneli kapat',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(
            key: const Key('selectionSheetHandle'),
            height: 20,
            width: double.infinity,
            child: Center(
              child: Container(
                width: 90,
                height: 3,
                color: ColorItems.primaryBlue,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
