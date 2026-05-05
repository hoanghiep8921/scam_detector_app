# CLAUDE.md — Scam Detector

Tài liệu ngữ cảnh cho Claude Code. Đọc đầu mỗi phiên làm việc.

## 1. Mục tiêu sản phẩm

Ứng dụng mobile (ưu tiên Android) phát hiện lừa đảo đa kênh:

- Cuộc gọi đến (CallScreeningService — Android, full-screen overlay)
- Số điện thoại nhập tay
- Số tài khoản ngân hàng
- Đường dẫn website (URL phishing)
- Nội dung tin nhắn / email (free-text → AI)

Tích hợp **Gemini Flash** (default `gemini-flash-latest` — alias auto-rotate
sang Flash mới nhất, override qua `.env` `GEMINI_MODEL=...`) để phân tích
**hành vi đa góc nhìn**: **ngôn ngữ học + an ninh mạng + tâm lý học xã hội**
(Cialdini). Hỗ trợ **multimodal**: text + ảnh + video (tối đa 5 ảnh + 1 video,
~18 MB / request). Ưu tiên kết quả **explainable** (có lý do cụ thể, không
chỉ điểm số), tiếng Việt phổ thông.

## 2. Stack

| Thành phần        | Công nghệ                                              |
|-------------------|--------------------------------------------------------|
| Mobile            | Flutter 3.41+ (Dart 3.11+), Material 3 light           |
| Native Android    | Kotlin (CallScreeningService, API 24+)                 |
| AI                | `google_generative_ai` (Gemini Flash) — on-demand, multimodal |
| Multimodal picker | `image_picker` 1.1+ (gallery / camera / video)         |
| Cloud DB          | `supabase_flutter` 2.12+ (`scam_checks` + `known_risks`) |
| State management  | `provider` (`ChangeNotifier`)                          |
| Local storage     | `shared_preferences` (history cache + native blocklist + device_id + known_risks cache) |
| Crash reporting   | `sentry_flutter` 8.9+ — disabled khi `SENTRY_DSN` rỗng |
| Typography        | `google_fonts` (Public Sans + Inter)                   |
| Cấu hình env      | `flutter_dotenv` (`.env`)                              |
| Launcher icon     | `flutter_launcher_icons` (dev_dependency)              |
| Release signing   | RSA-2048 keystore tại `android/upload-keystore.jks` (gitignored) |

## 3. Lộ trình & trạng thái

| Pha | Nội dung                                                          | Trạng thái |
|-----|-------------------------------------------------------------------|------------|
| 1   | Setup project, theme, navigation                                  | ✅          |
| 2   | Kiểm tra số điện thoại                                            | ✅ (gộp cả URL/STK) |
| 3   | Multi-input (số TK + URL)                                         | ✅          |
| 4   | Tích hợp Gemini Flash + JSON output                               | ✅          |
| 5   | CallScreeningService (Android) + full-screen overlay              | ✅          |
| 6   | Polish & demo (animation, copy, etc.)                             | ✅          |
| 7   | Áp design system "Sentinel Assurance" (Stitch)                    | ✅          |
| 8   | Cloud history qua Supabase (`scam_checks`)                        | ✅          |
| 9   | Lookup-then-AI flow (local → Supabase → AI on-demand)             | ✅          |
| 10  | AI 3 góc nhìn: ngôn ngữ học + an ninh mạng + tâm lý xã hội        | ✅          |
| 11  | Migrate JSON → Supabase `known_risks` (centralized blocklist)     | ✅          |
| 12  | Notifications inbox (chuông) + unread badge từ history native-*   | ✅          |
| 13  | Reset toàn bộ dữ liệu app + CRUD known_risks (Add FAB / swipe del)| ✅          |
| 14  | Buttons IncomingCallScreen thực sự add/remove blocklist           | ✅          |
| 15  | Shared `CallScreeningRoleProvider` (Home hero ↔ Bảo Vệ tab sync)  | ✅          |
| 16  | Production: app icon mới + release keystore + split-per-ABI APK   | ✅          |
| 17  | Tắt Auto Backup + permission INTERNET cho release build           | ✅          |
| 18  | Loading Gemini-style (sparkles orbit + sweep gradient ring)       | ✅          |
| 19  | Multimodal AI: text + ảnh + video qua Gemini (max 5 ảnh + 1 video, 18 MB) | ✅  |
| 20  | Sentry crash + error reporting (auto-disable khi DSN rỗng)        | ✅          |
| 21  | Đổi default model sang `gemini-flash-latest` alias + override qua `.env` | ✅   |
| 22  | Đồng nhất "Phân tích nội dung": Home tile + segment tab Kiểm tra → cùng 1 màn | ✅ |

Khi làm việc tiếp, nhớ cập nhật cả README.md lẫn bảng này.

## 4. Cấu trúc thư mục (rút gọn)

```
lib/
├── main.dart                       # entry: load .env + Supabase.initialize
├── app.dart                        # MultiProvider (ScamCheck + CallScreeningRole)
├── core/
│   ├── constants/                  # AppColors, ApiConfig (có hasSupabase)
│   └── theme/                      # AppTheme M3 + Public Sans/Inter
├── data/models/                    # RiskLevel, ScamCheckResult (3 signal lists), MediaAttachment
├── services/
│   ├── gemini_service.dart         # Gemini Flash (3-axis prompt + multimodal) — on-demand
│   ├── local_risk_service.dart     # Supabase known_risks + local SharedPreferences cache (TTL 24h)
│   ├── remote_risk_service.dart    # aggregate Supabase scam_checks (consensus)
│   ├── history_service.dart        # remote upsert + local cache, dedupe by id
│   ├── device_id_service.dart      # random UUID lưu local 1 lần đầu, có reset()
│   ├── call_screening_service.dart # MethodChannel: role / sync / get / add / remove / clear
│   └── data_reset_service.dart     # orchestrate clear-all (native + cache + history + device_id)
├── features/
│   ├── main_shell.dart             # bottom nav 4 tab + listener cuộc gọi đến + drain queue
│   ├── home/                       # dashboard: hero (shared role) + stats + tiles + activity + bell
│   ├── scam_check/                 # segmented control + provider (4 target)
│   ├── result/                     # gauge + radar + 3 axis cards + AI CTA
│   ├── call_screening/             # status + sync + reset + 2 nav tile + role provider
│   │   ├── call_screening_screen.dart
│   │   └── call_screening_role_provider.dart
│   ├── incoming_call/              # full-screen warning + add/remove blocklist actions
│   ├── blocklist/                  # browser danh sách offline NATIVE đang giám sát
│   ├── known_risks/                # browse Supabase DB + FAB Thêm + swipe-to-delete
│   ├── notifications/              # inbox cuộc gọi đã chặn (filter id native-*)
│   ├── content_analysis/           # free-text + ảnh/video → AI multimodal flow
│   └── history/                    # 100 lượt gần nhất
└── shared/widgets/                 # RiskBadge, FactorBar, RiskGauge,
                                    # ThreatRadarChart, ScanningOverlay (Gemini-style),
                                    # SkeletonBlock

android/app/src/main/kotlin/com/scamdetector/scam_detector/
├── MainActivity.kt                 # forward intent extras → Bridge
└── callscreening/
    ├── IncomingCallScreener.kt     # CallScreeningService (chặn + screening_events queue)
    └── CallScreeningBridge.kt      # MethodChannel: role / sync / get / add / remove / clearAll / drain

android/app/src/main/res/xml/
└── data_extraction_rules.xml       # Tắt cloud auto-backup + device transfer

android/
├── upload-keystore.jks             # Release signing key (gitignored, RSA-2048)
└── key.properties                  # storePassword/keyPassword/keyAlias (gitignored)

assets/icon/
├── icon.png                        # Source 1024×1024 cho launcher (full design)
└── icon_foreground.png             # Adaptive icon foreground (62% scale, transparent bg)

dist/                               # APK phân phối (gitignored, đã ký release)
├── ScamGuard-v1.0.0-arm64.apk      # ~19 MB
├── ScamGuard-v1.0.0-arm32.apk      # ~16 MB
└── ScamGuard-v1.0.0-x86_64.apk     # ~20 MB

supabase/migrations/                # 0001-0004 (scam_checks); 0005-0006 (known_risks)
```

## 5. Quy ước code

- **Ngôn ngữ UI**: tiếng Việt phổ thông. Mọi label, snackbar, error, prompt AI
  đều tiếng Việt. Identifier code, comment, log → tiếng Anh.
- **State**: `ChangeNotifier` qua `Provider`. 2 root provider:
  - `ScamCheckProvider` — check / history / AI / ingest screened calls
  - `CallScreeningRoleProvider` — shared role-held state (Home hero ↔ Bảo Vệ)
  Không thêm Riverpod/Bloc.
- **Mức rủi ro**: enum `RiskLevel { safe, suspicious, scam, unknown }`.
  - 0–39 → safe (xanh `riskSafe`)
  - 40–69 → suspicious (cam `riskMedium`)
  - 70–100 → scam (đỏ `riskHigh`)
  - Màu palette `core/constants/app_colors.dart`. KHÔNG hard-code màu.
- **Lookup priority** (trong `ScamCheckProvider.check()`):
  1. `LocalRiskService.lookup()` — fetch từ Supabase `known_risks` table,
     cache local 24h. Lookup là exact match `(type, normalized_value)`.
  2. `RemoteRiskService.lookup()` — consensus từ `scam_checks` Supabase
     (theo `target` + `normalized_input`, weighted by distinct device_id).
  3. Trả về placeholder `RiskLevel.unknown` với CTA "Phân tích sâu bằng AI".
- **AI is on-demand only**. Gemini KHÔNG được auto-call trong `check()` cho
  3 target structured (phone/bank/url). Chỉ gọi khi user bấm
  `analyzeWithAi(result)` trong `ResultScreen`. Riêng `CheckTarget.content`
  (free-text + ảnh/video) **luôn** đi thẳng Gemini vì không có lookup phù hợp.
- **Multimodal**: `GeminiService.analyze` nhận `attachments: List<MediaAttachment>`
  và build `Content.multi([TextPart(prompt), DataPart(mime, bytes), …])`. Cap
  ở 18 MB / request (Gemini hard limit ~20 MB) — UI ở `ContentAnalysisScreen`
  enforce: tối đa 5 ảnh + 1 video.
- **Stub mode**: thiếu `GEMINI_API_KEY` → result giải thích cách config.
  Thiếu `SUPABASE_URL`/`SUPABASE_ANON_KEY` → blocklist offline rỗng (không
  còn fallback JSON file). Cố ý — buộc setup Supabase trước khi demo.
- **Release builds bắt buộc khai INTERNET** (đã thêm trong manifest). Nếu
  thiếu, debug chạy được nhưng release fail "Failed host lookup".

## 6. AI prompt — 3 góc nhìn

Prompt trong `GeminiService._buildPrompt` yêu cầu Gemini phân tích theo:

1. **Ngôn ngữ học** (`linguistic`) — kịch bản, từ khoá hối thúc, mạo danh
   thương hiệu trong tên hiển thị, lỗi chính tả/ngữ pháp.
2. **An ninh mạng** (`cybersecurity`) — typo-squatting, TLD lạ, dải đầu số
   đã từng lừa đảo, mule account, brand impersonation, cert SSL.
3. **Tâm lý xã hội** (`socialTactics`) — 6 nguyên tắc Cialdini (Reciprocity /
   Commitment / Social Proof / Authority / Liking / Scarcity) + thao túng
   cảm xúc.

JSON trả về (cố định, không đổi field):

```json
{
  "riskScore": <int 0-100>,
  "riskLevel": "<safe|suspicious|scam>",
  "summary": "<1-2 câu>",
  "reasons": ["..."],
  "psychological": { "urgency": 0-100, "fear": 0-100, "authority": 0-100, "greed": 0-100 },
  "linguistic":     ["..."],
  "cybersecurity":  ["..."],
  "socialTactics":  ["..."]
}
```

Khi mở rộng prompt: giữ nguyên 3 key list `linguistic`/`cybersecurity`/
`socialTactics` để parser + UI khớp. `LocalRiskService` cũng đọc 3 key này
từ Supabase row (qua column `linguistic_signals` / `cyber_signals` / `social_tactics`).

## 7. Supabase

- **Project URL** + **anon/publishable key** trong `.env` (`SUPABASE_URL`,
  `SUPABASE_ANON_KEY`). Key có thể là legacy JWT (`eyJhbGc...`) hoặc format
  mới `sb_publishable_...` — SDK 2.12+ chấp nhận cả hai.

### Tables

1. **`public.scam_checks`** (per-device history, migrations 0001 → 0004)
   - 13 cột: id, device_id, target, input, normalized_input, risk_level,
     risk_score, summary, reasons (jsonb), psychological (jsonb),
     linguistic_signals (jsonb), cyber_signals (jsonb), social_tactics (jsonb),
     checked_at.
   - RLS: anon read/insert/delete = true. Filter theo `device_id`.
   - **Upsert** (PRIMARY KEY id) — re-analyze AI cùng id sẽ overwrite.

2. **`public.known_risks`** (centralized blocklist, migration 0005 + 0006)
   - 13 cột: id, type, value, normalized_value, risk_level, score, summary,
     reasons, psychological, linguistic_signals, cyber_signals,
     social_tactics, created_at, updated_at.
   - `UNIQUE (type, normalized_value)` — upsert ON CONFLICT.
   - RLS: anon read/insert/update/delete = true (demo). Tighten before prod.
   - Trigger `known_risks_touch_updated_at` tự cập nhật `updated_at`.
   - Seed sẵn 123 entries (57 phone, 26 bank, 40 url) trong migration 0005.

### Migration order

```
supabase/migrations/0001_scam_checks.sql        # base table + RLS
supabase/migrations/0002_normalized_input.sql   # add normalized_input col
supabase/migrations/0003_multi_axis_signals.sql # 3 jsonb axis cols
supabase/migrations/0004_content_target.sql     # accept target='content'
supabase/migrations/0005_known_risks.sql        # NEW table + RLS + 123 seed rows
supabase/migrations/0006_known_risks_delete.sql # add anon delete policy
```

Run trong dashboard SQL Editor theo thứ tự. Idempotent (`if not exists` /
`on conflict do update`).

### Identity & filtering

- **device_id** (UUID v4) là `DeviceIdService.get()`, lưu local 1 lần đầu.
  `DeviceIdService.reset()` xoá → tạo mới (dùng trong Reset toàn bộ app).
- Mọi insert/select/delete `scam_checks` đều filter theo `device_id`.
- `known_risks` shared toàn bộ user — không filter device.
- **normalized_value**/**normalized_input** quan trọng cho lookup đa định
  dạng — dùng `LocalRiskService.normalize(target, input)` (SQL backfill
  cũng dùng cùng pattern). Khi sửa `normalize`, sync luôn migration regex.

## 8. CallScreeningService (Android)

- `minSdk = 24` (yêu cầu của `CallScreeningService`).
- `ROLE_CALL_SCREENING` chỉ có từ API 29 — `CallScreeningBridge` đã fallback.
- `USE_FULL_SCREEN_INTENT` + `INTERNET` + `ACCESS_NETWORK_STATE` permission
  đã khai trong manifest.
- App **không** lưu/gửi số ra ngoài (ngoài cloud `known_risks` mà user chủ
  động đồng bộ). Blocklist native ở `SharedPreferences("scam_detector_prefs")`
  keys `scam_numbers` / `suspicious_numbers` / `screening_events` (queue).
- **Cloud auto-backup tắt** (manifest `allowBackup="false"` +
  `dataExtractionRules`). Uninstall = wipe sạch state.

### Flow cuộc gọi đến

1. `IncomingCallScreener.onScreenCall()` — chặn nếu trùng `scam_numbers`,
   thông báo nếu trùng `suspicious_numbers`, allow nếu không trùng.
   Mọi event đều ghi vào queue `screening_events` (JSON list trong prefs).
2. Notification dùng `setFullScreenIntent` + `CATEGORY_CALL` để tự bật
   overlay (qua `MainActivity` → MethodChannel).
3. `MainActivity.forwardIncomingCallExtras()` →
   `CallScreeningBridge.notifyIncomingCall()` →
   `MethodChannel("incomingCallDetected", ...)` → `MainShell._onIncomingCall`
   → push `IncomingCallScreen` + drain queue vào history.
4. Khi user mở app từ launcher (không qua notification), `MainShell` drain
   queue trên `initState` + `AppLifecycleState.resumed` → mọi cuộc gọi đã
   chặn vẫn vào history.

### MethodChannel methods (`com.scamdetector/call_screening`)

| Method | Hướng | Hành động |
|---|---|---|
| `registerIncomingCallListener` | Dart → Native | Báo native push event đã buffer |
| `incomingCallDetected` | Native → Dart | Forward live event (number/label/blocked) |
| `syncBlocklist` | Dart → Native | Đẩy `{scam, suspicious}` xuống prefs |
| `getBlocklist` | Dart → Native | Đọc prefs trả về `{scam, suspicious}` |
| `addBlocklistNumber` | Dart → Native | Thêm 1 số (auto-promote nếu cần) |
| `removeBlocklistNumber` | Dart → Native | Gỡ khỏi cả 2 set |
| `clearAllNativeData` | Dart → Native | Xoá hết prefs `scam_detector_prefs` |
| `drainScreeningEvents` | Dart → Native | Lấy + clear queue native |
| `isCallScreeningRoleHeld` | Dart → Native | Check `RoleManager.isRoleHeld` |
| `requestCallScreeningRole` | Dart → Native | Show system role dialog |

## 9. Quy ước UX

- **Design system**: bám "Sentinel Assurance" trong Stitch project
  `1467129125893543901` ("AI Scam Shield Mobile"). Visible screen: Home
  Dashboard, Manual Check, AI Analysis Result, Incoming Call Overlay,
  Notifications inbox, Blocklist browser, Known Risks DB browser.
- **Primary** `#1A237E`, **Headlines** Public Sans, **Body/UI** Inter.
- **Roundness**: cards 16px, inputs 12px, primary buttons stadium-pill.
- **Bottom nav** 4 tab (`MainShell`): Trang chủ / Kiểm tra / Lịch sử / Bảo vệ.
- **App icon** Sentinel Assurance (navy `#0B1D42` + shield + magnifying + thief
  silhouette). Source `assets/icon/icon.png`. Adaptive icon Android 8+.
- **Loading**: `ScanningOverlay` Gemini-style (3 sparkles xoay quanh shield +
  sweep gradient ring + outer pulse aura). KHÔNG dùng spinner inline trong nút.
- **URL `suspicious`/`scam`**: phải hỏi xác nhận trước khi mở.
- **Local lookup result**: prefix `"(Tra cứu cộng đồng)"` ở reason đầu tiên
  (đổi từ "Tra cứu offline" vì giờ source là cloud DB, không phải JSON local).
- **Remote aggregate result**: prefix `"(Cơ sở dữ liệu cộng đồng)"` ở reason đầu.
- **3 axis cards** trong ResultScreen có vertical accent bar bên trái:
  - Ngôn ngữ học → tím `#7B1FA2`
  - An ninh mạng → cyan `#00838F`
  - Tâm lý xã hội → hồng `#C2185B`
- **Charts**: `RiskGauge` (arc bán nguyệt) + `ThreatRadarChart` (4-axis
  CustomPainter). Đừng add fl_chart hay lib chart khác.
- **Empty-state guards** trong ResultScreen: ẩn `_TargetCard` nếu input rỗng,
  ẩn summary text nếu rỗng → tránh khoảng trắng cho record placeholder.

### Tab Bảo Vệ tiles (theo thứ tự)

1. Status card (đã bật / chưa bật / iOS).
2. Counters offline blocklist (read trực tiếp từ native via `getBlocklist`).
3. Nút "Bật cảnh báo cuộc gọi" (chỉ khi chưa bật role).
4. NavTile "Danh sách offline đang chặn" → `BlocklistScreen` (read-only).
5. NavTile "Cơ sở dữ liệu lừa đảo" → `KnownRisksScreen` (CRUD + 3 tab).
6. NavTile "Reset toàn bộ dữ liệu app" → confirm dialog + checkbox cloud.

### Home hero ↔ Bảo Vệ tab đồng bộ

`CallScreeningRoleProvider` (singleton ChangeNotifier) là single source of
truth. Cả 2 màn `context.watch` chung — bật từ đâu cũng sync.
`setRoleHeld(granted)` được gọi ngay sau system dialog return.

## 10. Lệnh thường dùng

```bash
flutter pub get
flutter analyze            # phải sạch
flutter test               # phải pass
flutter build apk --debug  # verify Kotlin/native build
flutter run -d emulator-5554

# Release distribution (split per ABI)
flutter build apk --release --split-per-abi
# → build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (~19 MB)
# → copy thủ công sang dist/ScamGuard-v<version>-<abi>.apk

# Regen launcher icon sau khi đổi assets/icon/icon.png
flutter pub run flutter_launcher_icons

# adb (Android SDK platform-tools)
~/Library/Android/sdk/platform-tools/adb -s <device-id> emu gsm call 0369218921
~/Library/Android/sdk/platform-tools/adb -s <device-id> install -r dist/ScamGuard-v1.0.0-arm64.apk
~/Library/Android/sdk/platform-tools/adb -s <device-id> uninstall com.scamdetector.scam_detector
~/Library/Android/sdk/platform-tools/adb -s <device-id> logcat | grep -E "flutter|IncomingCallScreener|PostgrestException"

# Verify APK signing
~/Library/Android/sdk/build-tools/37.0.0/apksigner verify --print-certs dist/ScamGuard-v1.0.0-arm64.apk
```

## 11. Test

- `test/widget_test.dart` — smoke test home + bottom nav.
- `test/local_risk_service_test.dart` — unit test `normalize` cho 3 target.
- Khi sửa `normalize`, chạy `flutter test` để verify rule chuẩn hoá vẫn đúng.

## 12. Release & phân phối

### Signing config

- Keystore: `android/upload-keystore.jks` (RSA-2048, valid 10000 ngày).
- Credentials: `android/key.properties` (storePassword + keyPassword).
- Cả 2 file đã trong `.gitignore` (`*.jks`, `key.properties`).
- `build.gradle.kts` load `keystoreProperties` qua `Properties()`. Nếu file
  vắng mặt → fallback debug key.
- **Backup keystore quan trọng**: mất → không update được app cho user đã cài.

### Distribution

- 3 file `.apk` trong `dist/` (gitignored): arm64 / arm32 / x86_64.
- ~18-22 MB / file (giảm 10× so với debug 201 MB).
- Tên file `ScamGuard-v<semver>-<abi>.apk` (vd. `ScamGuard-v1.0.2-arm64.apk`).
- Bump version khi distribute mới: pubspec `version: x.y.z+versionCode` —
  versionCode tăng dần để Android cho update in-place.
- Cài cho friends: gửi file qua Zalo / Drive → user bấm Install anyway
  (Play Protect cảnh báo vì sideload + sensitive perms — không tránh được
  trừ khi đăng Play Store Closed Testing).

### Permissions tối thiểu (manifest)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<!-- Multimodal AI (image/video picker). API 33+ dùng granular media. -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.CAMERA" />
```

`<application android:allowBackup="false" android:dataExtractionRules="...">`
→ uninstall = wipe state, không restore từ Google Drive.

## 13. Việc còn để mở

- **Auth** (Supabase email/Google) → per-user RLS policies. Hiện tại anon
  có quyền insert/update/delete trên cả 2 table.
- **Persistent user whitelist**: hiện "Tôi vẫn tin số này" chỉ remove khỏi
  native blocklist tạm thời — `Đồng bộ lại` từ cloud sẽ re-add. Cần set
  `user_whitelist` riêng có precedence.
- **Push notification (FCM)** khi cộng đồng phát hiện scam mới hoặc cập
  nhật `known_risks`.
- **iOS**: không hỗ trợ call screening (giới hạn nền tảng). Tab Bảo Vệ
  hiện đã hint khi `Platform.isAndroid == false`.
- **Offline outbox** cho check: hiện tại nếu Supabase fail → vẫn ghi local
  nhưng không retry sync sau.
- **Region fallback cho Gemini**: nếu user dùng VPN / mạng không hỗ trợ
  (UnsupportedUserLocation), giờ chỉ hiện message hướng dẫn tắt VPN /
  đổi WiFi. Có thể proxy qua Cloud Function để bypass.
- **Play Store Closed Testing** — bước tiếp theo để loại bỏ cảnh báo Play
  Protect cho beta tester (cần $25 1-time, upload AAB, Closed track).
- **Ultrareview / security review** trước khi go-prod (RLS hiện quá lỏng).

Khi nhận task mới, ưu tiên check mục này trước khi đề xuất feature mới.
