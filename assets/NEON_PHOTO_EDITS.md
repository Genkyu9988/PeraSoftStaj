# Neon photographic previews

Created 2026-10-02 using built-in image_gen edit mode (not the CLI or an app API).
These illustrative previews are edited real photographs, not unedited photos
of five separate lighting installations and not generated results from Mody AI.

Source: Michael from Calgary, AB, Canada, *My Accent SR with LED underbody
Lights (2539840531)*, [Wikimedia Commons](https://commons.wikimedia.org/w/index.php?curid=70194159),
[original Flickr](https://www.flickr.com/photos/msvg/2539840531/),
[CC BY 2.0](https://creativecommons.org/licenses/by/2.0/).

## Saved assets

- `images/neon_red_photo.jpg`: original resized source, no color edit.
- `images/neon_purple_photo.png`: COLOR = vivid purple.
- `images/neon_cyan_photo.png`: COLOR = bright cyan.
- `images/neon_green_photo.png`: COLOR = vivid green.
- `images/neon_multicolor_photo.png`: COLOR = a visible multicolor blend of cyan, purple and pink.

## Exact prompt template

One independent edit per COLOR, always using the original photo as input:

```text
Use case: lighting-weather. Asset type: Flutter car-mod selection photographic preview. Input image 1 is the edit target, a licensed real photograph. Change ONLY the underbody LED strips under the rear bumper and side sill and their nearby emitted light on the pavement to COLOR. Keep this exact photograph: same Hyundai hatchback, body paint, wheels, RED rear lamps, license plate, parked vehicles, houses, warm orange street lighting, perspective, framing and textures. Do not recolor the body or background. Photorealistic localized light edit, no illustration, no new car, no text, no watermark, no collage. Preserve landscape aspect ratio.
```

Outputs were visually checked for the intended underglow color and preserved
scene. Generative editing is not guaranteed to preserve every source pixel.
Stable option IDs, labels, generation instructions and selection storage are
unchanged. All five previews use the existing local-asset image component.
