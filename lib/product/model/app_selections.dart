import 'package:perasoft_staj/product/catalog/ai_video_items.dart';
import 'package:perasoft_staj/product/catalog/explore_items.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';

class AppSelections {
  AppSelections({
    GenerateSelection? generate,
    Map<String, ExploreSelection>? explore,
    Map<String, ExploreSelection>? aiVideo,
  }) : generate = generate ?? const GenerateSelection(),
       explore = explore ?? {},
       aiVideo = aiVideo ?? {};

  GenerateSelection generate;
  final Map<String, ExploreSelection> explore;
  final Map<String, ExploreSelection> aiVideo;

  Map<String, dynamic> toJson() => {
    'generate': generate.toJson(),
    'explore': explore.map((key, value) => MapEntry(key, value.toJson())),
    'aiVideo': aiVideo.map((key, value) => MapEntry(key, value.toJson())),
  };

  factory AppSelections.fromJson(Map<String, dynamic> json) => AppSelections(
    generate: json['generate'] is Map<String, dynamic>
        ? GenerateSelection.fromJson(json['generate'])
        : const GenerateSelection(),
    explore: _readCards(json['explore'], [
      ...ExploreItems.carMods,
      ...ExploreItems.styleBuilder,
      ...ExploreItems.wallpaperMaker,
      ...ExploreItems.aiEdits,
    ]),
    aiVideo: _readCards(json['aiVideo'], [
      ...AiVideoItems.transformations,
      ...AiVideoItems.driveScenes,
      ...AiVideoItems.filters,
    ], isVideo: true),
  );

  static Map<String, ExploreSelection> _readCards(
    Object? data,
    List<String> titles, {
    bool isVideo = false,
  }) {
    final result = <String, ExploreSelection>{};
    if (data is! Map) return result;
    for (final title in titles) {
      final value = data[title];
      if (value is Map<String, dynamic>) {
        result[title] = ExploreSelection.fromJson(
          value,
          title,
          isVideo: isVideo,
        );
      }
    }
    return result;
  }
}
