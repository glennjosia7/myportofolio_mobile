# Design Audit — My Portfolio Website-Aligned Mobile UI/UX

**Baseline Reference:**
- **Django Website (Authoritative Design Source):** [`myportofolio`](https://github.com/glennjosia7/myportofolio) at commit `410287ed49cdc5950062e3ca55545d9f36c57ff3`
- **Flutter Application (Protected Assignment 9 Baseline):** [`myportofolio_mobile`](https://github.com/glennjosia7/myportofolio_mobile) at commit `0470022d71919f9dc7c64836ae3deae2d7695701` (CI Run [`45969282722`](https://github.com/glennjosia7/myportofolio_mobile/actions/runs/45969282722) `success`, artifact `app-release-apk` `24,273,327` bytes)

---

## 1. Website Visual Identity Summary

Inspecting `templates/`, `static/css/style.css` (1,296 lines), `static/js/toast.js`, and 24 rendered screenshots across `320×640`–`1440×900` establishes a cohesive **dark-native Navy & Mint-Teal editorial brand**:
- **Dark-only palette:** Website defines a single dark color scheme (`<meta name="theme-color" content="#071525">`, `color-scheme: dark` on form popovers); **no light mode exists**.
- **Surface language:** Deep midnight navy background (`#071525`), elevated navy slate cards (`#0d2236`), subtle `1px solid #27455b` borders, `10px` radius (`--radius: 10px`), and **zero drop shadows** on stationary cards, inputs, and buttons.
- **Signature editorial cues:** Punctuation dot accent (`.brand span` & headings ending in `.` colored `#36c2ae`), uppercase teal `section-kicker` (`0.75rem`, weight `500`, wide tracking `0.08–0.12em`), crisp white headings (`#f6f8fb`, tight negative tracking `-0.025em` to `-0.045em`), cool slate secondary body copy (`#a9bbca`), and solid `#36c2ae` primary CTAs with dark `#071525` bold labels.

---

## 2. Actual Extracted Color Palette & Token Mapping

Rendered styles verified via Chrome DevTools (`getComputedStyle`) in `/tmp/myportofolio-ui-ux-qa/website-computed-styles.json`:

| Semantic Role | Website HEX / RGB | Website Source & Usage | Computed DOM Value | Current Flutter Value | Proposed Flutter Token & HEX | WCAG Contrast | Notes |
|---|---|---|---|---|---|---|---|
| `paper` / `scaffoldBg` | `#071525` | `style.css:4` (`--paper`), `body`, `.hero`, modals, button text | `rgb(7, 21, 37)` | `#FEF7FF` (M3 light) | `AppColors.paper = Color(0xFF071525)` | Base bg | Authoritative match |
| `surface` / `cardSurface` | `#0d2236` | `style.css:5` (`--surface`), `.experience-card`, `.certification-card`, inputs | `rgb(13, 34, 54)` | `#F7F2FA` / white M3 card | `AppColors.surface = Color(0xFF0D2236)` | `1.16:1` step + `#27455b` border | Card distinction relies on 1px `#27455b` border (matches web) |
| `surfaceElevated` / `chipBg` | `#123750` | `style.css:203, 234` (`.social-links a`, `.hero-photo::after`) | `rgb(18, 55, 80)` | None | `AppColors.surfaceElevated = Color(0xFF123750)` | `11.69:1` w/ `#f6f8fb` | Action pills, nav hover/selected tile fill |
| `headerOverlay` | `rgba(7, 21, 37, 0.84)` | `style.css:94` (`.site-header`) | `rgba(7, 21, 37, 0.84)` | Mixed (`#3F51B5` Indigo / white M3) | `AppColors.paper` (`0xFF071525` solid opaque for AppBar) | `17.27:1` w/ `#f6f8fb` | Solid navy prevents Android status/scroll bleed without BackdropFilter cost |
| `accent` / `primary` | `#36c2ae` | `style.css:6` (`--accent`), CTAs, `.section-kicker`, active underline, borders | `rgb(54, 194, 174)` | `#3F51B5` Indigo seed + 5 card colors | `AppColors.accent = Color(0xFF36C2AE)` | `8.30:1` vs `#071525`; `7.30:1` vs `#0d2236` | High AA/AAA pass on both `#071525` and `#0d2236` |
| `accentHover` / `pressed` | `#2aa896` | `style.css:703, 989` (`.button:hover`) | Declared `#2aa896` | Default Indigo splash | `AppColors.accentPressed = Color(0xFF2AA896)` | `6.25:1` vs `#071525` | Button pressed/hovered state |
| `ink` / `textPrimary` | `#f6f8fb` | `style.css:3` (`--ink`), headings, `.button-secondary`, `h1`/`h2`/`dd` | `rgb(246, 248, 251)` | `#1D1B20` dark ink | `AppColors.ink = Color(0xFFF6F8FB)` | `17.27:1` (`paper`), `15.19:1` (`surface`) | Secondary button bg when paired with `#071525` fg |
| `secondaryHover` | `#c7d3e0` | `style.css:727` (`.button-secondary:hover`) | Declared `#c7d3e0` | None | Optional `#c7d3e0` hover | `11.96:1` vs `#071525` | Matches secondary button hover |
| `muted` / `textSecondary` | `#a9bbca` | `style.css:7` (`--muted`), `.bio`, `.meta-list dt`, card metadata, `.empty-state`, footer | `rgb(169, 187, 202)` | `#49454F` M3 grey | `AppColors.muted = Color(0xFFA9BBCA)` | `9.32:1` (`paper`), `8.20:1` (`surface`) | Exceeds 4.5:1 AA |
| `line` / `borderSubtle` | `#27455b` | `style.css:8` (`--line`), card/header/footer/empty-state `1px` borders & dividers | `rgb(39, 69, 91)` | Default M3 outline | `AppColors.line = Color(0xFF27455B)` | `1.83:1` (`paper`), `1.61:1` (`surface`) | Decorative dividers/cards only |
| `inputBorderIdle` *(Adapted)* | Website uses `#36c2ae` (forms) & `#27455b` (search) | `style.css:753` (form inputs `#36c2ae`), `style.css:834` (search `#27455b`) | `rgb(54, 194, 174)` | `#79747E` M3 grey | `AppColors.inputBorder = Color(0xFF4B7794)` (idle) / `#36c2ae` (focus) | `3.36:1` (`#4b7794` on `#0d2236`), `7.30:1` (`#36c2ae`) | **WCAG Adaptation:** `#27455b` on `#0d2236` is `1.61:1` (<3:1 WCAG 1.4.11 UI border); `#4b7794` keeps slate hue at `3.36:1` while `#36c2ae` marks active focus |
| `errorSurface` / `danger` | `#b42318` | `style.css:956, 1171` (`.button-danger`, `.toast-error`) | `rgb(180, 35, 24)` | `#B3261E` M3 error | `AppColors.danger = Color(0xFFB42318)` | `6.57:1` w/ `#FFFFFF` | Destructive/error border accent & filled danger states |
| `errorText` / `formError` | `#ff9b8f` | `style.css:770` (`.form-error`) | `rgb(255, 155, 143)` | `#B3261E` | `AppColors.errorText = Color(0xFFFF9B8F)` | `9.04:1` (`paper`), `7.96:1` (`surface`) | Authoritative inline form error & `errorText` on dark surfaces |
| `success` | `#22c55e` | `style.css:1170` (`.toast-success` left bar) | Declared `#22c55e` | `#2E7D32` / default dialog | `AppColors.success = Color(0xFF22C55E)` | `8.06:1` (`paper`) | Success icon & left accent |
| `warning` *(Adapted)* | *(No warning token on web)* | `SnackBar` network/403 notices | None | Default SnackBar | `AppColors.warning = Color(0xFFF59E0B)` | `7.53:1` (`surface`) | **Derived adaptation** for offline/permission notice icons paired with text |
| `disabledFg` / `disabledBg` *(Adapted)* | Cursor `not-allowed` (`style.css:709`) | Disabled submit buttons mid-POST | None | M3 disabled grey | `surfaceElevated` + `muted` @ `0.55` alpha (`~4.1:1`) | >4:1 w/ spinner + label `'Menyimpan…'` | **Derived adaptation** |
| Legacy Home Card Palette | None on web | Absent on website | Absent on web | `#1565C0`, `#2E7D32`, `#BF360C`, `#6A1B9A`, `#00695C` | Unified `#0d2236` (`surface`) + `#36c2ae`/`#27455b` (`menu.dart` semantic roles) | `15.19:1` (`#f6f8fb` on `#0d2236`) | **Requires Decision #2:** Replace rainbow cards w/ website surface+accent cards (`widget_test.dart:203-228` update) |

---

## 3. Typography Inventory

Website declares `font-family: "Space Grotesk", system-ui, sans-serif` (`templates/base.html:12` loads weights `400`, `500`, `700` via Google Fonts; confirmed all 3 weights `status: "loaded"` in Chrome).

| Text Role | Website Declaration & Computed | Proposed Flutter `TextTheme` | Mobile Scaling Rationale |
|---|---|---|---|
| `headlineLarge` | `h1`: `clamp(2.5rem, 6vw, 4.5rem)` (`72px` @ 1280px), `700`, `ls: -0.045em`, `lh: 1.15` | `28 sp`, `w700`, `letterSpacing: -0.6`, `height: 1.18`, `#f6f8fb` | Scaled cleanly for 320–430px viewports (`4.5rem` would clip 320px phone screens) |
| `headlineMedium` | `h2`: `clamp(1.2rem, 2.5vw, 1.6rem)`–`3rem`, `700`, `ls: -0.025em`, `lh: 1.15` | `22 sp`, `w700`, `letterSpacing: -0.4`, `height: 1.22`, `#f6f8fb` | Section & form headings |
| `titleLarge` | AppBar / `.brand` (`16.8px`/`19.2px` `700`) & `.project-form-modal h2` (`24px` `700`) | `20 sp`, `w700`, `letterSpacing: -0.25`, `height: 1.25`, `#f6f8fb` | Consistent across all `AppBar`s and Detail headings |
| `titleMedium` | `.experience-card h2/h3` / `.certification-card h2` (`18.4px` `700`, `lh: 1.3`) | `17 sp`, `w700`, `height: 1.3`, `#f6f8fb` | Card titles |
| `bodyLarge` | `body` / `.bio` (`16px`, `400`, `lh: 1.7` -> `27.2px`) | `16 sp`, `w400`, `height: 1.55`, `#f6f8fb` | Primary readable text |
| `bodyMedium` | `.experience-description`, `dd`, `.toast-message` (`14.4px`–`16px`, `400`, `#a9bbca`) | `14 sp`, `w400`, `height: 1.5`, `#a9bbca` | Metadata, descriptions, card body |
| `labelLarge` | `.button` (`14.4px`–`16px`, `700`/`600`), `.form-group label` (`16px` `700`) | `15 sp`, `w700`, `letterSpacing: 0.1` | Buttons & form section labels |
| `labelSmall` | `.section-kicker`, `.certification-organization`, `.certification-details dt` (`12px`, `500`/`700`, uppercase, `ls: 0.08–0.12em`, `#36c2ae`) | `11 sp`, `w700`, `letterSpacing: 1.1`, `#36c2ae` | Editorial uppercase category/organization kickers |

**Font Asset Licensing Note:** `Space Grotesk` by Florian Karsten is licensed under **SIL Open Font License 1.1 (OFL)**. Bundling static `.ttf` weights (`Regular`, `Medium`, `Bold`) directly in `assets/fonts/` with `LICENSE` avoids adding `google_fonts` and works offline inside APK/widget tests. **Decision #3** asks user whether to bundle static OFL `Space Grotesk` `.ttf` files or use system sans-serif fallback (`Roboto`/Apple SF).

---

## 4. Spacing, Shape, Elevation, Iconography & Component Inventory

- **Spacing Scale (`AppSpacing`):** Derived from `style.css` (`0.25rem`/`0.5rem`/`0.75rem`/`1rem`/`1.25rem`/`1.5rem`/`2rem`): `xs=4`, `sm=8`, `md=12`, `base=16`, `lg=20`, `xl=24`, `xxl=32` (plus `formBottomInset=80` preserving CP4 `QC-03` SnackBar clearance, and `maxContentWidth=560` forms / `840` desktop list/home).
- **Shape & Elevation:** `radiusCard = 10`, `radiusButton = 10`, `radiusInput = 10`, `radiusChip = 8`, `borderWidth = 1.0`, `elevation = 0` on cards/dialogs/inputs (flat bordered surfaces instead of M3 drop shadows, matching `style.css`).
- **Iconography:** Website uses minimal HTML symbols (`+`, `★`, `×`, `↗`, `→`) and image logos. Flutter standardizes on outlined Material Icons (`Icons.*_outlined` / consistent line weight) across drawer, action cards, detail metadata, empty states, and error states. Zero emojis.

| Component | Website Reference | Flutter Equivalent | Current Mismatch (`D01`–`D08`) | Proposed Enhancement |
|---|---|---|---|---|
| Navigation | `.site-header` (`#071525`, `border-bottom: #27455b`, `.brand` + `.` accent, teal underline on active route, username pill) | `AppBar` + `LeftDrawer` | Indigo/white M3 AppBar split across screens (`D05`); bright blue `DrawerHeader`, missing route highlight & auth header pill | Flat `#071525` AppBar w/ `#27455b` bottom `1px` line; dark `#0d2236` `DrawerHeader` (`Glenn Josia Devano.`), active route highlight `#123750` + `#36c2ae` indicator, auth status badge |
| Brand identity | `.hero` (`#071525`, `section-kicker`, `h1` white, `avatar` `#36c2ae` border + `#123750` offset frame, `meta-list` `NPM`/`Program`) | `MyHomePage` + 3 `InfoCard`s | White grid, NPM `250661471\n2` wraps awkwardly (`D08`), absent editorial kicker & navy/teal hero (`D04`, `D01`) | Compact Navy Hero Identity card (`#0d2236`, `#27455b` border) w/ `section-kicker`, `Glenn Josia Devano.`, non-wrapping `NPM 2506614712` + `Class PBP F` metadata chips, optional website avatar (`profile.png`) |
| Button | `.button` (`#36c2ae` fill, `#071525` bold text, `10px` radius, `0` shadow); `.button-secondary` (`#f6f8fb` fill, `#071525` text) | `FilledButton`, `ElevatedButton`, `OutlinedButton`, `TextButton` | M3 pill radius (`20dp+`) on `Simpan`, plain light Indigo `Masuk` button on Login (`D03`) | Shared `AppTheme` button themes with `10px` radius, `48dp` min touch height, `#36c2ae` primary (`#071525` text), `#123750`/`#27455b` outlined secondary |
| Card | `.experience-card` / `.certification-card` (`#0d2236`, `1px #27455b`, `10px` radius, `24px` pad, teal uppercase kicker, white title, muted body) | `ItemCard`, `ProjectListScreen` / `CertificationListScreen` cards | 5 saturated rainbow squares (`#1565C0`–`#00695C`) ballooning to ~400px on desktop (`D01`/`D08`); plain grey M3 `ListTile` cards (`D03`) | Dark `#0d2236` cards with `1px #27455b` border & `10px` radius; Home uses responsive constrained cards (`maxContentWidth=840`); List cards adopt web hierarchy (kicker -> bold title -> metadata) |
| Input | `.form-group input` (`#0d2236` bg, `1px #36c2ae` border, `10px` radius, bold `#f6f8fb` label above, `#a9bbca` placeholder, `#ff9b8f` `.form-error`) | `TextFormField`, `_dateField` `InputDecorator` | Plain white rectangular outline fields, `#B3261E` errors (`D01`/`D03`) | Centralized `InputDecorationTheme`: `#0d2236` fill, `10px` radius, `#4b7794` (`3.36:1`) idle border, `#36c2ae` `1.5px` focus border, `#ff9b8f` error text + border (`errorMaxLines: 4`) |
| Badge / Kicker | `.section-kicker`, `.experience-category`, `.certification-organization` (`12px` uppercase `#36c2ae`) | Raw subtitle lines in `ListTile` / detail | No visual separation between `tech_stack`/`issuingOrganization` and title/dates (`D04`) | Styled teal uppercase label (`labelSmall` `#36c2ae`) + semantic outlined `Lifetime`/`Active` chip only when directly backed by `expirationDate == null` vs `expirationDate` |
| Alert / Dialog / Feedback | `.toast-component` (`#071525`, `1px #27455b`, `4px` left status bar `#22c55e`/`#b42318`/`#36c2ae`) & `.project-form-modal` (`#071525`, `1px #27455b`) | `SnackBar` & `AlertDialog` | Default dark-grey M3 `SnackBar` & light lavender `AlertDialog` (`D06`) | Dark `#0d2236` `SnackBar` with `#27455b` border + semantic status icon; `#071525` `AlertDialog` with `#27455b` `1px` border and `#22c55e` success check |
| Empty state | `.empty-state` (`border-top: 1px #27455b`, muted `#a9bbca` message) | Centered plain `Text('Belum ada ...')` | Bare single line of black text in empty space (`D06`) | Reusable `EmptyStateView` inside scrollable `RefreshIndicator` with subtle `#123750` icon badge, `#f6f8fb` title, `#a9bbca` guidance |
| Loading / Error | `#loading` (`Memuat...`) & `#error` (`Gagal memuat...`) text blocks | `CircularProgressIndicator` & centered `Text + TextButton('Coba lagi')` | Bare Indigo spinner & unframed error text (`D06`) | `#36c2ae` progress indicator (`48dp`) + `ErrorStateView` card (`#0d2236`, `#b42318`/`#ff9b8f` icon, legible `ApiException` message, `#36c2ae` Retry CTA) |

---

## 5. Captured Visual Audit Screenshots

All baseline screenshots stored outside tracked Git paths in `/tmp/myportofolio-ui-ux-qa/`:
- **Rendered Website (24 PNGs + computed CSS):** `/tmp/myportofolio-ui-ux-qa/website/{home-{320,390,768,1280,1440},projects-{390,1280},projects-empty-{390,1280},projects-auth-{390,1280},certifications-{390,1280},certifications-empty-{390,1280},certifications-auth-{390,1280},login-{390,1280},login-error-390,project-add-{390,1280},certification-add-{390,1280}}.png` and `/tmp/myportofolio-ui-ux-qa/website-computed-styles.json`
- **Flutter Before Redesign (18 PNGs):** `/tmp/myportofolio-ui-ux-qa/flutter-before/{home-{320,390,768,1280},drawer-390,projects-list-{390,1280},projects-empty-390,project-detail-{390,1280},certifications-list-{390,1280},certifications-empty-390,certification-detail-{390,1280},login-390,project-form-390,certification-form-390}.png`

---

## 6. Identified Flutter Inconsistencies (`D01`–`D08`)

- **D01 (Color inconsistency):** Flutter uses M3 light `#FEF7FF` / `#3F51B5` indigo and 5 unrelated rainbow card colors (`#1565C0`, `#2E7D32`, `#BF360C`, `#6A1B9A`, `#00695C`), completely disconnected from website `#071525`/`#0d2236`/`#36c2ae`.
- **D02 (Typography inconsistency):** Default system font sizes and weights lack website editorial hierarchy (`section-kicker` uppercase tracking, negative-tracked bold `.` titles, `#a9bbca` secondary hierarchy).
- **D03 (Component inconsistency):** Default pill `FilledButton`, unbordered shadow M3 cards, plain `ListTile` rows, and bare form inputs diverge from website flat `10px`-radius bordered cards (`#0d2236`, `#27455b`), solid teal `#36c2ae` buttons, and `#ff9b8f` errors.
- **D04 (Layout hierarchy issue):** `CertificationDetailScreen` and `ProjectDetailScreen` print raw `Label: Value` lines with no visual grouping; `LoginScreen` drops two raw fields onto empty white space; `CertificationFormPage` has no section headings grouping fields.
- **D05 (Navigation styling issue):** AppBar background alternates inconsistently (`#3F51B5` on `MyHomePage`/`ProjectFormPage`/`CertificationFormPage` vs light `#FEF7FF` on `ProjectListScreen`/`CertificationListScreen`/`LoginScreen`/`Detail`), `LeftDrawer` uses bright blue `Colors.indigo`, lacks active route indication and auth badge, and Detail AppBar truncates long titles (`Certified Defensive Applicati...`).
- **D06 (Feedback state issue):** Empty, error, loading, SnackBar, and 201 `AlertDialog` surfaces look generic and unbranded instead of echoing website `#0d2236`/`#071525`/`#36c2ae`/`#ff9b8f` states.
- **D07 (Accessibility & parity issue):** `ProjectDetailScreen` still uses `SelectableText` (fixed in CP4 `QC-11` on `CertificationDetailScreen` via `SelectionArea` + `Text`), `LoginScreen` lacks password visibility toggle, and strict reuse of website `#27455b` on input borders would drop below WCAG 3:1 UI component contrast (`1.61:1`).
- **D08 (Responsive issue):** On `390×844` Home, 3-column `InfoCard` wraps `250661471\n2` mid-digit (`flutter-before/home-390.png`); on `1280×800` desktop Web (`flutter-before/home-1280.png`), unbounded `GridView.count` expands Home cards into oversized ~400×480px blocks hiding the second row below the fold.

---

## 7. Proposed Visual Direction

Implement a lean **2-file shared design system** (`lib/theme/app_tokens.dart` + `lib/theme/app_theme.dart`) applying the website's **dark Navy & Mint-Teal editorial system** across every route via `MaterialApp.theme`:
- Dark-only `ThemeData` (`Brightness.dark`, `useMaterial3: true`), `scaffoldBackgroundColor: #071525`, explicit `ColorScheme.dark` mapped strictly to website palette + WCAG-safe `#4b7794` idle input border (`3.36:1`) and `#ff9b8f` form error (`7.96–9.04:1`).
- Flat bordered surfaces (`1px solid #27455b`, `BorderRadius.circular(10)`, `elevation: 0`).
- Zero fake gradients, zero `BackdropFilter` glassmorphism, zero fake stats/metrics, zero bottom navigation bar, zero extra pub packages.

---

## 8. Screen-by-Screen Redesign Proposal

1. **`lib/main.dart`:** Wire `buildAppTheme()` from `lib/theme/app_theme.dart` without altering `MultiProvider`, `ApiClient`, or `AuthState`.
2. **`lib/screens/menu.dart` (`MyHomePage`, stays `StatelessWidget`):**
   - `AppBar` with brand title `MyPortfolio.` (teal dot span), `#071525` bg, `1px #27455b` bottom divider.
   - Constrained centered body (`maxWidth: 840`) preventing desktop ballooning (`D08`).
   - Top **Hero Identity Card** (`#0d2236`, `#27455b` border, `10px` radius): uppercase `#36c2ae` kicker (`INFORMATION SYSTEMS · UNIVERSITAS INDONESIA`), bold `Glenn Josia Devano.`, plus non-wrapping identity metadata pills/blocks (`NPM 2506614712`, `Kelas PBP F`) cleanly replacing cramped 3-column `InfoCard` digit wrapping (`D08`). Optionally reuse website `profile.png` (`83KB`) with `#36c2ae` border (Decision #4) if approved.
   - Portfolio section heading (`KARYA & KREDENSIAL` / `Akses Cepat.`) + cohesive `ItemCard` grid (`3` columns on wide, `2` on narrow `<520px`/large text, capped max tile height via `ConstrainedBox`/`mainAxisExtent` on desktop so all 5 cards fit cleanly above the fold at `1280×800`). Preserve exact button labels (`Lihat Proyek`, `Tambah Proyek`, `Logout`, `Tambah Sertifikasi`, `Lihat Sertifikasi`), behavior, and guards.
3. **`lib/widgets/left_drawer.dart`:**
   - Dark `#0d2236` drawer with `#071525` `DrawerHeader` (`MyPortfolio.`, subtitle, auth indicator pill `Authenticated` in `#36c2ae` vs `Guest` in `#a9bbca`), `1px #27455b` section dividers (`PORTFOLIO` / `KELOLA` / `SESI`), active route highlight (`#123750` tile fill + `#36c2ae` icon/text), preserving `_busy` lock, `closeDrawer()`, and `popUntil((r) => r.isFirst)` (`QC-01`, `QC-06`).
4. **`lib/widgets/project_card.dart` (`ItemCard`):**
   - Retain `ItemHomepage` model API & `_busy` lock (`QC-02`). Replace rainbow fills with `#0d2236` surface (`1px` semantic accent/border: `#36c2ae` accent for primary read actions `Lihat Proyek`/`Lihat Sertifikasi`, `#123750` + `#36c2ae` border or subtle icon badge for `Tambah*`, `#b42318` accent border/icon for `Logout`), keeping white `#f6f8fb` title (`maxLines: 2`, NO `FittedBox`) and `10px` radius (`D01`, `D03`). *(Subject to Decision #2 on updating `widget_test.dart:203-228` color assertions.)*
5. **`lib/screens/project_list_screen.dart` & `lib/screens/certification_list_screen.dart`:**
   - Centered `maxWidth: 840` scrollable `ListView` inside `RefreshIndicator`, keeping `_projects`/`_certifications` in `initState()`.
   - Dark `#0d2236` cards with `1px #27455b` border, `10px` radius, `16–20px` padding:
     - Projects card: uppercase `#36c2ae` `techStack` kicker, bold `#f6f8fb` title, muted `#a9bbca` description (`maxLines: 3`), subtle trailing chevron.
     - Certifications card: uppercase `#36c2ae` `issuingOrganization` (`maxLines: 2`), bold `#f6f8fb` `name`, crisp date row (`Terbit` + `Berakhir` / `Tanpa kedaluwarsa` never truncated — preserves `QC-05`), trailing chevron.
   - Add `Muat ulang` icon consistency on `ProjectListScreen` AppBar too (`QC-10` parity) + shared `EmptyStateView` / `ErrorStateView`.
6. **`lib/screens/project_detail_screen.dart` & `lib/screens/certification_detail_screen.dart`:**
   - Constrained `maxWidth: 720`, `SelectionArea` wrapping `ListView` (`QC-11` parity on both screens), AppBar concise title (`Detail Proyek` / `Detail Sertifikasi` so long names display cleanly in hero card header below without AppBar ellipsis truncation!).
   - Project Detail: safe HTTP/HTTPS image frame with `#27455b` border (collapsed completely if `projectImageUrl` empty), `#36c2ae` `techStack` badge/kicker, `h2` title, grouped description & URL cards.
   - Certification Detail: grouped card displaying all 6 exact user-facing fields (`Nama Sertifikasi`, `Lembaga Penerbit`, `ID Kredensial`, `Tanggal Terbit`, `Tanggal Kedaluwarsa`, `URL Kredensial`) with strong label/value contrast (`#a9bbca` label -> `#f6f8fb` value).
7. **`lib/screens/project_form.dart` & `lib/screens/certification_form.dart`:**
   - Inherit dark `#071525` AppBar & `#0d2236` input decoration (`10px` radius, `#ff9b8f` `errorMaxLines: 4`, `80px` bottom padding `QC-03`, `PopScope`, drawer lock `QC-07`).
   - Group `CertificationFormPage` under compact uppercase `#36c2ae` section kickers (`INFORMASI SERTIFIKASI`, `MASA BERLAKU`, `REFERENSI KREDENSIAL`) without adding/removing fields. Dark-themed `DatePickerDialog` via `DatePickerThemeData`, solid `#36c2ae` `Simpan`/`Save` CTA (`48dp` height, `#071525` bold text), and themed `#071525`/`#27455b`-bordered 201 `AlertDialog` with `#22c55e` success check.
8. **`lib/screens/login_screen.dart`:**
   - Centered `#0d2236` card (`maxWidth: 440`, `1px #27455b` border, `10px` radius), `#36c2ae` kicker `AKSES PORTOFOLIO`, `Login.` title, concise explanation (`Masuk untuk menambahkan proyek atau sertifikasi ke backend Django.`), optional eye icon visibility toggle on Password field (`48dp` hit target), full-width `#36c2ae` `Masuk` button, `#ff9b8f` `errorText`, preserving `PopScope`, `hideCurrentSnackBar()`, and token auth logic.
9. **`lib/widgets/state_views.dart` (minimal shared empty & error widgets):**
   - `EmptyStateView(icon, title, subtitle)` and `ErrorStateView(message, onRetry)` reused across `ProjectListScreen` and `CertificationListScreen`.

---

## 9. Accessibility Risks & Adaptations

- **Border contrast (`#27455b` = `1.61:1`):** Used strictly on decorative surfaces/dividers; interactive form fields use adapted `#4b7794` (`3.36:1`) idle border + `#36c2ae` (`7.30:1`) focus border + `#ff9b8f` (`7.96:1`) error border.
- **200% text scaling & 320px narrow screens:** Zero `FittedBox` label shrinking; fluid `Wrap`/`Column` metadata rows instead of cramped 3-column `Row` for NPM; scrollable containers across all screens & drawer.
- **Semantics & selection:** Extend `SelectionArea` + `Text` (`QC-11`) to `ProjectDetailScreen`; keep `48×48dp` minimum touch targets on AppBar/clear/password-visibility icon buttons and CTA buttons; communicate loading/error/empty/401/403 states through explicit Indonesian copy + icons, never color alone.

---

## 10. Implementation Scope (UI Checkpoints 2–4)

- **UI Checkpoint 2:** `lib/theme/app_tokens.dart`, `lib/theme/app_theme.dart`, `lib/main.dart`, `lib/screens/menu.dart`, `lib/widgets/left_drawer.dart`, `lib/widgets/project_card.dart` (+ optional `Space Grotesk` assets if approved), plus updating/preserving `test/widget_test.dart`.
- **UI Checkpoint 3:** `lib/widgets/state_views.dart`, `lib/screens/project_list_screen.dart`, `lib/screens/project_detail_screen.dart`, `lib/screens/project_form.dart`, `lib/screens/certification_list_screen.dart`, `lib/screens/certification_detail_screen.dart`, `lib/screens/certification_form.dart`, `lib/screens/login_screen.dart`.
- **UI Checkpoint 4:** Before/after screenshot comparison, independent visual/accessibility/responsive/functional QC subagent audit, Chrome E2E, Android smoke QA, full quality gate (`67+` Flutter tests, `111` Django unchanged), and `docs/ui-ux/FINAL_REPORT.md`.
- **Explicitly Excluded:** Zero Django modifications, zero API/serializer/auth changes, zero new third-party Dart dependencies (unless user chooses an optional asset-only font bundle — no `google_fonts` package), zero Assignment 9 history edits.

---

## 11. Functional & Test Preservation Plan

- Keep every API contract (`ApiClient`, `ApiException`, `AuthState`, `ensureLoggedIn`, `Certification`, `Project`, `*.g.dart` ignores), key identifier (`Key('projectNameField')`, `Key('saveButton')`, etc.), Indonesian dialog/error strings (`Sertifikasi berhasil ditambahkan!`, `Tutup`, `Lihat Daftar`, `Coba lagi`, `Muat ulang`), `PopScope`, and CP4 QC fixes (`QC-01`–`QC-11`) intact.
- **Known test impact (`test/widget_test.dart:203-228`):** Existing test `'setiap ItemCard memakai warna unik dari model'` explicitly asserts the 5 hardcoded rainbow colors `[0xFF1565C0, 0xFF2E7D32, 0xFFBF360C, 0xFF6A1B9A, 0xFF00695C]` and `expect(colors.toSet(), hasLength(5))`. When updating `ItemCard` to website-aligned Navy/Mint-Teal tokens (upon Decision #2 approval), update ONLY that color assertion to assert the approved design-system `ItemHomepage.color` tokens & contrast pairs while retaining `'setiap ItemCard memakai warna model pada Material'` behavior, all 5 icon/label checks, and all 67/67 functional/auth/401/403/responsive assertions.

---

## 12. Proposed Changed Files & Required Decisions Before UI Checkpoint 2

- **Proposed files (CP2–CP3):** `lib/theme/app_tokens.dart`, `lib/theme/app_theme.dart`, `lib/widgets/state_views.dart`, `lib/main.dart`, `lib/screens/{menu,login_screen,project_list_screen,project_detail_screen,project_form,certification_list_screen,certification_detail_screen,certification_form}.dart`, `lib/widgets/{left_drawer,project_card}.dart`, relevant visual assertions in `test/widget_test.dart` (+ responsive/after-redesign tests), and `docs/ui-ux/FINAL_REPORT.md` (plus `pubspec.yaml`/`assets/` only if optional local font/avatar assets are approved).

### Decisions Awaiting User Approval:
1. **Branch isolasi (Disarankan):** Jalankan `git switch -c feat/website-aligned-mobile-ui` secara manual agar baseline Assignment 9 (`0470022` di `main`) tetap utuh?
2. **Skema 5 kartu Home (`menu.dart` / `project_card.dart`):** Ganti 5 warna pelangi lama (`#1565C0`, `#2E7D32`, `#BF360C`, `#6A1B9A`, `#00695C`) ke skema seragam website (`#0d2236` surface + aksen semantik `#36c2ae`/`#27455b`/`#b42318`) dan perbarui assertion warna di `test/widget_test.dart:203-228`, ATAU pertahankan 5 warna pelangi lama di `ItemCard`? *(Rekomendasi: ganti ke skema website agar konsisten.)*
3. **Font `Space Grotesk`:** Bundle static font OFL `Space Grotesk` (Regular/Medium/Bold + lisensi `OFL.txt`) ke `assets/fonts/` (tanpa package `google_fonts`), ATAU gunakan fallback sans-serif bawaan sistem (`Roboto`/`SF`) agar ukuran APK tetap minimal?
4. **Foto profil pada Hero Home:** Pakai ulang aset resmi `myportofolio/static/img/profile.png` (`83 KB`, bingkai `#36c2ae` seperti website) pada Hero `MyHomePage`, ATAU cukup avatar monogram inisial `GJ` agar aset biner tidak diduplikasi?
