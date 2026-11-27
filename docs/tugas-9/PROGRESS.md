# Individual Assignment 9 — Progress & Traceability

## Prerequisite Audit (R01)

- **Tutorial 10 (`myportofolio_mobile`):** Commit `37b9b7cb2dc1fe278f143fa32432264c279de28d` (`2026-11-24T04:37:38Z` = 11:37 WIB, before 25 Nov 2026 23:59 WIB deadline). GitHub Actions Run `45327694076` -> **PASS** (`success`, artifact `app-release-apk` present).
- **Tutorial 10 (`myportofolio`):** Commit `833844ea099497260ef03ecfab7f346fa2c36c71`.
- **Checkpoint 1–3 Remote & CI Evidence:**
  - CP1 `542490e` -> Run `45744074546` (`success`).
  - CP2 corrective `1d2475b` -> Run `45761706529` (`success`).
  - CP3 Flutter `d4ee23d` + corrective `d6bc863` -> Run `45783916874` (`success`, `build / build` + `build_apk` + artifact `app-release-apk`).
  - CP3 Django `410287ed49cdc5950062e3ca55545d9f36c57ff3` verified on remote `refs/heads/main`.
- **Unverified externally:** User SCELE portal submission receipt.

## Authoritative Certification API Contract

Source: `myportofolio/main/models.py` (`Certification`), `myportofolio/main/serializers.py` (`CertificationSerializer`), `myportofolio/main/api_urls.py`, `myportofolio/main/permissions.py`, `myportofolio/main/api_views.py`.

Endpoint: `/api/v1/certifications/` (`GET`, `HEAD`, `POST`)

| JSON field | Dart property | Django field type | Dart type | Required for POST | Nullable | Read-only | Default | Validation |
|---|---|---|---|---|---|---|---|---|
| `id` | `id` | `BigAutoField` (int PK) | `int?` | No (`includeToJson: false`) | Yes (unsaved) | Yes | `null` | Server-assigned integer PK |
| `name` | `name` | `CharField(max_length=255)` | `String` | Yes | No | No | - | `strip_tags().strip()`, non-empty, max 255 |
| `issuing_organization` | `issuingOrganization` | `CharField(max_length=255)` | `String` | Yes | No | No | - | `strip_tags().strip()`, non-empty, max 255 |
| `issue_date` | `issueDate` | `DateField` | `String` | Yes | No | No | - | `YYYY-MM-DD` date string |
| `expiration_date` | `expirationDate` | `DateField(blank=True, null=True)` | `String?` | No | Yes | No | `null` | `YYYY-MM-DD` or `null`; >= `issue_date` on form |
| `credential_id` | `credentialId` | `CharField(max_length=255)` | `String` | Yes | No | No | - | `strip_tags().strip()`, non-empty, max 255 |
| `credential_url` | `credentialUrl` | `URLField(max_length=200)` | `String` | Yes | No | No | - | Valid HTTP/HTTPS URL, max 200 |
| `star_count` | *(ignored)* | `SerializerMethodField` | - | No | No | Yes | - | Computed integer count |
| `is_starred` | *(ignored)* | `SerializerMethodField` | - | No | No | Yes | - | Computed boolean |
| `starred_by_names` | *(ignored)* | `SerializerMethodField` | - | No | No | Yes | - | Comma-separated usernames |

## Critical Backend Finding & Resolution (Checkpoint 3)

- **Root Cause:** `myportofolio/main/api_views.py:91` previously decorated `certification_list` with `@authentication_classes([SessionAuthentication])` only, overriding DRF's `DEFAULT_AUTHENTICATION_CLASSES` and ignoring `Authorization: Token <key>`.
- **Fix Applied (`main/api_views.py:91`):** Enabled `@authentication_classes([ProjectTokenAuthentication, SessionAuthentication])` alongside existing `IsPortfolioOwnerOrEditorOrReadOnly` permissions.
- **Preserved Behavior:** Public `GET /api/v1/certifications/`, superuser-only `POST`, `Editor` edit-only privileges (`403` on `POST`), `SessionAuthentication` + CSRF enforcement, `401` on invalid/revoked tokens, and `403` on unauthenticated web writes without a token.
- **Backend Verification:** Added 4 tests in `main/tests_api.py` (`CertificationAPITest`); `manage.py check`, `migrate --check`, `makemigrations --check --dry-run` PASS; full `manage.py test main` **111/111 PASS** (27.022s).

## Requirements Traceability Matrix

| ID | Mandatory Requirement | Status | Notes |
|---|---|---|---|
| R01 | Tutorial 10 prerequisite verified | PASS | SHA `37b9b7c` (24 Nov 11:37 WIB) + Actions Run `45327694076` `success` (`app-release-apk`); SCELE submission user-managed |
| R02 | Certification JSON model matches actual DRF serializer | PASS | `lib/models/certification.dart` aligned with `CertificationSerializer` |
| R03 | JsonSerializable snake_case mapping | PASS | `@JsonSerializable(fieldRename: FieldRename.snake)` |
| R04 | Server-generated ID excluded from POST | PASS | `@JsonKey(includeToJson: false)` on `int? id` |
| R05 | Appropriate optional-field defaults | PASS | `String? expirationDate` defaults to `null` |
| R06 | Generated `*.g.dart` and Git/analyzer exclusions | PASS | `lib/models/certification.g.dart` generated, ignored in `.gitignore` & `analysis_options.yaml` |
| R07 | Public GET Certifications | PASS | `ApiClient.getCertifications()` without `Authorization` header |
| R08 | Authenticated POST Certifications | PASS | Protected `CertificationFormPage` + backend `ProjectTokenAuthentication` |
| R09 | Authorization: Token header | PASS | Reuses `ApiClient._request` `Token <key>` header |
| R10 | Public Certification List screen | PASS | `lib/screens/certification_list_screen.dart` |
| R11 | Future initialized in `initState` | PASS | `_certifications` assigned in `initState()`, reused across rebuilds |
| R12 | Loading state | PASS | `CircularProgressIndicator` during initial load |
| R13 | Error state and Retry | PASS | `ApiException` message + `Coba lagi` button calling `_refresh` |
| R14 | Empty state | PASS | Scrollable `'Belum ada sertifikasi.'` inside `RefreshIndicator` |
| R15 | RefreshIndicator | PASS | `RefreshIndicator` with synchronous `setState` assignment + await outside `setState` |
| R16 | Dedicated Detail screen displaying all relevant fields | PASS | `lib/screens/certification_detail_screen.dart` displays all 6 fields |
| R17 | Homepage and LeftDrawer integration | PASS | `Lihat Sertifikasi` card on Home + `View Certifications` in `LeftDrawer` |
| R18 | Existing Assignment 8 Form refactored | PASS | `lib/screens/certification_form.dart` preserves validation/dates + connects API |
| R19 | `ensureLoggedIn` route/submission guard | PASS | Home card, `LeftDrawer`, list `+` action, and form submission guarded |
| R20 | `AuthState` token used for POST | PASS | Reads `AuthState.token` before `ApiClient.createCertification()` |
| R21 | `ApiException` and error SnackBar | PASS | Handles 400/403/5xx/network errors while preserving inputs |
| R22 | HTTP 401 clears session and requests login | PASS | Calls `auth.invalidate(token)`, shows SnackBar, triggers `ensureLoggedIn`, no auto-replay |
| R23 | Successful POST confirmation | PASS | Resets form on 201 and shows server-returned data in `AlertDialog` |
| R24 | New Certification appears after refresh/navigation | PASS | `'Lihat Daftar'` refreshes `CertificationListScreen` or replaces form with list |
| R25 | Successful GitHub Actions build | PARTIAL | CP4 `2783432` Run `45867103933` `build / build` PASS; final CP5 commit awaits manual push & post-push check |
| R26 | Successful `build_apk` and downloadable `app-release-apk` | PARTIAL | CP4 Run `45867103933` `build_apk` PASS (`24,273,326` bytes) + local release APK `52,344,297` bytes PASS; final CP5 remote check pending push |
| R27 | CI badge at top of README | PASS | Dynamic `main.yaml?branch=main` badge added at top of `README.md` |
| R28 | Setup instructions and `API_BASE_URL` | PASS | Portable 11-step setup, `build_runner` note, `--dart-define=API_BASE_URL`, Web & `adb reverse` Android docs in `README.md` |
| R29 | Actual backend repository/deployed API reference | PASS | Public repo `glennjosia7/myportofolio` + commit `410287e` linked; PWS `404` documented accurately without inventing URLs |
| R30 | Four reflective answers | PASS | Heading `### Assignment 9` with Indonesian numbered answers 1–4 grounded in actual code & CI steps |
| R31 | Transparent AI disclosure | PASS | Transparent tool list, 5-checkpoint workflow, `mobile-agent-testers` adaptation, and actual Git/DOM/host limitations in `README.md` |
| R32 | Public GitHub repository and final commit URL | PARTIAL | Both repos verified `PUBLIC`; final CP5 commit awaits manual commit/push before generating SCELE URL |
| R33 | Meaningful additional automated testing | PASS | Django `111/111 PASS`; Flutter `67/67 PASS`; native headless Android smoke `A01`–`A14` PASS |
| R34 | Format, analyzer, and clean modular code | PASS | `build_runner` PASS, `dart format` 0 changes (26 files), `flutter analyze` 0 issues, `flutter build web` PASS |
| R35 | Five genuine progressive commits | PARTIAL | CP1–CP4 published (`542490e`, `a44d10c`, `1d2475b`, `d4ee23d`, `d6bc863`, `d2cc88a`, `2783432`); CP5 docs ready for manual 8th Flutter commit |

## Checkpoints

### Checkpoint 1/5 — Foundation & JSON Model
- Commit: `542490e4da9dc9fe9459d975842ddb268460fc25` (`feat(certifications): add DRF-aligned certification model`)
- Files: `lib/models/certification.dart`, `test/certification_model_test.dart`, `docs/tugas-9/PROGRESS.md`
- Verification: `dart run build_runner build` PASS; `dart format --output=none --set-exit-if-changed lib test` PASS; `flutter analyze --no-pub` PASS (0 issues); `test/certification_model_test.dart` 4/4 PASS; full suite 49/49 PASS (45 existing + 4 new).

### Checkpoint 2/5 — API Client & Public Read
- Main commit: `a44d10c814d9365e77c771373f39f8e09b442043` (`feat(certifications): integrate public list and detail screens`)
- Corrective test commit: `1d2475b2bdd72f9c90582fbc51e1226e5bf8c25f` (`test(certifications): complete public read regression coverage` — `test/certification_api_test.dart`, `test/certification_list_test.dart`, `test/widget_test.dart`)
- Verification: `dart format --output=none --set-exit-if-changed lib test` PASS (26 files, 0 changed); `flutter analyze --no-pub` PASS (0 issues); focused tests 5/5 PASS; full suite 54/54 PASS; `flutter build web --no-pub --dart-define=API_BASE_URL=http://127.0.0.1:8000` PASS.

### Checkpoint 3/5 — Authenticated Certification Form & Backend Token Auth Fix
- Django commit: `410287ed49cdc5950062e3ca55545d9f36c57ff3` (`fix(api): enable token authentication for certifications`)
- Flutter commits: `d4ee23d443cfe3f0fe9998617cf32ade9a36dc31` (`feat(certifications): connect protected form to DRF API`) and corrective `d6bc863aba71812965b73dd73ca6b3d4ebdf9a45` (`test(certifications): complete protected navigation regression coverage`); CI Run `45783916874` **PASS**.

### Checkpoint 4/5 — Advanced Testing, Independent Mobile QC, Security & Real E2E
- Initial QC commit: `d2cc88a812b73d94f76659e62024fbf3dd5d1163` (`fix(certifications): resolve QC defects and strengthen regression coverage` — 6 files)
- Corrective commit: `278343251b0b065e52954f5b61a754657bb8d9b5` (`fix(qc): complete responsive navigation and auth regression fixes` — remaining 8 files)
- CI Evidence: Run `45867103933` on `2783432` **PASS** (`build / build`: `success`, `build_apk`: `success`, artifact `app-release-apk` `24,273,326` bytes).
- Independent QC (`mobile-agent-testers` SHA `494a15b` persona framework): 0 P0, 1 P1 (`QC-01`), 9 P2 (`QC-02`–`QC-08`, `QC-10`, `QC-11`), 1 P3 (`QC-09`) — all fixed & retested. Detailed evidence in `docs/tugas-9/QC_REPORT.md`.
- Headless Chrome E2E (`127.0.0.1:8089` -> `127.0.0.1:8009`): `E01`–`E27` (24/27 directly asserted in Chrome; `E17`/`E18`/`E21` complemented by `E22` retry & widget assertions; `E04` desktop `Muat ulang` + widget pull-to-refresh; 4-viewport sweep `0` errors; QA cleanup `0` leftover records/users).

### Checkpoint 5/5 — Final Quality Gate, Android Runtime, Documentation & Release Prep
- Commit: `PENDING MANUAL COMMIT` (`docs(assignment-9): finalize certification integration and release readiness`)
- Files: `README.md`, `docs/tugas-9/PROGRESS.md`, `docs/tugas-9/FINAL_REPORT.md`
- Verification:
  - CP4 CI verified green (`45867103933`); QC-01..QC-11 verified in source `2783432` (`0` new defects).
  - Flutter Quality Gate: `build_runner build` PASS; `dart format` PASS (26 files, 0 changed); `flutter analyze` PASS (`0 issues`); `flutter test` **67/67 PASS**; `flutter build web --dart-define=API_BASE_URL=http://127.0.0.1:8000` PASS.
  - Django: unchanged at `410287e` (verified **111/111 PASS** baseline preserved; `0` leftover QA rows).
  - Local Release APK: `flutter build apk --no-pub --release` PASS (`build/app/outputs/flutter-apk/app-release.apk`, `52,344,297` bytes).
  - Android Runtime Smoke (`Medium_Phone_API_37.0`, `adb reverse tcp:8000 tcp:8000`, `127.0.0.1:8000`): `A01`–`A14` **PASS** (`POST 201`, detail 6 fields, `View Projects 200`, `Logout 204`, zero logcat fatal errors, DB cleanup `0` leftover QA rows). PWS `https://glenn-josia-myportofolio.pws.cs.ui.ac.id/api/v1/certifications/` checked -> `404`.

## Rubric Self-Assessment (Evidence-Based, No Grade Guarantee)

| Criterion (Weight) | Target Level | Supporting Verified Evidence |
|---|---|---|
| Functionality & Topic Fit (70%) | Level 4 candidate | Full GET/Detail + token-authenticated POST + 401/403 + real E2E + live revoked-token 401 + native Android smoke + meaningful `MockClient`/widget tests (`67` Flutter, `111` Django) + CI APK (`app-release-apk` pending final CP5 push re-verify) |
| Code Quality & Structure (10%) | Level 3.5–4 candidate | Strong typing, modular `lib/{models,services,widgets,screens}` + `MultiProvider`, `dart format` 0 changes, `flutter analyze` 0 issues, 11 QC defects resolved (note: uses standard `flutter_lints`, not `very_good_analysis`) |
| Git & Discipline (10%) | Level 3.5–4 candidate | Incremental 5-checkpoint conventional commits excluding `*.g.dart`, transparent corrective commits (`1d2475b`, `d6bc863`, `2783432`) without rewriting history, ahead of 30 Nov 2026 deadline |
| Documentation, AI & Reflections (10%) | Level 4 candidate | Dynamic CI badge, portable setup + backend commit `410287e`, 4 grounded Indonesian reflections, critical AI disclosure documenting `mobile-agent-testers` & actual limitations, `FINAL_REPORT.md` + `PROGRESS.md` + `QC_REPORT.md` |
