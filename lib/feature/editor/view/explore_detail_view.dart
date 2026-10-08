import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perasoft_staj/feature/ai_video/view_model/ai_video_generation_cubit.dart';
import 'package:perasoft_staj/feature/editor/view_model/editor_generation_cubit.dart';
import 'package:perasoft_staj/feature/explore/view_model/explore_generation_cubit.dart';
import 'package:perasoft_staj/feature/generation/view_model/generation_activity.dart';
import 'package:perasoft_staj/feature/generation/view/generation_result_view.dart';
import 'package:perasoft_staj/feature/generation/view/widget/generation_panel.dart';
import 'package:perasoft_staj/product/navigation/navigation_helper.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'package:perasoft_staj/product/service/generation/generation_service_factory.dart';

import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/widget/selection_image_box.dart';
import 'package:perasoft_staj/product/widget/vehicle_selection_panel.dart';
import 'package:perasoft_staj/product/widget/vehicle_image_input.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/widget/sample_cars_area.dart';
import 'package:perasoft_staj/product/widget/selection_sheet.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';
import 'package:perasoft_staj/product/widget/color_options_panel.dart';
import 'package:perasoft_staj/product/constants/layout_items.dart';
import 'package:perasoft_staj/product/widget/mock_selection_panels.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/feature/editor/view/widget/detail_cover_header.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/product/validation/explore_validator.dart';
import 'package:perasoft_staj/product/utility/mody_feedback.dart';
import 'package:perasoft_staj/feature/editor/view/widget/selection_warning_frame.dart';

class ExploreDetailView extends StatefulWidget {
  const ExploreDetailView({
    super.key,
    required this.title,
    required this.isCarMod,
    this.onBack,
    this.initialSelection = const ExploreSelection(),
    this.onApplied,
    this.isVideo = false,
    this.coverImagePath,
    this.generationService,
  });

  final String title;
  final String? coverImagePath;
  final bool isCarMod;
  final VoidCallback? onBack;
  final bool isVideo;
  final ExploreSelection initialSelection;
  final ValueChanged<ExploreSelection>? onApplied;
  final GenerationService? generationService;

  @override
  State<ExploreDetailView> createState() => _ExploreDetailViewState();
}

class _ExploreDetailViewState extends State<ExploreDetailView> {
  String _image = '';
  bool _sheetOpen = false;
  String _option = '';
  int _colorCategory = 0;
  String _referenceImage = '';
  final _validator = const ExploreValidator();
  final _inputsKey = GlobalKey();
  String? _warning;
  Timer? _warningTimer;
  bool _resultOpen = false;
  // This editor owns/closes its Cubit; the service is supplied at the UI edge.
  late final EditorGenerationCubit _generation = widget.isVideo
      ? AiVideoGenerationCubit(
          generationService:
              widget.generationService ?? createDemoGenerationService(),
        )
      : ExploreGenerationCubit(
          generationService:
              widget.generationService ?? createDemoGenerationService(),
        );
  bool get _blocked => _generation.state.blocksForm;

  ExploreSelection get _selection => ExploreSelection(
    image: _image,
    option: _option,
    colorCategory: _colorCategory,
    referenceImage: _referenceImage,
  );

  bool get _isClone => !widget.isVideo && widget.title == 'Clone Car Style';
  bool get _hasSecondInput => widget.isCarMod || _isClone;
  ExploreValidationRule get _warningRule => ExploreValidator.ruleFor(
    title: widget.title,
    isCarMod: widget.isCarMod,
    isVideo: widget.isVideo,
  );

  @override
  void initState() {
    super.initState();
    _image = VehicleCatalog.restoreId(widget.initialSelection.image);
    _option = widget.title == 'Change Color'
        ? widget.initialSelection.option
        : CarModCatalog.restoreId(widget.title, widget.initialSelection.option);
    _colorCategory = widget.initialSelection.colorCategory;
    _referenceImage = _isClone
        ? ReferenceCarCatalog.restoreId(widget.initialSelection.referenceImage)
        : '';
  }

  void _saveSelection() {
    widget.onApplied?.call(
      ExploreSelection(
        image: _image,
        option: _option,
        colorCategory: _colorCategory,
        referenceImage: _referenceImage,
      ),
    );
  }

  @override
  void dispose() {
    _warningTimer?.cancel();
    unawaited(_generation.close());
    super.dispose();
  }

  void _clearWarning() {
    _warningTimer?.cancel();
    if (_warning != null) setState(() => _warning = null);
  }

  void _clearFeedback() {
    _clearWarning();
    ModyFeedback.dismiss(context);
  }

  void _showWarning(String message) {
    _clearFeedback();
    setState(() => _warning = message);
    // Uygulama tercihi: mevcut SnackBar varsayılanı gibi 4 saniye.
    // Orijinalin süresi sabit ekran görüntülerinden çıkarılamaz.
    _warningTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) _clearWarning();
    });
    final inputContext = _inputsKey.currentContext;
    if (inputContext != null) {
      // Küçük ekranlarda işlem düğmesine kaydırıldığında hata görünür kalsın.
      Scrollable.ensureVisible(
        inputContext,
        duration: const Duration(milliseconds: 200),
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    }
  }

  void _submit() {
    if (_blocked) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final error = _validator.validate(
      _warningRule,
      image: _image,
      option: _option,
      referenceImage: _referenceImage,
    );
    if (error != null) {
      _showWarning(error);
      return;
    }
    _clearWarning();
    ModyFeedback.dismiss(context);
    final warning = _generation.submit(
      title: widget.title,
      selection: _selection,
    );
    if (warning != null) _showWarning(warning);
  }

  Future<void> _showResult(GenerationActivity activity) async {
    if (!mounted ||
        _resultOpen ||
        !(ModalRoute.of(context)?.isCurrent ?? false) ||
        activity != _generation.state ||
        activity.result == null) {
      return;
    }
    _resultOpen = true;
    _generation.consumeResult(activity.attemptId);
    try {
      await openPage<void>(
        context,
        GenerationResultView(result: activity.result!),
      );
    } finally {
      _resultOpen = false;
    }
  }

  void _back() {
    _generation.dismissGeneration();
    _clearFeedback();
    (widget.onBack ?? () => Navigator.of(context).pop())();
  }

  void _selectVehicle(String id) {
    if (_blocked) return;
    _clearFeedback();
    setState(() => _image = VehicleCatalog.restoreId(id));
    _saveSelection();
  }

  Future<void> _openImages() async {
    if (_sheetOpen || _blocked) return;
    _clearFeedback();
    _sheetOpen = true;
    try {
      final result = await showSelectionSheet<String>(
        context: context,
        initialValue: _image,
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
      case 'Spoiler':
        return 'Spoiler';
      case 'Sound System':
        return 'Ses Sistemi';
      case 'Window Tints':
        return 'Cam Filmi';
      case 'Exhaust':
        return 'Egzoz';
      case 'Chrome Delete':
        return 'Krom Detay';
      case 'Body Kit':
        return 'Gövde Kiti';
      case 'Perspective':
        return 'Açı';
      case 'Mirror Swap':
        return 'Ayna';
      case 'Sunroof Mood':
        return 'Tavan';
      case 'Put On Sticker':
        return 'Kaplama';
      case 'Upholstery':
        return 'Döşeme';
      default:
        return widget.title;
    }
  }

  Future<void> _openReferences() async {
    if (_sheetOpen || _blocked) return;
    _clearFeedback();
    _sheetOpen = true;
    try {
      final result = await showSelectionSheet<String>(
        context: context,
        initialValue: _referenceImage,
        builder: (context, draft, change, apply) => MockOptionsSelectionPanel(
          title: 'Referans Görsel',
          options: ReferenceCarCatalog.items,
          selected: draft,
          onSelected: change,
          onApply: apply,
        ),
      );
      if (!mounted || result == null) return;
      _selectReference(result);
    } finally {
      _sheetOpen = false;
    }
  }

  void _selectReference(String id) {
    if (_blocked) return;
    _clearFeedback();
    setState(() => _referenceImage = ReferenceCarCatalog.restoreId(id));
    _saveSelection();
  }

  Future<void> _openOptions() async {
    if (_sheetOpen || _blocked) return;
    _clearFeedback();
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
                options: CarModCatalog.groups[widget.title] ?? const [],
                selected: draft,
                onSelected: change,
                onApply: apply,
              ),
      );
      if (!mounted || result == null || _blocked) return;
      setState(() {
        _option = result;
        _colorCategory = colorCategoryOf(result);
      });
      _saveSelection();
    } finally {
      _sheetOpen = false;
    }
  }

  void _clearOption() {
    if (_blocked) return;
    _clearFeedback();
    setState(() {
      _option = '';
      _colorCategory = 0;
    });
    _saveSelection();
  }

  @override
  Widget build(BuildContext context) {
    final generation = _generation;
    // Keep the form subtree stable while only production state changes.
    final editor = _buildEditor(context);
    return BlocConsumer<EditorGenerationCubit, GenerationActivity>(
      bloc: generation,
      listenWhen: (previous, current) =>
          current.status == GenerationStatus.success &&
          (previous.status != current.status ||
              previous.attemptId != current.attemptId),
      listener: (context, activity) => unawaited(_showResult(activity)),
      builder: (context, activity) => Stack(
        children: [
          GenerationInteractionGuard(
            blocked: activity.blocksForm,
            child: editor,
          ),
          if (activity.blocksForm)
            Positioned.fill(
              child: GenerationPanel(
                activity: activity,
                onRetry: generation.retryGeneration,
                onDismiss: generation.dismissGeneration,
                onShowResult: () => unawaited(_showResult(activity)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final selectedOption = CarModCatalog.find(widget.title, _option);
    final reference = ReferenceCarCatalog.find(_referenceImage);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              key: const Key('exploreDetailScroll'),
              padding: PaddingItems.pageHorizontal,
              children: [
                if (widget.coverImagePath case final path?)
                  DetailCoverHeader(
                    path: path,
                    title: widget.title,
                    backLabel: widget.isVideo
                        ? 'AI Video’ya dön'
                        : 'Explore’a dön',
                    onBack: _back,
                  )
                else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: widget.isVideo
                          ? 'AI Video’ya dön'
                          : 'Explore’a dön',
                      onPressed: _back,
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
                ],
                const SizedBox(height: SizeItems.largeSpace),
                SelectionWarningFrame(
                  key: _inputsKey,
                  message: _warning,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_hasSecondInput) const Spacer(),
                      Expanded(
                        flex: _hasSecondInput ? 1 : 2,
                        child: VehicleImageInput(
                          selectedId: _image,
                          onSelect: _openImages,
                          onClear: () => _selectVehicle(''),
                        ),
                      ),
                      if (widget.isCarMod) ...[
                        const SizedBox(width: SizeItems.normalSpace),
                        Expanded(
                          child: selectedOption != null
                              ? SelectionImageBox(
                                  imagePath: selectedOption.imagePath,
                                  semanticLabel:
                                      'Seçilen modifikasyon: ${selectedOption.label}',
                                  inputKey: const Key('modificationInput'),
                                  imageKey: const Key(
                                    'selectedModificationImage',
                                  ),
                                  clearLabel: 'Modifikasyon seçimini kaldır',
                                  onSelect: _openOptions,
                                  onClear: _clearOption,
                                  emptyChild: const SizedBox.shrink(),
                                )
                              : _DetailBox(
                                  title: _optionTitle,
                                  value:
                                      CarModCatalog.find(
                                        widget.title,
                                        _option,
                                      )?.label ??
                                      _option,
                                  icon: Icons.keyboard_arrow_down,
                                  onPressed: _openOptions,
                                ),
                        ),
                      ],
                      if (_isClone) ...[
                        const SizedBox(width: SizeItems.normalSpace),
                        Expanded(
                          child: SelectionImageBox(
                            imagePath: reference?.imagePath,
                            inputKey: const Key('referenceInput'),
                            imageKey: const Key('selectedReferenceImage'),
                            semanticLabel:
                                'Seçilen referans: ${reference?.label ?? ''}',
                            clearLabel: 'Referans seçimini kaldır',
                            onSelect: _openReferences,
                            onClear: () => _selectReference(''),
                            emptyChild: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Referans Görsel',
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: SizeItems.smallSpace),
                                Icon(Icons.add),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (!_hasSecondInput) const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: SizeItems.largeSpace),
                SampleCarsArea(selectedId: _image, onSelected: _selectVehicle),
                const SizedBox(height: SizeItems.largeSpace),
                BlocSelector<EditorGenerationCubit, GenerationActivity, bool>(
                  bloc: _generation,
                  selector: (state) => state.blocksForm,
                  builder: (context, blocked) => ModyActionButton(
                    onPressed: blocked ? null : _submit,
                    title: widget.isVideo
                        ? 'Video Oluştur'
                        : 'Arabamı Modifiye Et',
                  ),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 160),
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
          mainAxisSize: MainAxisSize.min,
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
