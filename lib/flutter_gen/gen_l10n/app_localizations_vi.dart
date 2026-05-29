// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Scam Guard';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navCheck => 'Kiểm tra';

  @override
  String get navHistory => 'Lịch sử';

  @override
  String get navProtect => 'Bảo vệ';

  @override
  String get tooltipNotifications => 'Thông báo';

  @override
  String get tooltipSettings => 'Cài đặt';

  @override
  String get tooltipCopy => 'Sao chép';

  @override
  String get tooltipRefresh => 'Tải lại từ máy chủ';

  @override
  String get tooltipDeleteAll => 'Xoá tất cả';

  @override
  String get tooltipResync => 'Đồng bộ lại từ máy chủ';

  @override
  String get homeControlCenter => 'Trung tâm điều khiển';

  @override
  String get homeRecentActivity => 'Hoạt động gần đây';

  @override
  String get homeNoActivity =>
      'Chưa có lượt kiểm tra nào. Hãy thử với một số điện thoại bất kỳ trong tab Kiểm tra.';

  @override
  String get homeCheckPhone => 'Kiểm tra số điện thoại';

  @override
  String get homeCheckPhoneSub => 'Đối chiếu danh sách lừa đảo + AI phân tích';

  @override
  String get homeCheckBank => 'Kiểm tra tài khoản ngân hàng';

  @override
  String get homeCheckBankSub => 'Kiểm tra số tài khoản trước khi chuyển tiền';

  @override
  String get homeCheckUrl => 'Phân tích đường dẫn';

  @override
  String get homeCheckUrlSub => 'Phát hiện URL phishing, giả mạo thương hiệu';

  @override
  String get homeCheckContent => 'Phân tích nội dung / tin nhắn';

  @override
  String get homeCheckContentSub =>
      'Dán SMS, email, mô tả cuộc gọi — AI phân tích đa góc nhìn';

  @override
  String get statChecked => 'Đã kiểm tra';

  @override
  String get statSafe => 'An toàn';

  @override
  String get statScam => 'Lừa đảo';

  @override
  String get heroTitle => 'Bảo vệ thời gian thực';

  @override
  String get heroSubtitleIos =>
      'iOS chỉ hỗ trợ kiểm tra thủ công — tính năng sàng lọc cuộc gọi cần Android.';

  @override
  String get heroSubtitleActive =>
      'AI đang đối chiếu mọi cuộc gọi đến với danh sách lừa đảo trên máy.';

  @override
  String get heroSubtitleInactive =>
      'Bật để Scam Detector tự chặn cuộc gọi từ số đã biết là lừa đảo.';

  @override
  String get heroStatusChecking => 'Đang kiểm tra…';

  @override
  String get heroStatusIos => 'Chỉ kiểm tra thủ công (iOS)';

  @override
  String get heroStatusActive => 'Đang hoạt động';

  @override
  String get heroStatusInactive => 'Chưa bật';

  @override
  String get heroEnableBtn => 'Bật ngay';

  @override
  String get heroEnabledSnack => 'Đã bật bảo vệ thời gian thực.';

  @override
  String get heroPermissionSnack =>
      'Bạn cần cấp quyền sàng lọc cuộc gọi để bật bảo vệ.';

  @override
  String get checkTitle => 'Scam Guard';

  @override
  String get checkVerifyTitle => 'Xác minh đối tượng';

  @override
  String get checkSubmitBtn => 'Kiểm tra ngay';

  @override
  String get checkAnalyzeBtn => 'Phân tích bằng AI';

  @override
  String get checkEmptyError => 'Vui lòng nhập thông tin cần kiểm tra.';

  @override
  String get checkValidationRequired => 'Vui lòng nhập thông tin';

  @override
  String get checkValidationPhone => 'Số điện thoại không hợp lệ';

  @override
  String get checkValidationBank => 'Số tài khoản không hợp lệ';

  @override
  String get checkValidationUrl => 'Đường dẫn không hợp lệ';

  @override
  String get checkValidationContentShort =>
      'Nội dung quá ngắn (tối thiểu 5 ký tự)';

  @override
  String get checkSubtitlePhone =>
      'Đối chiếu danh sách rủi ro toàn cầu và phân tích tâm lý lừa đảo theo thời gian thực.';

  @override
  String get checkSubtitleBank =>
      'Kiểm tra số tài khoản nhận tiền có nằm trong các vụ lừa đảo đã được báo cáo.';

  @override
  String get checkSubtitleUrl =>
      'Phân tích cấu trúc tên miền và dấu hiệu giả mạo thương hiệu.';

  @override
  String get checkSubtitleContent =>
      'Dán SMS, email hoặc mô tả tình huống — AI phân tích đa góc nhìn.';

  @override
  String get checkHintPhone => '+84 9XX XXX XXX';

  @override
  String get checkHintBank => 'VD: 1903 5762 8810';

  @override
  String get checkHintUrl => 'VD: vietcombank-online.xyz';

  @override
  String get checkHintContent =>
      'VD: \"Vietcombank thông báo tài khoản của quý khách bị khoá. Vui lòng truy cập http://vcb-xacminh.tk để xác minh trong 10 phút...\"';

  @override
  String get checkBankLabel => 'Ngân hàng';

  @override
  String get checkBankHint => 'Chọn ngân hàng của số tài khoản';

  @override
  String get checkBankHintOther => 'Nhập số tài khoản (6–30 chữ số)';

  @override
  String checkBankValidationRange(String bank, int min, int max) {
    return 'Số tài khoản $bank thường có $min–$max chữ số';
  }

  @override
  String get segPhone => 'Số ĐT';

  @override
  String get segBank => 'Tài khoản';

  @override
  String get segUrl => 'Đường dẫn';

  @override
  String get segContent => 'Nội dung';

  @override
  String get engineTitle => 'Hybrid Detection Engine';

  @override
  String get engineSubtitle => 'Local blocklist  •  Gemini Flash AI';

  @override
  String get historyTile => 'Lịch sử';

  @override
  String get historyTileSub => 'Xem các lượt đã kiểm tra';

  @override
  String get tipsTile => 'Mẹo bảo vệ';

  @override
  String get tipsTileSub => 'Không cung cấp OTP, mã PIN cho ai';

  @override
  String get reportTitle => 'Báo cáo lừa đảo';

  @override
  String get reportSubPhone =>
      'Giúp cộng đồng — báo cáo số điện thoại giả mạo hoặc lừa đảo.';

  @override
  String get reportSubBank =>
      'Giúp cộng đồng — báo cáo tài khoản ngân hàng giả mạo hoặc lừa đảo.';

  @override
  String get reportSubUrl =>
      'Giúp cộng đồng — báo cáo đường dẫn giả mạo hoặc lừa đảo.';

  @override
  String get reportBtn => 'Báo cáo';

  @override
  String get reportDialogTitle => 'Báo cáo lừa đảo';

  @override
  String get reportDialogLabelPhone => 'Nhập số điện thoại bạn muốn báo cáo:';

  @override
  String get reportDialogLabelBank => 'Nhập số tài khoản bạn muốn báo cáo:';

  @override
  String get reportDialogLabelUrl => 'Nhập đường dẫn bạn muốn báo cáo:';

  @override
  String get reportDialogDesc => 'Mô tả ngắn (tuỳ chọn):';

  @override
  String get reportDialogDescHint =>
      'VD: Giả danh ngân hàng yêu cầu chuyển tiền...';

  @override
  String get reportSuccess =>
      'Đã gửi báo cáo. Cảm ơn bạn đóng góp cho cộng đồng!';

  @override
  String get reportFail => 'Gửi báo cáo thất bại. Vui lòng thử lại.';

  @override
  String get cancel => 'Huỷ';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get send => 'Gửi báo cáo';

  @override
  String get resultTitle => 'Kết quả phân tích';

  @override
  String get resultCopied => 'Đã sao chép kết quả';

  @override
  String get resultShareReasons => 'Lý do:';

  @override
  String get resultWarningReasons => 'Lý do cảnh báo';

  @override
  String get resultMultiAxis => 'Phân tích đa góc nhìn';

  @override
  String get resultPsyVector => 'Phân tích vector tâm lý';

  @override
  String get resultRadarDesc =>
      'Mỗi trục là một thủ thuật tâm lý lừa đảo phổ biến (0–100). Diện tích càng lớn, mức độ thao túng càng cao.';

  @override
  String get resultOpenLink => 'Mở liên kết';

  @override
  String get resultGoHome => 'Về trang chủ';

  @override
  String get resultUrlWarning => 'Cảnh báo URL';

  @override
  String get resultWarnDialogTitle => 'Cảnh báo';

  @override
  String resultWarnDialogContent(String level) {
    return 'Liên kết này được đánh giá $level. Bạn có chắc muốn mở?';
  }

  @override
  String get resultWarnCancel => 'Huỷ';

  @override
  String get resultWarnOpen => 'Vẫn mở';

  @override
  String get resultOpenFail => 'Không mở được liên kết';

  @override
  String get aiCardTitle => 'Phân tích hành vi bằng AI';

  @override
  String get aiCardSubUnknown =>
      'Chưa có dữ liệu offline / cộng đồng. Để Gemini phân tích kịch bản, dấu hiệu thao túng và các yếu tố tâm lý.';

  @override
  String get aiCardSubKnown =>
      'Bổ sung phân tích hành vi (urgency / fear / authority / greed) và lý do chi tiết từ AI.';

  @override
  String get aiCtaUnknown => 'Phân tích sâu bằng AI Gemini';

  @override
  String get aiCtaKnown => 'Phân tích hành vi bằng AI';

  @override
  String get aiCtaRedo => 'Phân tích lại bằng AI';

  @override
  String get aiAnalyzing => 'Đang phân tích…';

  @override
  String get aiOverlayMsg => 'Gemini đang phân tích hành vi…';

  @override
  String get axisLinguistic => 'Ngôn ngữ học';

  @override
  String get axisLinguisticSub => 'Dấu hiệu trong cách diễn đạt / từ vựng';

  @override
  String get axisCyber => 'An ninh mạng';

  @override
  String get axisCyberSub => 'Dấu hiệu kỹ thuật / hạ tầng';

  @override
  String get axisSocial => 'Tâm lý học xã hội';

  @override
  String get axisSocialSub =>
      'Thủ thuật thuyết phục (Cialdini & thao túng cảm xúc)';

  @override
  String get securityProtocolTitle => 'Cần áp dụng quy trình bảo vệ';

  @override
  String get securityProtocolBody =>
      'Không cung cấp OTP, mã PIN, mật khẩu cho bất kỳ ai. Báo cáo cho ngân hàng / cơ quan chức năng nếu đã chuyển tiền.';

  @override
  String get riskSafe => 'An toàn';

  @override
  String get riskSuspicious => 'Nghi ngờ';

  @override
  String get riskScam => 'Lừa đảo';

  @override
  String get riskUnknown => 'Chưa xác định';

  @override
  String get targetPhone => 'Số điện thoại';

  @override
  String get targetBank => 'Tài khoản ngân hàng';

  @override
  String get targetUrl => 'Đường dẫn';

  @override
  String get targetContent => 'Nội dung';

  @override
  String get historyScreenTitle => 'Lịch sử kiểm tra';

  @override
  String get historyEmpty => 'Chưa có lượt kiểm tra nào';

  @override
  String get historyDeleteAllConfirmTitle => 'Xoá toàn bộ lịch sử?';

  @override
  String get historyDeleteAllConfirmBody => 'Hành động này không thể hoàn tác.';

  @override
  String get historyDeleteBtn => 'Xoá';

  @override
  String get notifTitle => 'Thông báo';

  @override
  String get notifEmpty =>
      'Chưa có cuộc gọi nào được CallScreening xử lý.\nKhi có số trong danh sách lừa đảo gọi tới, bạn sẽ thấy ở đây.';

  @override
  String get notifCallBlocked => 'Đã chặn cuộc gọi';

  @override
  String get notifCallSuspicious => 'Cuộc gọi nghi ngờ';

  @override
  String get callScreenTitle => 'Cảnh báo cuộc gọi';

  @override
  String get callScreenOfflineList => 'Danh sách cảnh báo offline';

  @override
  String get callScreenScamCount => 'Số lừa đảo';

  @override
  String get callScreenSuspiciousCount => 'Số nghi ngờ';

  @override
  String get callScreenResync => 'Đồng bộ lại từ máy chủ';

  @override
  String get callScreenEnableBtn => 'Bật cảnh báo cuộc gọi';

  @override
  String get callScreenEnabledSnack => 'Đã bật cảnh báo cuộc gọi.';

  @override
  String get callScreenPermissionSnack =>
      'Bạn cần cấp quyền sàng lọc cuộc gọi để dùng tính năng.';

  @override
  String callScreenResyncSnack(int count, int scam, int suspicious) {
    return 'Đã tải $count mục từ máy chủ • $scam chặn / $suspicious cảnh báo.';
  }

  @override
  String callScreenResyncFail(String error, int scam, int suspicious) {
    return '$error (đang dùng cache: $scam + $suspicious).';
  }

  @override
  String get callScreenNoServer => 'Không thể kết nối máy chủ';

  @override
  String get callStatusAndroidOnly => 'Tính năng chỉ khả dụng trên Android';

  @override
  String get callStatusAndroidOnlyBody =>
      'CallScreeningService là API riêng của Android (10+). Trên iOS chỉ có thể dùng tab Kiểm tra thủ công.';

  @override
  String get callStatusActive => 'Đang bật cảnh báo cuộc gọi';

  @override
  String get callStatusActiveBody =>
      'Mọi cuộc gọi đến sẽ được đối chiếu với danh sách lừa đảo trên máy. Cuộc gọi lừa đảo sẽ bị từ chối, cuộc gọi nghi ngờ sẽ kèm thông báo cảnh báo.';

  @override
  String get callStatusInactive => 'Chưa bật cảnh báo cuộc gọi';

  @override
  String get callStatusInactiveBody =>
      'Bấm \"Bật cảnh báo cuộc gọi\" và chọn Scam Detector trong hộp thoại của hệ thống để cấp quyền sàng lọc.';

  @override
  String get callScreenNote =>
      'Cảnh báo cuộc gọi sử dụng dữ liệu offline trong app, không gửi số điện thoại của bạn ra ngoài. Yêu cầu Android 10 trở lên.';

  @override
  String get navTileBlocklist => 'Danh sách offline đang chặn';

  @override
  String get navTileBlocklistSub =>
      'Xem các số điện thoại CallScreening đang giám sát ngay trên máy.';

  @override
  String get navTileKnownRisks => 'Cơ sở dữ liệu lừa đảo';

  @override
  String get navTileKnownRisksSub =>
      'Duyệt / thêm / xoá số ĐT, tài khoản và đường dẫn rủi ro trên Supabase.';

  @override
  String get navTileReset => 'Reset toàn bộ dữ liệu app';

  @override
  String get navTileResetSub =>
      'Xoá lịch sử, blocklist offline, cache và device id. Bắt đầu lại từ trạng thái sạch.';

  @override
  String get navTileSentry => 'Gửi sự kiện test tới Sentry';

  @override
  String get navTileSentrySub =>
      'Bắn 1 message + 1 exception để xác nhận crash reporting đang hoạt động.';

  @override
  String get sentrySnack =>
      'Đã gửi test event lên Sentry. Vào dashboard sentry.io để xác nhận.';

  @override
  String get resetDialogTitle => 'Reset toàn bộ dữ liệu app?';

  @override
  String get resetDialogBody =>
      'Mọi lịch sử kiểm tra, danh sách offline, cache và device id sẽ bị xoá. Hành động này không thể hoàn tác.';

  @override
  String get resetDialogRemoteCheck => 'Xoá luôn lịch sử trên Supabase';

  @override
  String get resetDialogRemoteCheckSub =>
      'Bỏ chọn nếu chỉ muốn xoá local, giữ lịch sử trên cloud.';

  @override
  String get resetBtn => 'Reset';

  @override
  String get resetDoneSnack => 'Đã reset toàn bộ dữ liệu app.';

  @override
  String get blocklistTitle => 'Danh sách offline đang chặn';

  @override
  String blocklistSummary(int total) {
    return '$total số đang được giám sát';
  }

  @override
  String blocklistSummarySub(int scam, int suspicious) {
    return '$scam số sẽ bị chặn, $suspicious số sẽ kèm cảnh báo.';
  }

  @override
  String get blocklistSectionScam => 'Số sẽ bị chặn (lừa đảo)';

  @override
  String get blocklistSectionSuspicious => 'Số sẽ kèm cảnh báo (nghi ngờ)';

  @override
  String get blocklistEmpty =>
      'Chưa có số nào trong danh sách offline. Bấm nút đồng bộ ở góc phải để tải về từ máy chủ.';

  @override
  String get blocklistSectionEmpty => 'Chưa có số nào ở mức này.';

  @override
  String get blocklistNote =>
      'Đây là danh sách số điện thoại đã được tải xuống máy. CallScreeningService chạy hoàn toàn offline — không gửi số ra ngoài.';

  @override
  String blocklistResyncSnack(int scam, int suspicious) {
    return 'Đã đồng bộ $scam số lừa đảo, $suspicious số nghi ngờ.';
  }

  @override
  String get knownRisksTitle => 'Cơ sở dữ liệu lừa đảo';

  @override
  String knownRisksTabPhone(int count) {
    return 'Số ĐT ($count)';
  }

  @override
  String knownRisksTabBank(int count) {
    return 'Tài khoản ($count)';
  }

  @override
  String knownRisksTabUrl(int count) {
    return 'Đường dẫn ($count)';
  }

  @override
  String get knownRisksEmpty =>
      'Chưa có dữ liệu cho danh mục này.\nKiểm tra kết nối Supabase rồi bấm tải lại.';

  @override
  String get knownRisksAddBtn => 'Thêm';

  @override
  String get knownRisksAddedSnack => 'Đã thêm vào cơ sở dữ liệu.';

  @override
  String get knownRisksDeleteTitle => 'Xoá khỏi cơ sở dữ liệu?';

  @override
  String knownRisksDeleteBody(String value) {
    return '$value sẽ bị xoá khỏi Supabase. Mọi thiết bị khác cũng sẽ không nhận được entry này khi đồng bộ.';
  }

  @override
  String knownRisksDeletedSnack(String value) {
    return 'Đã xoá $value.';
  }

  @override
  String knownRisksDeleteFail(String error) {
    return 'Không xoá được: $error';
  }

  @override
  String get knownRisksSwipeDelete => 'Xoá';

  @override
  String get addDialogTitle => 'Thêm vào cơ sở dữ liệu';

  @override
  String get addDialogType => 'Loại';

  @override
  String get addDialogTypePhone => 'Số điện thoại';

  @override
  String get addDialogTypeBank => 'Tài khoản NH';

  @override
  String get addDialogTypeUrl => 'Đường dẫn';

  @override
  String get addDialogBank => 'Ngân hàng';

  @override
  String get addDialogValue => 'Giá trị';

  @override
  String get addDialogValueHint => 'VD: 0888888888 / vietcombank-online.xyz';

  @override
  String get addDialogRisk => 'Mức rủi ro';

  @override
  String get addDialogRiskScam => 'Lừa đảo (scam)';

  @override
  String get addDialogRiskSuspicious => 'Nghi ngờ (suspicious)';

  @override
  String get addDialogRiskSafe => 'An toàn (safe)';

  @override
  String get addDialogSummary => 'Tóm tắt (1 câu)';

  @override
  String get addDialogReasons => 'Lý do (mỗi dòng 1 ý)';

  @override
  String get addDialogSave => 'Lưu';

  @override
  String get addDialogSaveFail => 'Lưu thất bại.';

  @override
  String get contentTitle => 'Phân tích nội dung';

  @override
  String get contentHeadline => 'Phân tích bằng AI đa góc nhìn';

  @override
  String get contentSubtitle =>
      'Dán tin nhắn, mô tả cuộc gọi hoặc đính kèm ảnh / video. Gemini đọc cả OCR trong ảnh + nội dung video để phân tích theo 3 góc: ngôn ngữ học, an ninh mạng và tâm lý xã hội.';

  @override
  String get contentHint =>
      'VD: \"Vietcombank xin chào quý khách, tài khoản của quý khách phát sinh giao dịch lạ...\"';

  @override
  String get contentPasteTooltip => 'Dán từ clipboard';

  @override
  String get contentClipboardEmpty => 'Clipboard rỗng';

  @override
  String get contentAnalyzeBtn => 'Phân tích bằng AI';

  @override
  String get contentEmptyError =>
      'Nhập text hoặc đính kèm ảnh / video để AI phân tích.';

  @override
  String get contentTextTooShort =>
      'Text quá ngắn (tối thiểu 5 ký tự) hoặc kèm thêm ảnh.';

  @override
  String get contentOverlayText => 'Gemini đang phân tích nội dung…';

  @override
  String get contentOverlayMedia => 'Gemini đang đọc ảnh / video + phân tích…';

  @override
  String get attachLabel => 'Đính kèm ảnh / video (tuỳ chọn)';

  @override
  String attachLabelCount(int count, String size, String max) {
    return 'Đã đính kèm $count ($size / $max)';
  }

  @override
  String get attachGallery => 'Thư viện';

  @override
  String get attachCamera => 'Chụp ảnh';

  @override
  String get attachVideo => 'Video';

  @override
  String attachMaxImages(int max) {
    return 'Tối đa $max ảnh / lần phân tích.';
  }

  @override
  String get attachMaxVideo => 'Đã có 1 video — chỉ phân tích 1 video / lần.';

  @override
  String get attachSizeExceeded =>
      'Vượt quá tổng dung lượng cho phép (~18 MB). Hãy chọn file nhỏ hơn hoặc bớt media.';

  @override
  String attachPickImageFail(String error) {
    return 'Không chọn được ảnh: $error';
  }

  @override
  String attachPickVideoFail(String error) {
    return 'Không chọn được video: $error';
  }

  @override
  String get exampleSectionLabel => 'Hoặc thử với mẫu có sẵn';

  @override
  String get exampleBankTitle => 'Mạo danh ngân hàng';

  @override
  String get exampleBankBody =>
      'Vietcombank thông báo: tài khoản của quý khách bị khoá do nghi ngờ gian lận. Vui lòng nhấn link sau để xác minh: http://vcb-online-secure.xyz/login. Nếu không xác minh trong 30 phút, mọi giao dịch sẽ bị huỷ.';

  @override
  String get exampleShopeeTitle => 'CTV Shopee lãi cao';

  @override
  String get exampleShopeeBody =>
      'Em chào anh/chị, em là tuyển dụng CTV Shopee. Anh/chị chỉ cần đặt đơn ảo, công ty hoàn lại tiền và cộng thêm 15% hoa hồng. Một ngày dễ kiếm 500-800k. Anh/chị quan tâm em gửi link nhóm Telegram.';

  @override
  String get examplePoliceTitle => 'Giả công an';

  @override
  String get examplePoliceBody =>
      'Đồng chí, đây là Đại uý Nguyễn Văn A — Phòng Cảnh sát Hình sự. Tài khoản của đồng chí có liên quan đường dây ma tuý xuyên quốc gia. Đồng chí phải chuyển toàn bộ tiền vào tài khoản tạm giữ của Bộ Công an để phục vụ điều tra trong 1 tiếng.';

  @override
  String get incomingSecurityWarning => 'Cảnh báo bảo mật';

  @override
  String get incomingScamDetected => 'AI PHÁT HIỆN MẪU LỪA ĐẢO';

  @override
  String get incomingSuspiciousDetected => 'CẦN THẬN — DẤU HIỆU NGHI NGỜ';

  @override
  String get incomingCallLabel => 'CUỘC GỌI ĐẾN';

  @override
  String get incomingCopyTooltip => 'Sao chép số';

  @override
  String get incomingCopied => 'Đã sao chép';

  @override
  String get incomingRiskAnalysis => 'PHÂN TÍCH NGUY CƠ';

  @override
  String get incomingConfidence => 'NIỀM TIN';

  @override
  String get incomingBlockBtn => 'CHẶN & NGẮT MÁY';

  @override
  String get incomingWarnBtn => 'GHI NHẬN CẢNH BÁO';

  @override
  String get incomingTrustBtn => 'Tôi vẫn tin số này';

  @override
  String get incomingProtectedBy => 'Bảo vệ chủ động bởi Scam Detector';

  @override
  String incomingBlockedSnack(String number) {
    return 'Đã thêm $number vào danh sách chặn lừa đảo.';
  }

  @override
  String incomingRemovedSnack(String number) {
    return 'Đã gỡ $number khỏi danh sách chặn.';
  }

  @override
  String incomingNotInListSnack(String number) {
    return '$number không có trong danh sách offline.';
  }

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsAppearance => 'Giao diện';

  @override
  String get settingsLight => 'Sáng';

  @override
  String get settingsDark => 'Tối';

  @override
  String get settingsSystem => 'Theo hệ thống';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsLanguageVi => 'Tiếng Việt';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsBehavior => 'Điều hướng';

  @override
  String get settingsPreventMinimize => 'Ngăn thu nhỏ khi bấm Back';

  @override
  String get settingsPreventMinimizeDesc =>
      'Bấm Back sẽ quay màn trước thay vì thoát app.';

  @override
  String get settingsAbout => 'Về ứng dụng';

  @override
  String get settingsAppName => 'Scam Guard';

  @override
  String get settingsDataReset => 'Reset toàn bộ dữ liệu';

  @override
  String get settingsResetDialogBody =>
      'Hành động này sẽ xoá toàn bộ dữ liệu trên máy, bao gồm lịch sử, danh sách chặn và cài đặt. Tiếp tục?';

  @override
  String get settingsResetComingSoon => 'Tính năng này sẽ được bổ sung sau.';

  @override
  String get checkEmptyInputError => 'Vui lòng nhập thông tin cần kiểm tra.';

  @override
  String get screenedCallBlockedSummary =>
      'Cuộc gọi bị chặn tự động vì khớp danh sách lừa đảo.';

  @override
  String get screenedCallWarnedSummary =>
      'Cuộc gọi nghi ngờ — đã được cảnh báo nhưng không chặn.';

  @override
  String screenedCallBlockedReason(String number) {
    return 'CallScreeningService đã chặn cuộc gọi từ $number.';
  }

  @override
  String screenedCallWarnedReason(String number) {
    return 'CallScreeningService cảnh báo cuộc gọi từ $number.';
  }

  @override
  String get screenedCallOfflineReason =>
      'Số khớp danh sách offline được đồng bộ từ Scam Detector.';

  @override
  String incomingCallSummary(String label) {
    return 'Cuộc gọi từ số có dấu hiệu $label. Hãy thận trọng nếu bắt máy.';
  }

  @override
  String get incomingCallScreenedReason =>
      'CallScreeningService phát hiện trùng danh sách offline.';

  @override
  String checkBankDigits(int count) {
    return '$count chữ số';
  }

  @override
  String checkBankDigitRange(int min, int max) {
    return '$min–$max chữ số';
  }

  @override
  String checkBankHintWithRange(Object bank, Object range) {
    return 'VD: $bank — $range';
  }

  @override
  String get riskScoreLabel => 'ĐIỂM RỦI RO';

  @override
  String get radarPressure => 'Áp lực';

  @override
  String get radarAuthority => 'Quyền lực';

  @override
  String get radarGreed => 'Lợi ích';

  @override
  String get radarFear => 'Sợ hãi';

  @override
  String get scanningDefaultMessage => 'Đang phân tích bằng AI…';

  @override
  String get scanningSubtitle =>
      'Gemini đang phân tích đa góc nhìn — 2–5 giây.';
}
