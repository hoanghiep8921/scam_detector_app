# Scam Detector

Ứng dụng Flutter phát hiện lừa đảo đa kênh: số điện thoại, tài khoản ngân
hàng, đường dẫn website, nội dung tin nhắn, cuộc gọi đến (Android). AI
Gemini Flash phân tích hành vi theo **3 góc nhìn kết hợp**:

- 🔤 **Ngôn ngữ học** — kịch bản, từ khoá hối thúc, mạo danh thương hiệu trong copy
- 🛡️ **An ninh mạng** — typo-squatting, TLD lạ, mule account, brand impersonation
- 🧠 **Tâm lý học xã hội** — 6 nguyên tắc Cialdini + thao túng cảm xúc

Lookup **cộng đồng (Supabase) → AI on-demand**. Mọi cảnh báo có lý do
explainable cho người dùng phổ thông tiếng Việt.

## Trạng thái

| Pha | Nội dung                                                          | Trạng thái |
|-----|-------------------------------------------------------------------|------------|
| 1   | Setup project, theme, navigation                                  | ✅          |
| 2-3 | Multi-input (phone / bank / URL / content)                        | ✅          |
| 4   | Gemini Flash + JSON output                                        | ✅          |
| 5   | CallScreeningService (Android) + full-screen warning overlay      | ✅          |
| 6   | Polish (animation, copy, mở URL có cảnh báo)                      | ✅          |
| 7   | Design system "Sentinel Assurance" (Stitch)                       | ✅          |
| 8   | Cloud history (Supabase) + device-id anonymous attribution        | ✅          |
| 9   | Lookup-then-AI flow (AI on-demand, không auto-call)               | ✅          |
| 10  | AI 3 góc nhìn: ngôn ngữ học + an ninh mạng + tâm lý xã hội        | ✅          |
| 11  | Migrate JSON → Supabase `known_risks` (centralized blocklist)     | ✅          |
| 12  | Notifications inbox (chuông) + unread badge                       | ✅          |
| 13  | Reset toàn bộ dữ liệu + CRUD known_risks (Add / swipe-to-delete)  | ✅          |
| 14  | Buttons IncomingCallScreen thực sự add/remove blocklist           | ✅          |
| 15  | Shared `CallScreeningRoleProvider` (Home hero ↔ Bảo Vệ sync)      | ✅          |
| 16  | Production icon + release keystore + split-per-ABI APK            | ✅          |
| 17  | Tắt Auto Backup + permission INTERNET cho release build           | ✅          |
| 18  | Loading Gemini-style (sparkles orbit + sweep gradient ring)       | ✅          |

## Flow xử lý 1 lượt kiểm tra

```
        ┌─────────────────┐
input → │  LocalRiskSvc   │ → match? → trả ngay (cache 24h)
        │ (Supabase       │
        │  known_risks)   │
        └─────────────────┘
                ↓ no match
        ┌─────────────────┐
        │ RemoteRiskSvc   │ → consensus từ Supabase scam_checks
        │ (community DB)  │   (vote risk_level theo distinct device)
        └─────────────────┘
                ↓ no data
        ┌─────────────────┐
        │  Unknown result │ → CTA "Phân tích sâu bằng AI Gemini"
        │  + AI on-demand │   (user chủ động bấm)
        └─────────────────┘
                ↓ user nhấn AI
        ┌─────────────────┐
        │  GeminiService  │ → trả 3 axis: linguistic / cyber / social
        │  3-axis prompt  │   + psychological 0-100
        └─────────────────┘
```

## Cấu hình `.env`

```env
GEMINI_API_KEY=AIzaSy...
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=sb_publishable_... (hoặc legacy JWT eyJhbGc...)
```

Thiếu `GEMINI_API_KEY` → AI button không gọi được, fallback message giải thích.
Thiếu `SUPABASE_*` → blocklist offline rỗng (không còn fallback JSON).

## Setup Supabase

Chạy lần lượt 6 migration trong **Dashboard → SQL Editor**:

| File | Tác dụng |
|---|---|
| `0001_scam_checks.sql` | Table `scam_checks` per-device + RLS |
| `0002_normalized_input.sql` | Cột `normalized_input` + index |
| `0003_multi_axis_signals.sql` | 3 jsonb cols (linguistic / cyber / social) |
| `0004_content_target.sql` | Accept `target='content'` |
| `0005_known_risks.sql` | Table `known_risks` + RLS + seed 123 entries |
| `0006_known_risks_delete.sql` | Add anon delete policy cho known_risks |

Verify:
- **Table Editor → scam_checks** xuất hiện với 13 cột.
- **Table Editor → known_risks** có 123 rows (57 phone, 26 bank, 40 url).

```bash
# Verify cloud DB ready
URL=$(grep '^SUPABASE_URL=' .env | cut -d= -f2-)
KEY=$(grep '^SUPABASE_ANON_KEY=' .env | cut -d= -f2-)
curl -s -I -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
  -H "Prefer: count=exact" \
  "$URL/rest/v1/known_risks?select=count" | grep -i content-range
# Expected: content-range: 0-0/123
```

## Chạy & build

```bash
flutter pub get
flutter run                              # cần Android device hoặc emulator

# Release distribution
flutter build apk --release --split-per-abi
# → 3 file ~16-20 MB trong build/app/outputs/flutter-apk/

# Regen launcher icon sau khi đổi assets/icon/icon.png
flutter pub run flutter_launcher_icons
```

## Kiểm thử

```bash
flutter analyze            # phải sạch
flutter test               # phải pass
flutter build apk --debug  # verify Kotlin/native build
```

## Cấu trúc

```
lib/
├── main.dart                       # entry: load .env + Supabase.initialize
├── app.dart                        # MultiProvider + MaterialApp + MainShell
├── core/
│   ├── constants/                  # AppColors, ApiConfig (có hasSupabase)
│   └── theme/                      # AppTheme M3 + Public Sans/Inter
├── data/models/                    # RiskLevel, ScamCheckResult (3 signal lists)
├── services/
│   ├── gemini_service.dart         # Gemini Flash (3-axis prompt) — on-demand
│   ├── local_risk_service.dart     # Supabase known_risks + cache TTL 24h
│   ├── remote_risk_service.dart    # aggregate Supabase scam_checks
│   ├── history_service.dart        # remote upsert + local dedupe by id
│   ├── device_id_service.dart      # random UUID + reset()
│   ├── call_screening_service.dart # MethodChannel (10 methods)
│   └── data_reset_service.dart     # orchestrate clear-all
├── features/
│   ├── main_shell.dart             # bottom nav 4 tab + listener cuộc gọi đến
│   ├── home/                       # dashboard: hero + stats + tiles + activity + bell
│   ├── scam_check/                 # segmented control + provider
│   ├── result/                     # gauge + radar + 3 axis cards + AI CTA
│   ├── call_screening/             # status + sync + reset + 2 nav tile
│   │   ├── call_screening_screen.dart
│   │   └── call_screening_role_provider.dart  # shared ChangeNotifier
│   ├── incoming_call/              # full-screen warning + add/remove blocklist
│   ├── blocklist/                  # browser danh sách offline NATIVE
│   ├── known_risks/                # browse Supabase DB + FAB Thêm + swipe delete
│   ├── notifications/              # inbox cuộc gọi đã chặn (id native-*)
│   ├── content_analysis/           # free-text → AI flow
│   └── history/                    # 100 lượt gần nhất
└── shared/widgets/                 # RiskBadge, RiskGauge, ThreatRadarChart,
                                    # ScanningOverlay (Gemini-style), SkeletonBlock

android/app/src/main/kotlin/com/scamdetector/scam_detector/
├── MainActivity.kt                 # forward intent extras → Bridge
└── callscreening/
    ├── IncomingCallScreener.kt     # CallScreening + screening_events queue
    └── CallScreeningBridge.kt      # MethodChannel handler

android/app/src/main/res/xml/
└── data_extraction_rules.xml       # tắt cloud auto-backup + device transfer

android/
├── upload-keystore.jks             # release signing key (gitignored)
└── key.properties                  # signing creds (gitignored)

assets/icon/
├── icon.png                        # launcher source 1024×1024
└── icon_foreground.png             # adaptive foreground

dist/                               # APK phân phối (gitignored)
└── ScamGuard-v1.0.0-{arm64,arm32,x86_64}.apk

supabase/migrations/                # 0001-0006 SQL
```

## Cảnh báo cuộc gọi đến (Android)

1. Trang chủ → **Bật ngay** (hero) hoặc Tab **Bảo Vệ** → **Bật cảnh báo cuộc
   gọi**. Cả 2 surface chia sẻ `CallScreeningRoleProvider`.
2. Hệ thống xin role `ROLE_CALL_SCREENING` (API 29+) → user grant.
3. **Đồng bộ lại từ máy chủ** → fetch `known_risks` từ Supabase, push xuống
   native blocklist. Số lượng counter trong Bảo Vệ đọc trực tiếp từ native
   (single source of truth).
4. Khi có cuộc gọi đến từ số trong blocklist:
   - `IncomingCallScreener` chặn cuộc gọi (`scam_numbers`) hoặc cảnh báo
     (`suspicious_numbers`).
   - Notification `setFullScreenIntent` + `CATEGORY_CALL` → app tự bật
     full-screen `IncomingCallScreen`.
   - Buttons trên overlay:
     - **CHẶN & NGẮT MÁY** → add số vào scam set (auto-promote nếu suspicious).
     - **Tôi vẫn tin số này** → remove khỏi cả 2 set (per-device whitelist tạm).
   - Event được ghi vào queue native → drain vào history (xem được ở chuông
     trên Trang chủ + tab Lịch sử).
5. Nếu bỏ qua notification, mở app sau → bell icon hiện badge unread → tap
   xem trong **Notifications** inbox.

App **không gửi số ra ngoài tự động** — chỉ chủ động đồng bộ với cloud
`known_risks` (do user bấm). Auto Backup tắt → uninstall = wipe sạch state.

## Cơ sở dữ liệu lừa đảo

Tab Bảo Vệ → **Cơ sở dữ liệu lừa đảo** → 3 tab (Số ĐT / Tài khoản / Đường dẫn):

- **FAB "+ Thêm"**: form điền type / value / risk level / score (slider) /
  summary / lý do (mỗi dòng 1 ý). Upsert thẳng lên Supabase `known_risks`.
- **Vuốt sang trái 1 row**: confirm dialog → DELETE từ Supabase.
- Tap vào row → mở `ResultScreen` xem chi tiết (gauge + radar + 3 axis).

Mọi thay đổi tự refresh cache local → `LocalRiskService.lookup` lần sau dùng
data mới.

## Reset toàn bộ dữ liệu

Tab Bảo Vệ → **Reset toàn bộ dữ liệu app**. Confirm dialog có checkbox
"Xoá luôn lịch sử trên Supabase" (mặc định bật). Hành động:

- Native: clear `scam_numbers` / `suspicious_numbers` / `screening_events`.
- Local cache: clear `known_risks_cache_v1` + `scam_check_history_v1` +
  `notifications_last_seen_at_v1`.
- Optional remote: DELETE rows trong `scam_checks` filter theo `device_id`.
- Reset device_id → tạo mới ở lần check tiếp theo.

Counter Bảo Vệ về 0/0. Cần bấm **Đồng bộ lại từ máy chủ** để re-fetch.

## Phân phối APK

3 file release ký bằng keystore riêng (`android/upload-keystore.jks`):

| File | Size | Dùng cho |
|---|---|---|
| `ScamGuard-v1.0.0-arm64.apk` | ~19 MB | 99% điện thoại Android hiện tại |
| `ScamGuard-v1.0.0-arm32.apk` | ~16 MB | Điện thoại cũ chip 32-bit |
| `ScamGuard-v1.0.0-x86_64.apk` | ~20 MB | Emulator x86 |

Cài cho friends:

```bash
adb install -r dist/ScamGuard-v1.0.0-arm64.apk
# hoặc gửi file qua Zalo/Drive → user mở → Install anyway
```

⚠️ Play Protect sẽ cảnh báo "có thể gây rủi ro" do app yêu cầu
`BIND_SCREENING_SERVICE` + sideload outside Play Store. Workaround: bấm
**More details → Install anyway**. Để loại bỏ hoàn toàn cần đăng Play Store
Closed Testing ($25 phí 1-time).

## Design system "Sentinel Assurance"

UI dựa trên Stitch project "AI Scam Shield Mobile":

- **Primary**: `#1A237E` (Indigo 900 — deep security blue)
- **App icon background**: `#0B1D42` (navy đậm cho adaptive icon)
- **Surface**: `#F9F9F9` background, white surfaces
- **Status**: đỏ `#BA1A1A` (lừa đảo), cam `#E65100` (nghi ngờ), xanh `#1B5E20`
- **Typography**: Public Sans (semi-bold) cho headlines, Inter cho body/UI
- **Roundness**: 8–16px container, stadium-pill cho primary button
- **3 axis colors** (vertical accent bar): tím (ngôn ngữ), cyan (an ninh),
  hồng (tâm lý xã hội)
- **Icon app**: shield + magnifying glass + thief silhouette + warning triangle
  trên nền navy gradient.
- **Loading**: 3 sparkles orbit + sweep gradient ring + outer pulse aura
  (Gemini-style, không phải spinner).

## Việc còn để mở

- Auth (Supabase email/Google) → per-user RLS policies.
- Persistent user whitelist (hiện "Tôi vẫn tin số này" bị overwrite khi sync).
- Push notification (FCM) khi cộng đồng phát hiện scam mới.
- iOS: không hỗ trợ call screening (giới hạn nền tảng).
- Offline outbox cho check khi Supabase fail.
- Play Store Closed Testing để loại bỏ cảnh báo Play Protect.
