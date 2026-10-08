/// Stable identities for the existing static AI Video cards, not API models.
enum AiVideoTemplate {
  apexTransform('Apex Transform'),
  pitStopTransformation('Pit Stop Transformation'),
  magneticTransformation('Magnetic Transformation'),
  neonTransformation('Neon Transformation'),
  classicTransformation('Classic Transformation'),
  cliffFly('Cliff Fly'),
  cliffDrive('Cliff Drive'),
  snowDrift('Snow Drift'),
  cityDrive('City Drive'),
  desertDrive('Desert Drive'),
  zoomOut('Zoom Out'),
  zoomIn('Zoom In'),
  hydraulicHeatwave('Hydraulic Heatwave'),
  raceVideo('Race Video'),
  driftShowdown('Drift Showdown');

  const AiVideoTemplate(this.title);
  final String title;

  static AiVideoTemplate? fromTitle(String title) {
    for (final template in values) {
      if (template.title == title) return template;
    }
    return null;
  }
}
