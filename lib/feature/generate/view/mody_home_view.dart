import 'dart:async';
import 'package:perasoft_staj/feature/generate/view/generation_result_view.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generation_overlay.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generation_activity.dart';
import 'package:perasoft_staj/product/navigation/navigation_helper.dart';
import 'package:perasoft_staj/product/service/generation/generation_service_factory.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perasoft_staj/feature/generate/view_model/generate_cubit.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generate_state.dart';
import 'package:perasoft_staj/feature/generate/view/widget/style_builder_content.dart';
import 'package:perasoft_staj/feature/generate/view/widget/custom_edit_content.dart';
import 'package:perasoft_staj/feature/generate/view/widget/detail_edit_content.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generate_mode_tabs.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generate_idea_button.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generate_options_panel.dart';
import 'package:perasoft_staj/product/widget/vehicle_selection_panel.dart';
import 'package:perasoft_staj/product/widget/vehicle_image_input.dart';
import 'package:perasoft_staj/product/widget/color_options_panel.dart';
import 'package:perasoft_staj/product/widget/selection_sheet.dart';
import 'package:perasoft_staj/product/utility/mody_feedback.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/feature/generate/view/widget/detail_adjustment_panel.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/mody_header.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/catalog/generate_option_catalog.dart';
import 'package:perasoft_staj/feature/generate/logic/generate_suggestions.dart';

class ModyHomeView extends StatefulWidget {
  const ModyHomeView({
    super.key,
    this.showBottomBar = true,
    this.isActive,
    this.initialSelection = const GenerateSelection(),
    this.onApplied,
    this.suggestions,
    this.generationService,
  });
  final bool showBottomBar;
  // Read live: TabBarView can defer child updates during its animation.
  final ValueGetter<bool>? isActive;
  final GenerateSelection initialSelection;
  final ValueChanged<GenerateSelection>? onApplied;
  final GenerateSuggestions? suggestions;
  final GenerationService? generationService;

  @override
  State<ModyHomeView> createState() => _ModyHomeViewState();
}

class _ModyHomeViewState extends State<ModyHomeView> {
  int _contentIndex = 0;
  bool _sheetOpen = false;
  bool _resultOpen = false;
  late final PageController _pageController;
  late final TextEditingController _descriptionController;
  // Initialize on first use, including an existing State after hot reload.
  late final GenerateSuggestions _suggestions =
      widget.suggestions ?? GenerateSuggestions();
  // This State owns the Cubit; BlocProvider.value only exposes it to children.
  late final GenerateCubit _cubit = GenerateCubit(
    initialSelection: widget.initialSelection,
    suggestions: _suggestions,
    generationService:
        widget.generationService ?? createDemoGenerationService(),
    onApplied: (selection) => widget.onApplied?.call(selection),
  );

  void _submit(GenerateMode mode) {
    FocusManager.instance.primaryFocus?.unfocus();
    ModyFeedback.dismiss(context);
    unawaited(_cubit.submit(mode, description: _descriptionController.text));
  }

  void _dismissFeedback() {
    _cubit.dismissFeedback();
    ModyFeedback.dismiss(context);
  }

  void _showFeedback(BuildContext context, GenerateState state) {
    final feedback = state.feedback;
    // Stream notifications may arrive after another choice or tab change.
    if (!mounted ||
        !(widget.isActive?.call() ?? true) ||
        feedback == null ||
        feedback != _cubit.state.feedback) {
      return;
    }
    switch (feedback.kind) {
      case GenerateFeedbackKind.warning:
        ModyFeedback.warning(context, feedback.message);
      case GenerateFeedbackKind.message:
        ModyFeedback.message(context, feedback.message);
    }
  }

  void _onStateChanged(BuildContext context, GenerateState state) {
    _showFeedback(context, state);
    if (state.generation.status == GenerationStatus.success) {
      unawaited(_showResult(state.generation));
    }
  }

  Future<void> _showResult(GenerationActivity activity) async {
    if (!mounted ||
        _resultOpen ||
        !(widget.isActive?.call() ?? true) ||
        !(ModalRoute.of(context)?.isCurrent ?? false) ||
        activity != _cubit.state.generation ||
        activity.result == null) {
      return;
    }
    _resultOpen = true;
    _cubit.consumeResult(activity.attemptId);
    ModyFeedback.dismiss(context);
    try {
      await openPage<void>(
        context,
        GenerationResultView(result: activity.result!),
      );
    } finally {
      _resultOpen = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
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
    _dismissFeedback();

    setState(() {
      _contentIndex = index;
    });
  }

  void _selectVehicle(String id) {
    ModyFeedback.dismiss(context);
    _cubit.selectVehicle(id);
  }

  void _suggestIdea() {
    FocusManager.instance.primaryFocus?.unfocus();
    ModyFeedback.dismiss(context);
    _cubit.suggestIdea(GenerateMode.values[_contentIndex]);
  }

  void _setDescription(String text) {
    FocusManager.instance.primaryFocus?.unfocus();
    _dismissFeedback();
    _descriptionController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _openVehicles() async {
    if (_sheetOpen || _cubit.state.generation.blocksForm) return;
    _sheetOpen = true;
    try {
      final result = await showSelectionSheet<String>(
        context: context,
        initialValue: _cubit.state.vehicleId,
        builder: (context, draft, change, apply) => VehicleSelectionPanel(
          selected: draft,
          onSelected: change,
          onApply: apply,
        ),
      );
      if (!mounted || result == null) return;
      _selectVehicle(result);
    } finally {
      _sheetOpen = false;
    }
  }

  Future<void> _updatePanel(int index) async {
    if (_sheetOpen || _cubit.state.generation.blocksForm) return;
    final detail = _contentIndex == GenerateMode.detailEdit.index;
    if (detail &&
        (index == 2 || index == 3) &&
        !_cubit.canOpenDetailOptions()) {
      return;
    }
    final selection = _cubit.state;
    _sheetOpen = true;
    try {
      if (detail && index == 2) {
        final result = await showSelectionSheet<Map<String, int>>(
          context: context,
          initialValue: Map.of(selection.parts),
          builder: (context, draft, change, apply) => DetailAdjustmentPanel(
            categories: DetailPartCatalog.forAngle(selection.angle),
            selections: draft,
            onSelected: (part, value) => change({...draft, part: value}),
            onApply: apply,
          ),
        );
        if (!mounted || result == null) return;
        _cubit.selectParts(result);
      } else {
        final initial = index == 3
            ? (detail ? selection.detailColor : selection.color)
            : detail
            ? selection.angle
            : index == 1
            ? selection.style
            : selection.extra;
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
            return GenerateOptionsPanel(
              images: detail
                  ? ImageItems.angleOptions
                  : index == 1
                  ? ImageItems.styleOptions
                  : ImageItems.extraOptions,
              title: detail
                  ? 'Açı seçin'
                  : index == 1
                  ? 'Stil seçin'
                  : 'Ekstra seçin',
              options: detail
                  ? DetailPartCatalog.byAngle.keys.toList()
                  : index == 1
                  ? GenerateOptionCatalog.styles
                  : GenerateOptionCatalog.extras,
              selectedTitle: draft,
              onSelected: change,
              showApply: true,
              onApply: apply,
            );
          },
        );
        if (!mounted || result == null) return;
        if (index == 3) {
          if (detail) {
            _cubit.selectDetailColor(result);
          } else {
            _cubit.selectStyleColor(result);
          }
        } else if (detail) {
          _cubit.selectAngle(result);
        } else if (index == 1) {
          _cubit.selectStyle(result);
        } else {
          _cubit.selectExtra(result);
        }
      }
    } finally {
      _sheetOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read before Scaffold removes keyboard insets from its body's MediaQuery.
    final vehicleHeight = MediaQuery.viewInsetsOf(context).bottom > 0
        ? 100.0
        : MediaQuery.sizeOf(context).height < 700
        ? 140.0
        : 238.0;
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<GenerateCubit, GenerateState>(
        listenWhen: (previous, current) =>
            (previous.feedback != current.feedback &&
                current.feedback != null) ||
            (previous.generation != current.generation &&
                current.generation.status == GenerationStatus.success),
        listener: _onStateChanged,
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
            ),
            child: Stack(
              children: [
                GenerationFormGuard(
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: PaddingItems.pageHorizontal,
                          child: NestedScrollView(
                            headerSliverBuilder:
                                (context, innerBoxIsScrolled) => [
                                  SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const ModyHeader(),
                                        const SizedBox(
                                          height: SizeItems.normalSpace,
                                        ),
                                        GenerateModeTabs(
                                          selectedIndex: _contentIndex,
                                          onSelected: _updateContent,
                                        ),
                                        BlocSelector<
                                          GenerateCubit,
                                          GenerateState,
                                          String
                                        >(
                                          selector: (state) => state.vehicleId,
                                          builder: (context, vehicleId) =>
                                              VehicleImageInput(
                                                selectedId: vehicleId,
                                                onSelect: _openVehicles,
                                                onClear: () =>
                                                    _selectVehicle(''),
                                                height: vehicleHeight,
                                                footer: GenerateIdeaButton(
                                                  onPressed: _suggestIdea,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                            body: PageView(
                              key: const Key('generateModes'),
                              controller: _pageController,
                              onPageChanged: _setContent,
                              children: [
                                BlocSelector<
                                  GenerateCubit,
                                  GenerateState,
                                  ({
                                    String vehicleId,
                                    String style,
                                    String extra,
                                    String color,
                                  })
                                >(
                                  selector: (state) => (
                                    vehicleId: state.vehicleId,
                                    style: state.style,
                                    extra: state.extra,
                                    color: state.color,
                                  ),
                                  builder: (context, selection) =>
                                      StyleBuilderContent(
                                        selectedVehicleId: selection.vehicleId,
                                        onVehicleSelected: _selectVehicle,
                                        onPanelSelected: _updatePanel,
                                        selectedStyle: selection.style,
                                        selectedExtra: selection.extra,
                                        selectedColor: selection.color,
                                        onSubmit: () =>
                                            _submit(GenerateMode.styleBuilder),
                                      ),
                                ),
                                CustomEditContent(
                                  controller: _descriptionController,
                                  onDescriptionChanged: (_) =>
                                      _dismissFeedback(),
                                  onSuggestDescription: () => _setDescription(
                                    _suggestions.description(),
                                  ),
                                  onClearDescription: () => _setDescription(''),
                                  onSubmit: () =>
                                      _submit(GenerateMode.customEdit),
                                ),
                                BlocSelector<
                                  GenerateCubit,
                                  GenerateState,
                                  ({
                                    String vehicleId,
                                    String angle,
                                    String partsLabel,
                                    String color,
                                  })
                                >(
                                  selector: (state) => (
                                    vehicleId: state.vehicleId,
                                    angle: state.angle,
                                    partsLabel: state.partsLabel,
                                    color: state.detailColor,
                                  ),
                                  builder: (context, selection) =>
                                      DetailEditContent(
                                        selectedVehicleId: selection.vehicleId,
                                        onVehicleSelected: _selectVehicle,
                                        onPanelSelected: _updatePanel,
                                        selectedAngle: selection.angle,
                                        selectedParts: selection.partsLabel,
                                        selectedColor: selection.color,
                                        onSubmit: () =>
                                            _submit(GenerateMode.detailEdit),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (widget.showBottomBar) const ModyBottomBar(),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: GenerationOverlay(onShowResult: _showResult),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
