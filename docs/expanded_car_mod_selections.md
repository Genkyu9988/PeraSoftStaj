# Expanded Car Mods detail selections

Implemented 2026-10-03 for Chrome Delete, Body Kit, Perspective, Mirror Swap,
Sunroof Mood, Put On Sticker and Upholstery. These are proposed app-specific
options, not verified copies of the original application's unseen pickers.
Transformers and Clone Car Style remain deferred pending their original flows.
Follow-up: Spoiler, Sound System, Window Tints and Exhaust are now implemented
with three choices each. Every Car Mods card now has its detail selection flow.

## Remaining four cards — follow-up

- Spoiler: racing wing, curved sporty wing, roof/rear-window spoiler.
- Sound System: boxed trunk subwoofer, compact tweeter, multi-speaker installation.
- Window Tints: light smoke, dark smoke, reflective appearance. These labels are
  visual examples, not measured VLT percentages or road-use suitability claims.
- Exhaust: single round tip, four dark tips, four metallic tips.

Four Commons thumbnails were downloaded and visually checked; eight previews
reuse existing assets. Source/license information is in IMAGE_CREDITS.txt.
Sound system changes need suitable visible interior/open-trunk input to have a
visible effect once an AI service is attached. No sound playback or AI edit is
performed now. Vehicle selection remains the local catalog (no camera/gallery).

No new screen, persistence manager, dependency or global selection state was
introduced: this continues the #4 asset-widget, #13 sheet-result, #14 callback,
#6 state update and #12 cache-manager approach described below. Card readiness
is derived from the populated catalog. Options commit only on Apply, can be
cleared independently, and restore by ID through the existing cache manager.
In addition to the all-group tests, remaining_car_mods_test.dart navigates from
Explore through vehicle selection and modification Apply, checks both previews,
and returns/reopens each of the four cards at 320px.

## Catalog

| Category | Choices |
| --- | --- |
| Chrome Delete | Black grille; black window surrounds |
| Body Kit | Side skirt; wide body; rear diffuser |
| Perspective | Front three-quarter; rear three-quarter; side |
| Mirror Swap | Black housing; carbon weave housing |
| Sunroof Mood | Panoramic glass; closed interior shade; dual glass panels |
| Put On Sticker | Twin racing stripes; leaf-pattern wrap; racing graphics |
| Upholstery | Black leather; tan leather; red centers with black bolsters |

19 options use stable IDs, display labels, asset paths and separate generation
instructions. Instructions are metadata for future AI integration; no API call
is made. Reference brand, model, advertising and scene are not generation targets.
Perspective photos are not identical vehicles. Front/rear photos are angled,
so labels explicitly say three-quarter rather than claiming straight-on views.
The roof open/closed source filenames refer to the interior shade; the UI does
not falsely describe open glass. Upholstery/shade effects require a suitable
interior input to be visible; the current sample catalog remains exterior cars.

## Teaching foundations vs project decisions

- #13 transcript 16:48–17:25 and 17:30 onward: closing a sheet and updating the
  caller, context lifetime warning. Repo: lib/202/sheet_learn.dart.
  Existing showSelectionSheet<String> returns Future<String?>. null cancels;
  mounted is checked after await. A draft does not commit until Apply.
- #14 transcript 10:47–11:25: callback notification from child to parent.
  Repo: lib/product/widget/callback_dropodown.dart and lib/303/call_back_learn.dart.
  Existing panel emits IDs; screen owns selection, clearing and persistence.
- #6 statefull_learn.dart: setState updates the displayed preview.
- #4 image_learn.dart: paths in ImageItems, shared asset image widget, no
  duplicated image loading code per screen.
- #12 transcript 32:39–33:09; lib/202/cache/user_cache/user_cache_manager.dart:
  retain the existing manager boundary. UI never calls SharedPreferences directly.

All repo paths above are relative to https://github.com/VB10/Flutter-Full-Learn.
These are adaptations, not a claim the teacher wrote this car editor, prescribed
these IDs or named these options. No new dependency or state management package.

## Integrity and verification

Readiness derives from actual CarModCatalog groups, avoiding a second manual
list that can drift. Unknown screen titles no longer silently become Tire.
Empty/invalid/foreign-group saved IDs restore as no selection. Empty legacy
names on new options must never cause an empty selection to select option one.
Apply is enabled only when its ID belongs to the current panel's options.

Tests cover every group's images and labels, last-option selection, Apply vs
cancel at 320/390 widths, restored selection marker, independent clear buttons,
cover preservation, cache-manager round trips, invalid IDs, and asset decoding.
Seven new downloaded photos have attribution in assets/IMAGE_CREDITS.txt;
other choices reuse existing credited assets without modifying their pixels.
