# Explore: local catalog expansion

Update: the seven expanded Car Mods detail flows are now implemented; see
expanded_car_mod_selections.md. The deferred-detail description below records
the earlier main-screen-only milestone, not their current readiness.

Scope: main Explore cards only. Car Mods starts with 9 and expands to 16;
AI Edits starts with 9 and expands to 11. Horizontal sections are unchanged.
There is no network pagination or delayed/mock loading. Expansion lasts for the
lifetime of ExploreView, survives detail push/pop, and is not persisted to disk.

## Teaching references and adaptation

These are adaptations of foundations, not a claim that the teacher implemented
this exact screen or prescribed GridView/shrinkWrap for this application.

- #6 transcript 16:52–17:06: updating state rebuilds UI.
  https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/101/statefull_learn.dart
  Two private booleans in ExploreView own independent section expansion.
- #7 List lesson; repository itemBuilder/itemCount example:
  https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/101/list_view_builder.dart
  Catalog data supplies a builder rather than hand-written numbered cards.
  GridView instead of ListView is our three-column layout adaptation. It is
  non-scrollable inside the existing page scroll; shrinkWrap is appropriate for
  these bounded 16/11-item catalogs, not a prescription for unbounded feeds.
- #14 transcript 10:47–11:25: child-to-parent event notification.
  https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/303/call_back_learn.dart
  ExploreOptionGrid accepts callbacks and never owns navigation or mutates data.
  The existing ModyActionButton is reused without adding a dependency.
- #4 common asset widget and image path separation:
  https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/101/image_learn.dart
  ImageItems remains the path source; MockOptionCard/ModyAssetImage are reused.

## Deliberate limits

New detail screens are deferred. Tapping a new card displays an explanatory
SnackBar, rather than navigating to an empty picker incorrectly titled Tire.
The five existing Car Mods and five existing AI Edits detail flows are unchanged.
The readiness lists should be removed/replaced with typed capabilities when the
new detail flows are implemented. Saved titles and existing selection IDs were
not renamed. No cache migration is needed for this main-screen-only change.

Fourteen new source thumbnails are bundled. Existing spoiler/exhaust and classic
car photos are reused. AI Car Restore is a classic-car illustration, not a
before/after restoration. Transformers is an Optimus Prime statue, not a car
transformation. Clone Car Style shows two real cars, not an actual style transfer.
3D Car Figurine depicts a physical scale model, not a generated 3D object.
Chrome Delete represents black trim, not documented evidence of a modification.
Sources, creators and image licenses are in assets/IMAGE_CREDITS.txt.

Verification: expansion independence, end-of-list button removal, scroll
retention, existing detail navigation, deferred-detail feedback, 320/390 widths,
horizontal scrolling, and asset decoding/attribution coverage.
