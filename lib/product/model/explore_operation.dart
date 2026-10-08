/// Stable operation identities; existing display titles and cache stay intact.
enum ExploreInput { image, option, color, reference }

enum ExploreOperation {
  changeColor('Change Color', ExploreInput.color),
  customizeRims('Customize Rims', ExploreInput.option),
  suspension('Suspension', ExploreInput.option),
  neons('Neons', ExploreInput.option),
  tire('Tire', ExploreInput.option),
  spoiler('Spoiler', ExploreInput.option),
  soundSystem('Sound System', ExploreInput.option),
  windowTints('Window Tints', ExploreInput.option),
  exhaust('Exhaust', ExploreInput.option),
  chromeDelete('Chrome Delete', ExploreInput.option),
  bodyKit('Body Kit', ExploreInput.option),
  perspective('Perspective', ExploreInput.option),
  mirrorSwap('Mirror Swap', ExploreInput.option),
  sunroofMood('Sunroof Mood', ExploreInput.option),
  putOnSticker('Put On Sticker', ExploreInput.option),
  upholstery('Upholstery', ExploreInput.option),
  american('American'),
  japanese('Japanese'),
  offRoad('Off Road'),
  suv('SUV'),
  racing('Racing'),
  mostWt('Most WT'),
  countryside('Countryside'),
  tunerShop('Tuner Shop'),
  crystal('Crystal'),
  nightCity('Night City'),
  carEnhance('Car Enhance'),
  speedTrap('Speed Trap'),
  grandCityAuto('Grand City Auto'),
  dreamCarAndMe('Dream Car & Me'),
  aiCrashEffect('AI Crash Effect'),
  aiCarRestore('AI Car Restore'),
  miniToyCar('Mini Toy Car'),
  modyAiTechnic('Mody AI Technic'),
  carFigurine('3D Car Figurine'),
  transformers('Transformers'),
  cloneCarStyle('Clone Car Style', ExploreInput.reference);

  const ExploreOperation(this.title, [this.input = ExploreInput.image]);
  final String title;
  final ExploreInput input;

  static ExploreOperation? fromTitle(String title) {
    for (final operation in values) {
      if (operation.title == title) return operation;
    }
    return null;
  }
}
