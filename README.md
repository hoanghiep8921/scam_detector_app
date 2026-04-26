# Scam Detector

Ứng dụng Flutter phát hiện lừa đảo đa kênh: số điện thoại, tài khoản ngân hàng, đường dẫn website. Tích hợp Gemini Flash để phân tích hành vi/tâm lý lừa đảo và đưa ra giải thích cho người dùng.

## Trạng thái

- **Giai đoạn 1 — Setup**: ✅ project, theme, navigation, providers
- **Giai đoạn 2 — Kiểm tra số điện thoại**: ✅ kèm tài khoản & URL (3 target dùng chung 1 flow)
- **Giai đoạn 3 — Multi-input**: ✅ (đã gộp vào pha 2)
- **Giai đoạn 4 — AI Integration (Gemini Flash)**: ✅ với prompt JSON
- **Giai đoạn 5 — CallScreeningService (Android)**: ⏳ chưa làm
- **Giai đoạn 6 — Polish & demo**: ⏳ chưa làm

## Cấu hình

1. Sao chép `.env.example` thành `.env`
2. Điền `GEMINI_API_KEY=...` (key Gemini Flash)

Nếu chưa có key, app vẫn chạy ở **chế độ stub** (kết quả mẫu giải thích cách cấu hình).

## Chạy app

```bash
flutter pub get
flutter run               # cần thiết bị Android/iOS hoặc emulator
```

## Kiểm thử

```bash
flutter analyze
flutter test
```

## Cấu trúc

```
lib/
├── main.dart                 # entry, load .env
├── app.dart                  # MultiProvider + MaterialApp
├── core/
│   ├── constants/            # AppColors, ApiConfig
│   └── theme/                # AppTheme (M3 light)
├── data/models/              # RiskLevel, ScamCheckResult, PsychologicalFactors
├── services/
│   ├── gemini_service.dart   # Gemini Flash + JSON parsing
│   └── history_service.dart  # SharedPreferences-backed history
├── features/
│   ├── home/                 # 3 tile vào từng loại check
│   ├── scam_check/           # form input + provider
│   ├── result/               # explainable AI + factor bars
│   └── history/              # 100 lượt gần nhất
└── shared/widgets/           # RiskBadge, FactorBar
```

## Việc còn lại

- **CallScreeningService** (Kotlin) cho cảnh báo cuộc gọi đến — yêu cầu thay đổi `android/app/src/main/AndroidManifest.xml` + lớp Kotlin native + MethodChannel.
- Nguồn dữ liệu rủi ro local (CSV/SQLite) để giảm gọi API cho số đã biết.
- Animation trang loading + skeleton UI cho UX mượt hơn.
