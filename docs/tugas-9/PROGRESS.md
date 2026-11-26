# Individual Assignment 9 — Progress & Traceability

## Prerequisite Audit (R01)

- **Flutter repo (`myportofolio_mobile`)**: Verified locally on branch `main` at `37b9b7c` (`origin/main` local tracking ref matches `37b9b7c`). Working tree was clean before Checkpoint 1.
- **Django repo (`myportofolio`)**: Historical baseline `833844e` per `MASTER-CONTEXT` (read-only source inspection confirmed Tutorial 10 auth/CORS files present; sandbox prevented `git -C ../myportofolio` execution).
- **Unverified remotely in this session**: GitHub Actions workflow run for `37b9b7c`, downloadable `app-release-apk` artifact from Tutorial 10, and SCELE submission timestamps.

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
| R01 | Tutorial 10 prerequisite verified | PARTIAL | Local HEAD `37b9b7c` matches `origin/main`; remote CI & SCELE unverified |
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
| R25 | Successful GitHub Actions build | NOT STARTED | Checkpoint 5 |
| R26 | Successful `build_apk` and downloadable `app-release-apk` | NOT STARTED | Checkpoint 5 |
| R27 | CI badge at top of README | NOT STARTED | Checkpoint 5 |
| R28 | Setup instructions and `API_BASE_URL` | NOT STARTED | Checkpoint 5 |
| R29 | Actual backend repository/deployed API reference | NOT STARTED | Checkpoint 5 |
| R30 | Four reflective answers | NOT STARTED | Checkpoint 5 |
| R31 | Transparent AI disclosure | NOT STARTED | Checkpoint 5 |
| R32 | Public GitHub repository and final commit URL | NOT STARTED | Checkpoint 5 |
| R33 | Meaningful additional automated testing | IN PROGRESS | Django +4 API tests (111 total); Flutter `certification_form_test.dart` integration suite (61 total) |
| R34 | Format, analyzer, and clean modular code | PARTIAL | Verified for Checkpoint 3 scope |
| R35 | Five genuine progressive commits | PARTIAL | Checkpoints 1–2 committed (`542490e`, `a44d10c`, `1d2475b`); Checkpoint 3/5 pending manual commit |

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
- Django commit: `PENDING MANUAL COMMIT` (`fix(api): enable token authentication for certifications`)
  - Files: `main/api_views.py`, `main/tests_api.py` (3 pre-existing `docs/tugas-6/*` deletions preserved outside staging)
- Flutter commit: `PENDING MANUAL COMMIT` (`feat(certifications): connect protected form to DRF API`)
  - Files: `lib/screens/certification_form.dart`, `lib/screens/certification_list_screen.dart`, `lib/screens/menu.dart`, `lib/widgets/left_drawer.dart`, `test/certification_form_test.dart`, `test/widget_test.dart`, `docs/tugas-9/PROGRESS.md`
- Verification:
  - Django: `check` PASS, `migrate --check` PASS, `makemigrations --check --dry-run` PASS, `test main` **111/111 PASS** (27.022s).
  - Flutter: `dart format --output=none --set-exit-if-changed lib test` PASS (26 files, 0 changed); `flutter analyze --no-pub` PASS (0 issues); focused (`certification_form_test.dart` + `widget_test.dart`) **47/47 PASS**; full suite **61/61 PASS**; `flutter build web --no-pub --dart-define=API_BASE_URL=http://127.0.0.1:8000` PASS.
  - Live HTTP smoke (`127.0.0.1:8009`, SQLite): anonymous GET `200`, token login `200`, superuser token POST `201`, persisted GET `200` (`True`), revoked token POST `401`, QA fixtures cleaned up.
- Remaining QC (Checkpoints 4–5): Browser/Playwright end-to-end QA, responsive live browser audit, clean-checkout codegen check, CI badge, README setup/reflections/AI disclosure, final report, and remote GitHub Actions + `app-release-apk` verification.
