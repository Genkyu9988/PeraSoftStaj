class GenerateSelection {
  const GenerateSelection({
    this.style = '',
    this.extra = '',
    this.color = '',
    this.colorCategory = 0,
    this.angle = '',
    this.parts = const {},
    this.detailColor = '',
    this.detailColorCategory = 0,
  });

  final String style;
  final String extra;
  final String color;
  final int colorCategory;
  final String angle;
  final Map<String, int> parts;
  final String detailColor;
  final int detailColorCategory;

  Map<String, dynamic> toJson() => {
    'style': style,
    'extra': extra,
    'color': color,
    'colorCategory': colorCategory,
    'angle': angle,
    'parts': parts,
    'detailColor': detailColor,
    'detailColorCategory': detailColorCategory,
  };

  factory GenerateSelection.fromJson(Map<String, dynamic> json) {
    final parts = <String, int>{};
    final data = json['parts'];
    if (data is Map) {
      for (final title in [
        'Spoiler',
        'Exhaust',
        'Rear Bumper & Diffuser',
        'Tail Lights',
      ]) {
        final index = data[title];
        if (index is int && index >= 0 && index < 3) parts[title] = index;
      }
    }
    final color = readColor(json['color']);
    final detailColor = readColor(json['detailColor']);
    return GenerateSelection(
      style: readChoice(json['style'], [
        'Klasik',
        'Sportif',
        'Off Road',
        'SUV',
        'Yarış',
        'Şehir',
      ]),
      extra: readChoice(json['extra'], [
        'Jant',
        'Spoiler',
        'Boya',
        'Neon',
        'Kaput',
        'Gövde Kiti',
      ]),
      color: color,
      colorCategory: colorCategoryOf(color),
      angle: readChoice(json['angle'], ['Front', 'Rear', 'Side']),
      parts: parts,
      detailColor: detailColor,
      detailColorCategory: colorCategoryOf(detailColor),
    );
  }
}

String readChoice(Object? value, List<String> choices) =>
    value is String && choices.contains(value) ? value : '';

String readColor(Object? value) => readChoice(value, [
  for (final prefix in ['', 'Premium ', 'Özel '])
    for (final color in ['Kırmızı', 'Mavi', 'Mor', 'Gri']) '$prefix$color',
]);

int colorCategoryOf(String color) => color.startsWith('Premium ')
    ? 1
    : color.startsWith('Özel ')
    ? 2
    : 0;
