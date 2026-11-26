# Checkpoint 4 — Independent Mobile QC, Security & E2E Report

## 1. Mobile Agent Testers Audit

- **Repository:** `https://github.com/pierridotite/mobile-agent-testers` (MIT license)
- **Pinned Revision Audited:** `494a15ba07e3e1006602464daeca863511119bdb` (`2026-11-26T08:34:11Z`)
- **Files Reviewed Read-Only:** `README.md`, `setup.sh`, `PRIVACY.md`, `AGENT_BRIEF.md`, `personas.json`, root directory listing.
- **Compatibility & Security Assessment:**
  - `mobile-agent-testers` is a GitHub Actions cloud template + Claude Code plugin running `@anthropic-ai/claude-code` on GitHub-hosted Android/iOS/web runners.
  - Requires `CLAUDE_CODE_OAUTH_TOKEN` or `ANTHROPIC_API_KEY`, RSA-4096 keys in `~/.mobile-agent-testers/`, and a separate GitHub repo; cloud runners cannot access `127.0.0.1` local Django.
  - Therefore `setup.sh` was NOT installed. Instead, its MIT persona framework (`anna` 320px/large font, `grace` 200% font scale/high contrast, `malik` fast tapper, `mehmet` Unicode/long text, `arjun` impatient web user) was executed via:
    1. Independent read-only `research` subagent QC audit across all Certification/auth/navigation/Project Flutter files and Django contracts.
    2. Isolated headless Google Chrome (`--headless=new`, temporary profile, Node.js v24 CDP) driving the compiled Flutter Web app against local Django.

## 2. Independent QC Findings & Remediation

Zero P0 defects found. One P1, nine P2, and one P3 defects were identified, fixed minimally, and verified by regression tests:

| ID | Severity | Location | Root Cause | Minimal Fix | Retest |
|---|---|---|---|---|---|
| QC-01 | P1 | `lib/widgets/left_drawer.dart` | `Navigator.pop()` inside drawer could pop underlying `ModalRoute` on rapid double-tap | Replaced with `Scaffold.maybeOf(context)?.closeDrawer()` + `_busy` re-entrancy lock | PASS (`certification_list_test.dart`) |
| QC-02 | P2 | `lib/widgets/project_card.dart`, `lib/screens/certification_list_screen.dart`, `lib/services/auth_state.dart` | Missing tap lock & concurrent `AuthState.logout()` race firing duplicate `POST /auth/logout/` | Added `_busy`/`_navigating` guards and deduplicated `AuthState.logout()` via `_loggingOut` | PASS (`certification_api_test.dart`) |
| QC-03 | P2 | `lib/screens/certification_form.dart`, `lib/screens/project_form.dart` | Navigation `SnackBar` overlapped `Simpan`/`Save` at bottom scroll edge | Increased bottom form scroll padding to `80px` | PASS (`certification_form_test.dart`, `widget_test.dart`) |
| QC-04 | P2 | `lib/screens/menu.dart`, `lib/widgets/project_card.dart` | `FittedBox` inside 3-column grid shrank labels at `320px` and defeated `200%` text scaling | Removed `FittedBox`, wrapped `Text(maxLines: 2)`, switched grid to 2 columns below `360px` or >`20px` scaled text | PASS (`certification_form_test.dart` 200% scale + 320px) |
| QC-05 | P2 | `lib/screens/certification_list_screen.dart` | Shared `maxLines: 3` subtitle hid issue/expiry dates when org name wrapped | Split `issuingOrganization` (`maxLines: 2`) and `validity` into separate `Text` children in `Column` | PASS (`certification_list_test.dart`) |
| QC-06 | P2 | `lib/widgets/left_drawer.dart` | `pushReplacement` from `CertificationFormPage(fromList: true)` stacked fresh list over stale list | Popped back to root route (`popUntil((r) => r.isFirst)`) before pushing top-level destination | PASS (`certification_list_test.dart`) |
| QC-07 | P2 | `lib/screens/certification_form.dart`, `lib/screens/project_form.dart` | `LeftDrawer` remained openable mid-POST; `ProjectFormPage` lacked `PopScope` | Disabled `drawer` and drag gesture while `_submitting`; wrapped `ProjectFormPage` in `PopScope(canPop: !_submitting)` | PASS (`certification_form_test.dart`) |
| QC-08 | P2 | `lib/screens/certification_form.dart`, `lib/screens/project_form.dart` | `errorMaxLines` (`1` / `2`) clipped multi-line validation errors at `320px` / `200%` scale | Increased `errorMaxLines: 4` on form inputs and date fields | PASS (`certification_form_test.dart`) |
| QC-09 | P3 | `lib/screens/login_screen.dart`, `lib/screens/project_form.dart` | Missing `hideCurrentSnackBar()` let error SnackBars linger after successful login | Added `hideCurrentSnackBar()` on error display and before `Navigator.pop(context, true)` | PASS (Chrome E2E + `widget_test.dart`) |
| QC-10 | P2 | `lib/screens/certification_list_screen.dart` | Mouse/keyboard desktop Web cannot drag `RefreshIndicator` | Added `AppBar` `IconButton(tooltip: 'Muat ulang')` calling `_refresh` alongside `RefreshIndicator` | PASS (`certification_list_test.dart` + Chrome E2E `E04`) |
| QC-11 | P2 | `lib/screens/certification_detail_screen.dart` | `SelectableText` emitted unfocused empty `<textarea disabled>` nodes in Flutter Web semantics | Wrapped `ListView` in `SelectionArea` using `Text(...)` for all 6 fields | PASS (Chrome E2E `E03` + `certification_list_test.dart`) |

## 3. Real Headless Chrome E2E Matrix (`http://127.0.0.1:8089` -> `http://127.0.0.1:8009`, SQLite)

| ID | Scenario | Status | Actual Evidence |
|---|---|---|---|
| E01 | Anonymous homepage | PASS | Rendered identity (`2506614712`, `Glenn Josia Devano`, `PBP F`) and action cards |
| E02 | Public Certification List GET | PASS | `GET /api/v1/certifications/` returned `200`, empty state rendered |
| E03 | Certification Detail (all 6 fields) | PASS | All 6 fields exposed in rendered Web semantics (`SelectionArea` + `Text`) |
| E04 | Refresh updates list | PASS | `Muat ulang` button triggered fresh `GET 200`; `dragTouch` not triggered on desktop mouse profile (`touchTriggered: false`), touch drag covered in `certification_list_test.dart` |
| E05 | Backend unavailable error state | PASS | Stopped Django subprocess -> `Muat ulang` rendered `Coba lagi` error state |
| E06 | Retry after backend recovery | PASS | Restarted Django subprocess -> clicking `Coba lagi` recovered (`200`) |
| E07 | Protected `Tambah Sertifikasi` guard | PASS | Anonymous tap opened `LoginScreen` |
| E08 | Cancel login blocks form | PASS | Back on `LoginScreen` returned to `MyHomePage` without form access |
| E09 | Invalid credentials rejected | PASS | `POST /api/v1/auth/token/` returned `400`, remained on `LoginScreen` |
| E10 | Temporary QA superuser login | PASS | Valid QA superuser login succeeded and opened `CertificationFormPage` |
| E11 | Invalid Certification form zero POST | PASS | Empty submit showed validation errors with zero network POSTs |
| E12 | Valid form POST returns 201 | PASS | `POST /api/v1/certifications/` returned HTTP `201` |
| E13 | Confirmation shows server data | PASS | `AlertDialog` displayed server-returned certification name & fields |
| E14 | Record persisted in Django DB | PASS | Confirmed row count = `1` with matching `credential_id` in SQLite |
| E15 | Django website renders created entry | PASS | Navigated Chrome to `http://127.0.0.1:8009/certifications/` -> both QA records rendered |
| E16 | Flutter list shows created entry | PASS | Clicking `Lihat Daftar` displayed newly created entry without app restart |
| E17 | Regular user POST denied (403) | PASS | Real HTTP `403`, valid session preserved (`Logout` remained in drawer); unfocused `<input>` DOM check required focus, preservation proved in `certification_form_test.dart` |
| E18 | Editor POST denied (403) | PASS | Real HTTP `403`, valid session preserved (`Logout` remained in drawer); preservation proved in `certification_form_test.dart` |
| E19 | Revoked QA token POST returns 401 | PASS | Deleted only `qa_t9_cp4_owner` token -> UI `Simpan` received real HTTP `401` |
| E20 | Flutter clears session & asks login | PASS | Redirected to `LoginScreen`, no success dialog |
| E21 | Cancel re-login preserves values | PASS | Cancelled to `CertificationFormPage`, DB stayed at `1` record; `E22` directly submitted preserved values without re-typing + `certification_form_test.dart` verified all 6 fields |
| E22 | Re-login + explicit retry (no dup) | PASS | Drawer re-login sent zero auto-POSTs (`count=1`); explicit `Simpan` returned `201` (`count=2`) and appeared in list |
| E23 | Logout clears local session | PASS | UI `Logout` sent `POST /api/v1/auth/logout/` (`204`) |
| E24 | Revoked logout token rejected | PASS | Reusing captured logout token on `POST /api/v1/certifications/` returned `401`, DB token gone |
| E25 | Existing Projects list | PASS | `Lihat Proyek` -> `GET /api/v1/projects/` `200`, `Daftar Proyek` rendered |
| E26 | Existing Projects login guard | PASS | `Tambah Proyek` while logged out opened `LoginScreen` |
| E27 | Existing identity & navigation intact | PASS | Identity & 5 action cards intact; `LeftDrawer` double-tap & unwind safe |

## 4. Security, CORS & Responsive Summary

- **CORS (`OPTIONS http://127.0.0.1:8009/api/v1/certifications/`):**
  - Trusted origin `http://127.0.0.1:8089`: `200`, `Access-Control-Allow-Origin: http://127.0.0.1:8089`, `Access-Control-Allow-Headers: accept, authorization, content-type, user-agent, x-csrftoken, x-requested-with`, `Access-Control-Allow-Methods: DELETE, GET, OPTIONS, PATCH, POST, PUT`.
  - Untrusted origin `https://untrusted.example`: `200`, no `Access-Control-Allow-Origin` header (`null`).
- **Responsive Browser Sweep (`320×640`, `390×844`, `768×1024`, `1280×800`):** Traversed Homepage, List, Detail, Drawer, and Login trigger in headless Chrome with **0 console errors**, **0 RenderFlex overflow messages**, and **0 runtime exceptions**. Form + keyboard inset at `320×640` and `200%` text scaling at `390×844` verified in `test/certification_form_test.dart`.
- **Android Runtime:** `NOT TESTED` (AVD `Medium_Phone_API_37.0` present but not booted; no Android runtime claims made from Web evidence).
- **Clean-Checkout Validation (`/tmp/pbp-t9-cp4-clean`):** Verified `project.g.dart` & `certification.g.dart` absent before generation, then `flutter pub get --offline`, `dart run build_runner build` (`wrote 4 outputs`), `flutter analyze --no-pub` (`0 issues`), `flutter test --no-pub` (`67/67 PASS`), `flutter build web` (`PASS`), then removed `/tmp/pbp-t9-cp4-clean`.
- **QA Fixture Cleanup:** Deleted `2` QA certifications and `3` QA accounts (`remaining_qa_certs: 0`, `remaining_qa_users: 0`, `total_certs_after: 0`). Chrome temp profile and credentials file removed.
