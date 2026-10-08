# Transformers and Clone Car Style

## Scope

- Transformers uses the existing vehicle catalog, sample row and single image input.
- Clone uses the same vehicle input plus an independent reference image input.
- Both are reachable from Explore's expanded AI Edits grid.
- Reference selection reuses the Neon/Tire `MockOptionsSelectionPanel` and
  `showSelectionSheet<String>` draft/apply/cancel behavior. `ImageChoice` is only
  the shared presentation contract; references are not stored as Car Mod options.
- Four existing credited photos are reused: wide body, racing appearance, leaf
  wrap and red underglow. Their labels describe the inspected photos. Original
  application artwork is not bundled or claimed as reproduced.
- `referenceImage` stores a validated reference ID independently of the target
  vehicle ID and `option`. Missing/unknown IDs restore as empty. Other features
  discard reference IDs. Existing cache JSON remains readable.
- Removing either input leaves the other unchanged. Clone requires both inputs
  for its mock action; Transformers requires only a vehicle.
- AI Car Restore, Mini Toy Car, Mody AI Technic and 3D Car Figurine now use
  the same single-vehicle flow as Transformers. No variant input is added.
- No camera/gallery, history or real AI generation is added.

## Teaching sources and adaptation

Repository: https://github.com/VB10/Flutter-Full-Learn (main).
Times below come from the supplied transcripts, not a fresh full video playback.

- #4, 07:47–14:56 and 54:51–57:59: parameterized immutable widgets and shared
  image rendering (`lib/101/stateless_learn.dart`, `lib/101/image_learn.dart`).
  Existing image boxes are reused, rather than duplicating screens.
- #6, 24:14–27:59 and 52:17–55:43: local state and lifecycle initialization
  (`lib/101/statefull_learn.dart`, `lib/101/statefull_life_cycle_learn.dart`).
- #13: nullable generic sheet results and pop-based communication
  (`lib/202/sheet_learn.dart`); 17:30–17:58 warns about closed contexts.
  Draft/apply policy, duplicate-open guard and mounted checks are our safety
  adaptations, not claims of verbatim teacher code.
- #14, 10:47–11:51, 17:50–19:54: callbacks, binding selected values and model
  identity (`lib/303/call_back_learn.dart`,
  `lib/product/widget/callback_dropodown.dart`). Stable reference IDs are our
  adaptation. Tests cover 320 and 390 logical pixel widths, reflecting the
  small-screen concerns discussed at 57:21–58:44.
- #12, 32:28–34:33: reusable storage managers
  (`lib/202/cache/shared_manager.dart`,
  `lib/202/cache/user_cache/user_cache_manager.dart`). Existing app cache is reused;
  storing separate vehicle/reference IDs is a product-specific decision.

Tests: `test/ai_edit_selection_test.dart` covers navigation, all four reference
previews, apply/cancel, independent clears, restore and manager JSON round trips.

## Remaining four cards: reuse instead of rebuilding

The cards were blocked by `pendingAiEdits`, not by missing picker infrastructure.
Remove that obsolete gate and reuse the existing detail route, catalog, callbacks
and cache. #7 at 80:38–81:59 and 83:42–84:46 is the direct navigation reference:
https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/101/navigation_learn.dart.
Its shared navigation method accepts a destination widget; our existing
`openPage` helper serves the same purpose without adopting its mixin verbatim.
#4's parameterized widget approach avoids four duplicated pages. #13's shared
sheet, #14's callbacks and #6/#12's state/cache remain existing infrastructure,
not newly implemented layers for this change.

`test/remaining_ai_edits_test.dart` covers each card at 320/390 widths:
navigation and matching cover, absence of a second input, draft cancellation,
apply and preview, reopening, clear, samples, mock action, independent cache
round trips and persisted clearing.
