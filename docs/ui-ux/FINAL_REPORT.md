# Final UI/UX Redesign Report — MyPortfolio Website Alignment

**Project:** `myportofolio_mobile` (Post-Assignment 9 Visual Redesign & Design System Synchronization)
**Authoritative Website Reference:** [`myportofolio`](https://github.com/glennjosia7/myportofolio) (`410287ed49cdc5950062e3ca55545d9f36c57ff3`)
**Protected Flutter Assignment 9 Baseline:** [`myportofolio_mobile`](https://github.com/glennjosia7/myportofolio_mobile) (`0470022d71919f9dc7c64836ae3deae2d7695701`, CI Run [`45969282722`](https://github.com/glennjosia7/myportofolio_mobile/actions/runs/45969282722) `success`)
**Design Spec:** [DESIGN_AUDIT.md](file:///Users/devanmacbook/Documents/01_Kuliah/MAIN_KULIAH/Semester-3/PBP/Tugas-Individu/Tugas-Individu/myportofolio_mobile/docs/ui-ux/DESIGN_AUDIT.md)

---

## 1. Executive Summary

The Flutter mobile application was aligned across typography, color tokens, surface geometry, navigation hierarchy, form feedback, and empty/error states with the dark-native Navy & Mint-Teal editorial visual identity of the Django MyPortfolio website while preserving all Assignment 9 functionality, authentication guarantees, API contracts, and regression suites.

- **Zero new pub dependencies:** Only local static OFL `Space Grotesk` TTF weights (`Regular`, `Medium`, `Bold` + `OFL.txt`) and website `profile.png` (`83K`) were bundled in `pubspec.yaml`; `pubspec.lock` is unchanged.
- **Zero Django/API modifications:** `myportofolio` remains untouched at `410287e` with `111/111` passing Django tests.
- **Zero blockers remaining:** Independent read-only QC review surfaced 4 `MAJOR` and 4 `MINOR` items; all 8 were resolved and re-verified across widget tests, headless Chrome E2E, and Android Emulator (`Medium_Phone_API_37.0`).

---

## 2. Design System & Component Alignment

| Layer | Implementation | Website Parity Highlights |
|---|---|---|
| Tokens & Theme | `lib/theme/app_tokens.dart`, `lib/theme/app_theme.dart`, `lib/main.dart` | `#071525` background, `#0D2236` cards/inputs, `#123750` elevated fills, `#36C2AE` primary CTA/kicker/focus accent, `#F6F8FB` primary text, `#A9BBCA` muted copy, `#FF9B8F` error copy, `#B42318` danger border, `#22C55E` success icon, `10px` radius, `0` shadow, `VisualDensity.standard` (`48dp` targets), WCAG >= 3:1 idle input borders (`#4B7794`), state-aware `WidgetStateTextStyle` floating labels |
| Bundled Assets | `pubspec.yaml`, `assets/fonts/`, `assets/img/profile.png` | Offline static `Space Grotesk` (`400`/`500`/`700`, `OFL.txt`) and official website `profile.png` with `GJ` initials fallback |
| Home & Nav | `lib/screens/menu.dart`, `lib/widgets/left_drawer.dart`, `lib/widgets/project_card.dart` | `MyHomePage` remains `StatelessWidget`; `MyPortfolio.` AppBar with `1px #27455B` bottom divider; Navy Hero Identity Card (`INFORMATION SYSTEMS · UI`, non-wrapping `NPM 2506614712` & `Class PBP F` pills); 1/2/3-column responsive `ItemCard` grid collapsing cleanly to 1 col at `320px` + `200%` scale; dark grouped `LeftDrawer` (`48dp` minimum tile height, active route highlight, `Guest Mode`/`Authenticated` badge) |
| Auth & Portfolio Flows | `lib/widgets/state_views.dart`, `lib/screens/{login_screen,project_list_screen,project_detail_screen,project_form,certification_list_screen,certification_detail_screen,certification_form}.dart` | Centered max-width containers (`440`/`560`/`720`/`840`), editorial kickers & `.` accent headings, password visibility toggle on `LoginScreen`, `Muat ulang` AppBar parity on `ProjectListScreen`, shared `EmptyStateView` / `ErrorStateView`, `SelectionArea` on both detail screens without AppBar title ellipsis, top-aligned multiline `Deskripsi Proyek` label, dark-themed `DatePickerDialog`, 201 confirmation `AlertDialog`, and `80px` SnackBar clearance preserved |

---

## 3. Independent QC Audit Findings & Resolutions

Subagent audit (`3b4b5347-b7d1-4914-accb-b20fa0f7dd7a`) identified **0 BLOCKER**, **4 MAJOR**, and **4 MINOR** items before CP4 hardening:

| Severity | Finding | Resolution | Verified In |
|---|---|---|---|
| `MAJOR` | Drawer `ListTile` (`minTileHeight: 44`) below `48dp` target height | Raised `minTileHeight: 48` in `lib/widgets/left_drawer.dart` | `widget_test.dart` + Chrome E2E (`drawerHomeTileHeight: 52`, `drawerLoginTileHeight: 50`) |
| `MAJOR` | Static `floatingLabelStyle` forced bright teal `#36C2AE` on error & unfocused states | Switched to `WidgetStateTextStyle.resolveWith` (`error -> #FF9B8F`, `focused -> #36C2AE`, default -> `#A9BBCA`) | `widget_test.dart` + `flutter-cp4/certification-form-error-390.png` |
| `MAJOR` | Home `ItemCard` labels truncated at `320px` + `200%` text scaling in 2 columns | Collapsed grid to `1` column when `constraints.maxWidth < 360 && textScale > 1.4` (`lib/screens/menu.dart`) | `widget_test.dart` (`crossAxisCount == 1`, `takeException() == null`) |
| `MAJOR` | Web/desktop default compact `VisualDensity` shrank CTA buttons to `40px` (`TextButton` declared `44dp`) | Set `VisualDensity.standard` in `buildAppTheme()` and `Size(48, 48)` on `textButtonTheme` | `widget_test.dart` + Chrome E2E (`48px` on `Masuk`, `Save`, `Simpan`) |
| `MINOR` | Drawer `My Portfolio.` dot floated center-aligned when wrapping at 200% scale | Added `crossAxisAlignment: CrossAxisAlignment.end` on header `Row` | `lib/widgets/left_drawer.dart` + `flutter-cp4/drawer-390.png` |
| `MINOR` | Multiline `Deskripsi Proyek` label vertically centered | Set `alignLabelWithHint: maxLines > 1` in `project_form.dart` | `flutter-cp4/project-form-390.png` |
| `MINOR` | Latent `< 3:1` border color (`AppColors.line`) in `outlinedButtonTheme` | Updated `outlinedButtonTheme` border side to `AppColors.inputBorder` (`3.36–3.82:1`) | `lib/theme/app_theme.dart` |
| `MINOR` | Date fields remained visually enabled during form submission | Passed `enabled: !_submitting` to date `InputDecorator` in `certification_form.dart` | `lib/screens/certification_form.dart` + `certification_form_test.dart` |

---

## 4. Verification Matrix (Post-Final-Edit)

| Check | Command / Environment | Result | Evidence |
|---|---|---|---|
| Formatter | `dart format --output=none --set-exit-if-changed lib test` | **PASS** | `Formatted 29 files (0 changed) in 0.12 seconds.` |
| Codegen Check | `dart run build_runner build` | **PASS** | `Built with build_runner/aot in 5s; wrote 0 outputs.` (`git ls-files '*.g.dart'` empty) |
| Static Analysis | `flutter analyze --no-pub` | **PASS** | `No issues found! (ran in 2.8s)` |
| Flutter Unit & Widget Suite | `flutter test --no-pub --reporter expanded` | **PASS** | `00:11 +71: All tests passed!` (`71/71`, including A9 baseline + CP2–CP4 UI/accessibility regressions) |
| Django Test Suite | `cd ../myportofolio && PRODUCTION=False DEBUG=True .venv/bin/python manage.py test` | **PASS** | `Ran 111 tests in 27.014s` -> `OK` (`111/111`, backend untouched) |
| Flutter Web Build | `flutter build web --no-pub --dart-define=API_BASE_URL=http://127.0.0.1:8012` | **PASS** | `✓ Built build/web` (`29.1s`) |
| Release Android APK | `flutter build apk --release --no-pub` | **PASS** | `✓ Built build/app/outputs/flutter-apk/app-release.apk (52.7MB)` (`52,717,390` bytes, `29.2s`) |
| Chrome Headless E2E | `node .../scratch/ui_cp4_capture.mjs` (local Django `8012` + Web `8092`) | **PASS** | `ok: true`, `consoleErrorsCount: 0`, `runtimeExceptions: []`, POST 201 + Detail + Logout + live ErrorStateView |
| Android Emulator Smoke | `python3 .../scratch/android_smoke_cp4.py` (`Medium_Phone_API_37.0`, `adb reverse tcp:8013`) | **PASS** | `ok: true`, all 9 runtime checks (`home`, `drawer`, `cert_list_get`, `login_to_form`, `cert_post_201`, `cert_detail`, `project_list_get`, `logout_and_home`, `logcat: 0 fatal errors`) |
| QA DB & Workspace Hygiene | `ui_audit_fixture.py counts` + `git diff --check` | **PASS** | `{"experiences":3,"achievements":5,"projects":0,"certifications":0,"qa_users":0}`, `git diff --check` empty |

---

## 5. Screenshot Archive (Outside Git)

- **Website Reference:** `/tmp/myportofolio-ui-ux-qa/website/` (24 PNGs + `website-computed-styles.json`)
- **Flutter Before Redesign:** `/tmp/myportofolio-ui-ux-qa/flutter-before/` (18 PNGs)
- **CP2 Design System & Nav:** `/tmp/myportofolio-ui-ux-qa/flutter-cp2/` (8 PNGs)
- **CP3 Lists, Details, Forms, Login:** `/tmp/myportofolio-ui-ux-qa/flutter-cp3/` (14 PNGs)
- **CP4 Post-QC Polish & Live States:** `/tmp/myportofolio-ui-ux-qa/flutter-cp4/` (10 PNGs: `home-{390,1280}`, `drawer-390`, `login-390`, `project-form-390`, `certification-form-390`, `certification-form-error-390`, `datepicker-390`, `certification-success-dialog-390`, `projects-error-390`)
- **CP4 Android Emulator Runtime:** `/tmp/myportofolio-ui-ux-qa/android-cp4/` (8 PNGs: `android-home`, `android-drawer`, `android-cert-list`, `android-login`, `android-cert-form`, `android-datepicker`, `android-cert-success`, `android-cert-detail`)

---

## 6. Residual Notes & Scope Boundaries

- **Physical Android Hardware:** Not tested on a physical handset; runtime verification covered `Medium_Phone_API_37.0` (`emulator-5554`).
- **Remote PWS Deployment:** Not re-tested against live PWS in offline UI/UX checkpoints; E2E validated local Django DRF endpoints identically matching production contracts.
- **Git Mutations:** Repository remains on `main` (`0470022`) with CP1–CP4 changes unstaged for manual branch creation, staging (`git add -- <file>`), commit, and push by the user.
