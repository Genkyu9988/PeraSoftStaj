"""Supported behavior IDs match Flutter enums; catalog labels are not code."""
OPERATIONS = dict(zip(
    'changeColor customizeRims suspension neons tire spoiler soundSystem windowTints exhaust chromeDelete bodyKit perspective mirrorSwap sunroofMood putOnSticker upholstery american japanese offRoad suv racing mostWt countryside tunerShop crystal nightCity carEnhance speedTrap grandCityAuto dreamCarAndMe aiCrashEffect aiCarRestore miniToyCar modyAiTechnic carFigurine transformers cloneCarStyle'.split(),
    ['Change Color', 'Customize Rims', 'Suspension', 'Neons', 'Tire', 'Spoiler', 'Sound System', 'Window Tints', 'Exhaust', 'Chrome Delete', 'Body Kit', 'Perspective', 'Mirror Swap', 'Sunroof Mood', 'Put On Sticker', 'Upholstery', 'American', 'Japanese', 'Off Road', 'SUV', 'Racing', 'Most WT', 'Countryside', 'Tuner Shop', 'Crystal', 'Night City', 'Car Enhance', 'Speed Trap', 'Grand City Auto', 'Dream Car & Me', 'AI Crash Effect', 'AI Car Restore', 'Mini Toy Car', 'Mody AI Technic', '3D Car Figurine', 'Transformers', 'Clone Car Style'], strict=True))
VIDEOS = 'apexTransform pitStopTransformation magneticTransformation neonTransformation classicTransformation cliffFly cliffDrive snowDrift cityDrive desertDrive zoomOut zoomIn hydraulicHeatwave raceVideo driftShowdown'.split()
GENERATE_FIELDS = ['mode', 'style', 'extra', 'color', 'angle', 'description']
EXPLORE_FIELDS = ['operation', 'optionId', 'color', 'referenceId']
DIRECT_FIELDS = ['mode', 'style', 'extra', 'color', 'angle', 'description', 'operation', 'template']
