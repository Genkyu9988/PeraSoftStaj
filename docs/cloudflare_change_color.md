# Cloudflare Change Color and Spoiler — 15-call local experiment

## Verification (2026-10-09)

Extension: Spoiler is wired through `/api/v1/ai/spoiler` with the shared cap
raised to 15. Enabling it preserved 2 existing attempts (13 remaining) and
backed up the database. Automated tests mock inference. A subsequent live
Spoiler test (Mustang + Sportif Kanat) failed with provider HTTP 400; the exact
provider rejection reason is not yet diagnosed. The failed attempt counts
toward the shared cap. The user is continuing with Change Color only for now.
Spoiler remains wired in code but is experimental, not live-verified working.
AI may alter unrelated car details.

The Android x86_64 debug build was installed without clearing app data. One real
request was submitted from Explore → Change Color (Klasik Mustang → Mavi).
Django received a successful provider result, served the generated image, and
published it once. After a full app restart, Garage still displayed the AI image.
At that initial verification, the ledger contained **1 completed/published attempt**. The existing
8 demo records remain; database integrity check returned `ok`.
The model changed some car details as well as paint; this is not a pixel-exact
paint-only editor. No second inference was run to improve the result.

**Explore → Change Color and Spoiler** can use real inference. Other image and video
operations remain explicitly labelled demos. There is no gallery or upload UI.
The server resolves a bundled vehicle photo from the SQLite catalog; arbitrary
URLs, paths, prompts and model names cannot be supplied by Flutter.

## Setup and run

The Cloudflare dashboard was checked on 2026-10-09: **Workers Free / Active**,
**No payment method on file**. Keep this account on Free. Never enable Paid,
prepaid credits or another provider. Free-plan quota exhaustion rejects calls;
this application does not purchase credits or upgrade plans.

1. Store the Workers AI Read/Edit token using `backend/configure_cloudflare.py`.
   Input is hidden. The ignored `.cloudflare.local.json` is local plaintext,
   not an encrypted vault. Do not share it. It is not the Flutter backend token.
2. Install `backend/requirements.txt` in the backend venv.
3. Run `backend/enable_cloudflare.py`. It backs up the existing central database,
   adds `ai_attempts` without altering demo tables, and enables inference.
   Re-running this command **does not reset** the attempt ledger.
4. Restart Django, then run Flutter with:

```powershell
flutter run -d emulator-5554 --dart-define-from-file=backend/flutter.local.json --dart-define=MODY_REAL_AI=true
```

Omit `MODY_REAL_AI` to retain all-demo behavior. SQLite-only mode never sends
real generation requests. Provider keys are never compiled into Flutter.

## Behavior and storage

- Fixed model: `@cf/black-forest-labs/flux-2-klein-4b`. Input is resized below
  512×512; output requests 768×512. No automatic model fallback or retries.
- A single atomic SQL reservation precedes each provider call. All attempts,
  including errors, timeouts and cancellations, count toward the lifetime cap
  of **15 shared across both operations** in this database. Previous attempts remain counted. Only one pending call is allowed.
- Spoiler uses the bundled vehicle as `input_image_0` and the selected catalog
  part as `input_image_1`, each below 512×512. Django validates the part belongs
  to Spoiler before reserving a slot. Flutter sends only the part ID, not a URL.
- IDs make ambiguous client retries idempotent. A completed ID returns its
  stored result. Failed/pending IDs are never resubmitted to the provider.
- A definitive 502 allows a user's **explicit** Retry to reserve a new slot.
  Unknown transport failures retain the ID. An interrupted server may leave a
  pending row: intentionally fail closed, inspect it before proceeding; never
  delete/reset the ledger merely to bypass the cap.
- Dismissal hides the result and prevents adding it to the visible history;
  it cannot cancel a request already sent to Cloudflare or refund the slot.
- Images are small JPEG BLOBs in `ai_attempts`, served through an authenticated
  Django endpoint. History stores a `mody-media:<id>` reference, not the key.
  A successful result is published to shared history only when Flutter accepts
  completion. Client-submitted forged or altered AI results are rejected.
- Existing `creations` records and the local SQLite rollback mode are preserved.
- The existing vehicle picker still selects a catalog vehicle ID. Selecting a
  history card as an input does not yet chain its AI output into another edit.

This is a local development experiment, not a production multi-user service.
The 15-call cap does not constrain unrelated usage elsewhere in the account.
The real image may change details besides paint; inspect quality before expanding.

## Tests

`backend/test_ai_generation.py` mocks the provider (no quota use), checking limits,
idempotence, publication, authentication, invalid inputs and multipart format.
`test/cloudflare_generation_test.dart` checks typed real results, transport retry
IDs, explicit retry, demo routing, history and forged media rejection.

## Official sources

- https://developers.cloudflare.com/workers-ai/platform/pricing/
- https://developers.cloudflare.com/changelog/post/2026-01-15-flux-2-klein-4b-workers-ai/
- https://developers.cloudflare.com/workers-ai/get-started/rest-api/

Cloudflare skill guidance informed the direct REST integration with the existing
Django backend. No Workers deployment, extra database service or paid service
was added. No claim is made that a teacher video covers this provider API.
