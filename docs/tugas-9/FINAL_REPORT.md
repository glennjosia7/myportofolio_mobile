# Individual Assignment 9 — Final Release Report

**Student:** Glenn Josia Devano (NPM `2506614712`, Class PBP F, CSGE602022)  
**Repositories:**
- Flutter: `https://github.com/glennjosia7/myportofolio_mobile` (`public`)
- Django: `https://github.com/glennjosia7/myportofolio` (`public`, Assignment 9 commit `410287ed49cdc5950062e3ca55545d9f36c57ff3`)

---

## 1. Executive Summary

Assignment 9 successfully integrates the Flutter **Certifications** module (`Certification` model, public list & detail screens, Homepage & `LeftDrawer` navigation, and token-authenticated creation form) with the Django REST Framework `/api/v1/certifications/` backend. All 5 implementation and verification checkpoints completed without breaking Tutorial 08–10 or Assignment 7–8 features. Local verification on CP5 confirms `dart run build_runner build`, `dart format` (0 changes), `flutter analyze` (0 issues), **67/67** Flutter tests, **111/111** Django tests (backend unchanged at `410287e`), Web build, local release APK (`52,344,297` bytes), headless Chrome E2E, and headless Android emulator smoke QA (`A01`–`A14`). Final CP5 documentation commit and post-push GitHub Actions release verification await manual user commit and push.

## 2. Assignment Requirements

The authoritative requirements from `tugas-9.pdf` (`R01`–`R35`) are reconciled in [PROGRESS.md](PROGRESS.md). Implementation, quality gate, testing, Android smoke, CI configuration, README, CI badge, reflective answers, and AI disclosure are verified complete; final remote CI verification (`R25`, `R26`, `R32`, `R35`) remains open solely for the manual CP5 push.

## 3. Tutorial 10 Prerequisite Evidence

- **Flutter Tutorial 10 Commit:** `37b9b7cb2dc1fe278f143fa32432264c279de28d` (`2026-11-24T04:37:38Z` / `11:37:28 +0700`, before the 25 November 2026 23:59 WIB prerequisite deadline).
- **Django Tutorial 10 Commit:** `833844ea099497260ef03ecfab7f346fa2c36c71`.
- **GitHub Actions CI Evidence:** Run `45327694076` concluded `success` with downloadable `app-release-apk` artifact.
- **Boundary Note:** Technical completion is supported by Git and CI records; actual SCELE submission confirmation was not audited externally inside the workspace.

## 4. Actual Certification API Contract

Verified directly against `myportofolio/main/{models.py,serializers.py,api_urls.py,permissions.py,api_views.py}` (`/api/v1/certifications/`, `GET`, `HEAD`, `POST`):
- Payload fields: server-assigned `id` (`int?`, `BigAutoField`, excluded from `toJson`), `name` (`CharField(255)`), `issuing_organization` (`CharField(255)`), `issue_date` (`DateField` `YYYY-MM-DD`), optional nullable `expiration_date` (`DateField`, default `null`), `credential_id` (`CharField(255)`), and `credential_url` (`URLField(200)`). Read-only star metadata (`star_count`, `is_starred`, `starred_by_names`) is ignored by Flutter.
- Full field matrix is recorded in [PROGRESS.md](PROGRESS.md#authoritative-certification-api-contract).

## 5. Implementation Architecture

- **Model & Code Generation:** `lib/models/certification.dart` (`@JsonSerializable(fieldRename: FieldRename.snake)`, `@JsonKey(includeToJson: false)` on `int? id`), generating `lib/models/certification.g.dart` (excluded in `.gitignore` and `analysis_options.yaml`).
- **Services & State (`MultiProvider` in `lib/main.dart`):** `ApiClient` (`lib/services/api_client.dart`) exposes `getCertifications()` and `createCertification()`; `AuthState` (`lib/services/auth_state.dart`) manages in-memory tokens, stale-token `invalidate(token)`, and deduplicated `logout()`.
- **Navigation & Screens:** `lib/screens/menu.dart` (`Lihat Sertifikasi` `#00695C`), `lib/widgets/left_drawer.dart` (`View Certifications`, `Add Certification`), `lib/widgets/auth_guard.dart` (`ensureLoggedIn`), `lib/screens/certification_list_screen.dart`, `lib/screens/certification_detail_screen.dart`, and `lib/screens/certification_form.dart`.
- **Backend Auth Fix (`myportofolio` commit `410287e`):** Updated `@authentication_classes([ProjectTokenAuthentication, SessionAuthentication])` on `certification_list` (`main/api_views.py:91`) without weakening `IsPortfolioOwnerOrEditorOrReadOnly` or CSRF protections.

## 6. Public GET and Detail

`CertificationListScreen` initializes `_certifications` once in `initState()` and uses `FutureBuilder` for loading (`CircularProgressIndicator`), empty (`Belum ada sertifikasi.`), error (`ApiException` + `Coba lagi`), and populated states. Refresh is supported via swipe `RefreshIndicator` (widget test) and app bar `Muat ulang` (`QC-10`). Selecting an entry opens `CertificationDetailScreen`, rendering all 6 fields inside `SelectionArea` + `ListView` (`QC-11`).

## 7. Authenticated POST

Opening or submitting `CertificationFormPage` checks `ensureLoggedIn(context)` without changing `Project` flows. Validating inputs sends `Certification.toJson()` with `Authorization: Token <key>` via `ApiClient.createCertification()`. On `201 Created`, inputs clear, form resets, an `AlertDialog` presents the **server-returned** data (`Tutup` / `Lihat Daftar`), and `PopScope` returns `_createdAny` so navigating Back refreshes `CertificationListScreen`.

## 8. HTTP 401 and 403 Handling

- **HTTP 401:** Calls `auth.invalidate(token)` (ignoring stale tokens), clears local SnackBars, shows the `ApiException` prompt, and opens `LoginScreen` via `ensureLoggedIn(context)` with **zero automatic POST replay**; user form inputs remain intact whether re-login succeeds or is cancelled.
- **HTTP 403 / 400 / Network Errors:** Preserves active session (`AuthState.token`) and user form inputs while displaying a clear `SnackBar`. Duplicate taps are blocked via `_submitting` and drawer disablement (`QC-07`).

## 9. Actual Persistence

Database persistence was verified end-to-end against local Django SQLite twice:
1. **CP4 Headless Chrome E2E:** Two created QA certifications (`E14`–`E16`, `E22`) persisted in SQLite (`rows` verified directly), rendered at Django `/certifications/` (`E15`), and surfaced in Flutter `CertificationListScreen` without restart (`E16`).
2. **CP5 Android Emulator Smoke (`A08`–`A09`):** One created certification (`Android Smoke Certification`, `QA-CP4-cp5android-001`, row id `33`) persisted via `POST /api/v1/certifications/` (`201`) and rendered immediately in `Daftar Sertifikasi` and `CertificationDetailScreen`.
All temporary QA rows and users were removed afterward (`0` remaining QA records/users).

## 10. Automated Testing

Application code (`lib/`, `test/`) is unchanged since CP4 corrective commit `2783432`:
- **Django Backend (`410287e` unchanged):** `manage.py check`, `migrate --check`, `makemigrations --check --dry-run` PASS; `manage.py test main` **111/111 PASS** (verified CP3 & CP4, reused unchanged backend state).
- **Flutter Quality Gate (CP5 local re-run):** `dart run build_runner build` PASS, `dart format --output=none --set-exit-if-changed lib test` PASS (26 files, 0 changed), `flutter analyze --no-pub` PASS (`0 issues`), `flutter test --no-pub --reporter expanded` **67/67 PASS** (across `certification_model_test.dart`, `certification_api_test.dart`, `certification_list_test.dart`, `certification_form_test.dart`, `project_list_test.dart`, `tutorial_10_api_test.dart`, and `widget_test.dart`), `flutter build web --no-pub --dart-define=API_BASE_URL=http://127.0.0.1:8000` PASS.

## 11. Independent QC

An independent read-only `research` subagent QC audit identified **0 P0**, **1 P1** (`QC-01`: `LeftDrawer` double-tap route pop), **9 P2** (`QC-02`–`QC-08`, `QC-10`, `QC-11`), and **1 P3** (`QC-09`) findings. All 11 fixes were confirmed present in committed CP4 corrective source (`2783432`), with zero new defects in CP5. Full root-cause and retest ledger: [QC_REPORT.md](QC_REPORT.md).

## 12. Mobile Agent Testers Audit and Adaptation

`https://github.com/pierridotite/mobile-agent-testers` was audited read-only at pinned SHA `494a15ba07e3e1006602464daeca863511119bdb` (MIT license). Its native `setup.sh` / cloud GitHub Actions Claude Code runner was **not** installed or executed because it requires Anthropic credentials, separate repo scaffolding, and cannot reach `127.0.0.1` Django. Instead, its MIT tester personas (`anna`, `grace`, `malik`, `mehmet`, `arjun`) were adapted cleanly to Antigravity subagent QC, headless Chrome CDP E2E, and headless Android emulator smoke QA.

## 13. Real Browser E2E Evidence

CP4 executed `E01`–`E27` in isolated headless Google Chrome CDP (`127.0.0.1:8089` -> `127.0.0.1:8009`, SQLite). Exact evidentiary boundaries:
- **24/27 scenarios directly asserted end-to-end in the browser.**
- **E17 & E18 (Member & Editor `403`):** Real browser HTTP `403` and preserved `AuthState` session (`Logout` remained in drawer) verified in Chrome; retention of unfocused `<input>` DOM values was not directly readable by headless DOM `.value` queries and is proven in `test/certification_form_test.dart`.
- **E21 (Post-`401` cancel preserves input):** Navigation back to `CertificationFormPage`, zero `AlertDialog`, and unchanged SQLite count (`1`) observed in Chrome; 6-field preservation is proven by direct `E22` submission without re-typing returning `201` (`count=2`) plus explicit widget assertions in `certification_form_test.dart`.
- **Refresh:** Desktop browser refresh verified via explicit `Muat ulang` action (`E04`); touch `RefreshIndicator` drag verified via widget tests in `certification_list_test.dart`.
See [QC_REPORT.md](QC_REPORT.md#3-real-headless-chrome-e2e-matrix-http1270018089---http1270018009-sqlite) for per-scenario rows.

## 14. Actual Revoked-Token Test

Confirmed live in headless Chrome (`E19`–`E24`) against real SQLite token deletion (`qa_db_helper.py revoke-owner-token`): clicking `Simpan` triggered real HTTP `401`, cleared local token, redirected to `LoginScreen`, preserved inputs across cancel (`E21`), sent zero automatic replays upon drawer re-login, succeeded with HTTP `201` on explicit `Simpan` (`E22`), and verified server logout `204` rejects subsequent reuse of the old token with HTTP `401` (`E24`).

## 15. Responsive QA

- **Headless Chrome (`320×640`, `390×844`, `768×1024`, `1280×800`):** Homepage, List, Detail, Drawer, and Login flows passed with `0` console errors, `0` RenderFlex overflows, and `0` runtime exceptions.
- **Widget Tests (Kept Separate from Browser Evidence):** `test/certification_form_test.dart` verifies `Simpan` reachability across all 4 sizes including `320×640` with bottom keyboard inset (`viewInsets: 280`), plus `TextScaler.linear(2.0)` (`200%`) at `390×844` with Unicode inputs (`QC-04`, `QC-08`).

## 16. Android Runtime Status

Executed **concise native Android runtime smoke (`A01`–`A14`)** on headless AVD `Medium_Phone_API_37.0` (`emulator-5554`, `1080×2400`, Impeller OpenGLES) against local Django (`127.0.0.1:8000` SQLite):
- Note on host routing: `myportofolio/portofolio/settings.py` `ALLOWED_HOSTS` excludes `10.0.2.2` (verified returning HTTP `400 DisallowedHost`). To test unmodified backend code, `adb reverse tcp:8000 tcp:8000` paired with a debug APK (`--dart-define=API_BASE_URL=http://127.0.0.1:8000`) was used.
- **Results (`A01`–`A14`):** All 14 smoke checks passed cleanly — launch (`A01`), identity + 5 cards (`A02`), public list `GET 200` (`A03`), detail 6 fields (`A04`), protected Login guard + Back cancel (`A05`), temporary QA superuser login `200` (`A06`), ADB keyboard inputs + `DatePickerDialog` `OK` (`A07`), `POST 201` + `AlertDialog` (`A08`), created record in list (`A09`), drawer `Logout 204` resetting menu to `Login` (`A10`), `View Projects` `GET 200` (`A11`), system Back + drawer Home stack unwind (`A12`), `adb logcat` zero fatal `AndroidRuntime:E`/`flutter:E` errors (`A13`), and full DB/emulator cleanup (`A14`, `0` leftover QA certs/users).

## 17. CI/CD and APK Status

- **Workflow (`.github/workflows/main.yaml`):** Preserved working `build` (`VeryGoodOpenSource/very_good_workflows/.github/workflows/flutter_package.yml@v2`, `flutter_version: '3.47.9'`, `setup: dart run build_runner build`, `coverage_excludes: '**/*.g.dart'`, `min_coverage: 0`) and dependent `build_apk` (`needs: build`) uploading `app-release-apk`.
- **Verified CP4 CI Run (`2783432`):** Run `45867103933` `completed` / `success` (`build / build`: `success`, `build_apk`: `success`, artifact `app-release-apk` `24,273,326` bytes, `expired: false`).
- **Local Release APK (CP5):** `flutter build apk --no-pub --release` succeeded (`build/app/outputs/flutter-apk/app-release.apk`, `52,344,297` bytes / `52.3MB`).
- **Deployment & Repo Var Status:** GitHub repo variable `API_BASE_URL` is unset; PWS endpoint (`https://glenn-josia-myportofolio.pws.cs.ui.ac.id/api/v1/certifications/`) currently returns `HTTP/2 404` and was not redeployed.
- **Pending Release Check:** GitHub Actions status and `app-release-apk` artifact for the final CP5 documentation commit must be verified **after** manual commit and push.

## 18. Security Review

- Audited both working trees: zero hardcoded passwords/tokens, zero `.env` or `.sqlite3` files committed, `lib/models/*.g.dart` ignored and untracked, `build/` ignored, and temporary Chrome/ADB/credentials artifacts deleted.
- Backend preserves `IsPortfolioOwnerOrEditorOrReadOnly` (`POST` superuser-only), CSRF on session views, `ProjectTokenAuthentication` `401` separation on invalid/revoked tokens, and strict `CORS_ALLOWED_ORIGINS` (loopback regex enabled only when `DEBUG and not PRODUCTION`).
- Release `AndroidManifest.xml` preserves HTTPS-only behavior (`usesCleartextTraffic` isolated strictly to `debug/AndroidManifest.xml`).

## 19. Actual Checkpoint Commit History

Published history contains honest corrective commits where manual multiline `git add` omitted files (history never rewritten):

| Stage | Repo | Commit / Status | Summary |
|---|---|---|---|
| Tutorial 10 Prereq | Flutter | `37b9b7cb2dc1fe278f143fa32432264c279de28d` | Projects & auth integration + CI pipeline (Run `45327694076` `success`) |
| CP1 | Flutter | `542490e4da9dc9fe9459d975842ddb268460fc25` | `Certification` JSON model + tests (Run `45744074546` `success`) |
| CP2 (Feature + Test Fix) | Flutter | `a44d10c814d9365e77c771373f39f8e09b442043`, `1d2475b2bdd72f9c90582fbc51e1226e5bf8c25f` | `ApiClient`, public list/detail, Home/Drawer wiring + tests (Run `45761706529` `success`) |
| CP3 Backend | Django | `410287ed49cdc5950062e3ca55545d9f36c57ff3` | `ProjectTokenAuthentication` on `certification_list` + 4 tests (`111/111 PASS`) |
| CP3 (Feature + Test Fix) | Flutter | `d4ee23d443cfe3f0fe9998617cf32ade9a36dc31`, `d6bc863aba71812965b73dd73ca6b3d4ebdf9a45` | Protected form, 401/403, confirm/refresh + tests (Run `45783916874` `success`) |
| CP4 (QC + Complete Fix) | Flutter | `d2cc88a812b73d94f76659e62024fbf3dd5d1163`, `278343251b0b065e52954f5b61a754657bb8d9b5` | 11 QC defect fixes + 6 tests + `QC_REPORT.md` (Run `45867103933` `success`) |
| CP5 Release Docs | Flutter | `PENDING MANUAL COMMIT` | Final quality gate, Android smoke, README badge/setup/Q1–Q4/AI disclosure, reports |

*(8 Flutter commits across 5 progressive checkpoints once CP5 is committed; separate Django commit tracked independently.)*

## 20. Requirements Traceability

Full 35-item matrix (`R01`–`R35`) and rubric evaluation are maintained in [PROGRESS.md](PROGRESS.md#requirements-traceability-matrix).

## 21. Remaining Limitations

- Backend PWS deployment returns `HTTP 404` for `/api/v1/certifications/` and was not deployed; full integration relies on local Django at commit `410287e`.
- Django `ALLOWED_HOSTS` does not include `10.0.2.2`, so unmodified emulator testing uses `adb reverse tcp:8000 tcp:8000` with `127.0.0.1:8000`.
- `PATCH` / `DELETE` on `Certification` in Flutter are intentionally omitted as outside Assignment 9 minimal requirements (`GET` + `POST`).
- Native `mobile-agent-testers` cloud runner and iOS runtime were not executed; final CP5 CI run (`build`, `build_apk`, `app-release-apk`) and SCELE portal submission await manual push/submission by the student.

## 22. Submission Instructions

- **Deadline:** Monday, **30 November 2026, 23:59 WIB**.
- Stage, commit, and push CP5 manually, then verify the GitHub Actions run for the exact final `HEAD` SHA passes both `build` and `build_apk` with a downloadable `app-release-apk` artifact.
- Generate the exact commit URL after push and submit it via SCELE alongside reference to Django commit `https://github.com/glennjosia7/myportofolio/commit/410287ed49cdc5950062e3ca55545d9f36c57ff3`:

```bash
echo "https://github.com/glennjosia7/myportofolio_mobile/commit/$(git rev-parse HEAD)"
```
