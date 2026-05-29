import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'Scam Guard'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get navHome;

  /// No description provided for @navCheck.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra'**
  String get navCheck;

  /// No description provided for @navHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get navHistory;

  /// No description provided for @navProtect.
  ///
  /// In vi, this message translates to:
  /// **'Bảo vệ'**
  String get navProtect;

  /// No description provided for @tooltipNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get tooltipNotifications;

  /// No description provided for @tooltipSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get tooltipSettings;

  /// No description provided for @tooltipCopy.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép'**
  String get tooltipCopy;

  /// No description provided for @tooltipRefresh.
  ///
  /// In vi, this message translates to:
  /// **'Tải lại từ máy chủ'**
  String get tooltipRefresh;

  /// No description provided for @tooltipDeleteAll.
  ///
  /// In vi, this message translates to:
  /// **'Xoá tất cả'**
  String get tooltipDeleteAll;

  /// No description provided for @tooltipResync.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ lại từ máy chủ'**
  String get tooltipResync;

  /// No description provided for @homeControlCenter.
  ///
  /// In vi, this message translates to:
  /// **'Trung tâm điều khiển'**
  String get homeControlCenter;

  /// No description provided for @homeRecentActivity.
  ///
  /// In vi, this message translates to:
  /// **'Hoạt động gần đây'**
  String get homeRecentActivity;

  /// No description provided for @homeNoActivity.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lượt kiểm tra nào. Hãy thử với một số điện thoại bất kỳ trong tab Kiểm tra.'**
  String get homeNoActivity;

  /// No description provided for @homeCheckPhone.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra số điện thoại'**
  String get homeCheckPhone;

  /// No description provided for @homeCheckPhoneSub.
  ///
  /// In vi, this message translates to:
  /// **'Đối chiếu danh sách lừa đảo + AI phân tích'**
  String get homeCheckPhoneSub;

  /// No description provided for @homeCheckBank.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra tài khoản ngân hàng'**
  String get homeCheckBank;

  /// No description provided for @homeCheckBankSub.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra số tài khoản trước khi chuyển tiền'**
  String get homeCheckBankSub;

  /// No description provided for @homeCheckUrl.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích đường dẫn'**
  String get homeCheckUrl;

  /// No description provided for @homeCheckUrlSub.
  ///
  /// In vi, this message translates to:
  /// **'Phát hiện URL phishing, giả mạo thương hiệu'**
  String get homeCheckUrlSub;

  /// No description provided for @homeCheckContent.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích nội dung / tin nhắn'**
  String get homeCheckContent;

  /// No description provided for @homeCheckContentSub.
  ///
  /// In vi, this message translates to:
  /// **'Dán SMS, email, mô tả cuộc gọi — AI phân tích đa góc nhìn'**
  String get homeCheckContentSub;

  /// No description provided for @statChecked.
  ///
  /// In vi, this message translates to:
  /// **'Đã kiểm tra'**
  String get statChecked;

  /// No description provided for @statSafe.
  ///
  /// In vi, this message translates to:
  /// **'An toàn'**
  String get statSafe;

  /// No description provided for @statScam.
  ///
  /// In vi, this message translates to:
  /// **'Lừa đảo'**
  String get statScam;

  /// No description provided for @heroTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bảo vệ thời gian thực'**
  String get heroTitle;

  /// No description provided for @heroSubtitleIos.
  ///
  /// In vi, this message translates to:
  /// **'iOS chỉ hỗ trợ kiểm tra thủ công — tính năng sàng lọc cuộc gọi cần Android.'**
  String get heroSubtitleIos;

  /// No description provided for @heroSubtitleActive.
  ///
  /// In vi, this message translates to:
  /// **'AI đang đối chiếu mọi cuộc gọi đến với danh sách lừa đảo trên máy.'**
  String get heroSubtitleActive;

  /// No description provided for @heroSubtitleInactive.
  ///
  /// In vi, this message translates to:
  /// **'Bật để Scam Detector tự chặn cuộc gọi từ số đã biết là lừa đảo.'**
  String get heroSubtitleInactive;

  /// No description provided for @heroStatusChecking.
  ///
  /// In vi, this message translates to:
  /// **'Đang kiểm tra…'**
  String get heroStatusChecking;

  /// No description provided for @heroStatusIos.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ kiểm tra thủ công (iOS)'**
  String get heroStatusIos;

  /// No description provided for @heroStatusActive.
  ///
  /// In vi, this message translates to:
  /// **'Đang hoạt động'**
  String get heroStatusActive;

  /// No description provided for @heroStatusInactive.
  ///
  /// In vi, this message translates to:
  /// **'Chưa bật'**
  String get heroStatusInactive;

  /// No description provided for @heroEnableBtn.
  ///
  /// In vi, this message translates to:
  /// **'Bật ngay'**
  String get heroEnableBtn;

  /// No description provided for @heroEnabledSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã bật bảo vệ thời gian thực.'**
  String get heroEnabledSnack;

  /// No description provided for @heroPermissionSnack.
  ///
  /// In vi, this message translates to:
  /// **'Bạn cần cấp quyền sàng lọc cuộc gọi để bật bảo vệ.'**
  String get heroPermissionSnack;

  /// No description provided for @checkTitle.
  ///
  /// In vi, this message translates to:
  /// **'Scam Guard'**
  String get checkTitle;

  /// No description provided for @checkVerifyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác minh đối tượng'**
  String get checkVerifyTitle;

  /// No description provided for @checkSubmitBtn.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra ngay'**
  String get checkSubmitBtn;

  /// No description provided for @checkAnalyzeBtn.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích bằng AI'**
  String get checkAnalyzeBtn;

  /// No description provided for @checkEmptyError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập thông tin cần kiểm tra.'**
  String get checkEmptyError;

  /// No description provided for @checkValidationRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập thông tin'**
  String get checkValidationRequired;

  /// No description provided for @checkValidationPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại không hợp lệ'**
  String get checkValidationPhone;

  /// No description provided for @checkValidationBank.
  ///
  /// In vi, this message translates to:
  /// **'Số tài khoản không hợp lệ'**
  String get checkValidationBank;

  /// No description provided for @checkValidationUrl.
  ///
  /// In vi, this message translates to:
  /// **'Đường dẫn không hợp lệ'**
  String get checkValidationUrl;

  /// No description provided for @checkValidationContentShort.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung quá ngắn (tối thiểu 5 ký tự)'**
  String get checkValidationContentShort;

  /// No description provided for @checkSubtitlePhone.
  ///
  /// In vi, this message translates to:
  /// **'Đối chiếu danh sách rủi ro toàn cầu và phân tích tâm lý lừa đảo theo thời gian thực.'**
  String get checkSubtitlePhone;

  /// No description provided for @checkSubtitleBank.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra số tài khoản nhận tiền có nằm trong các vụ lừa đảo đã được báo cáo.'**
  String get checkSubtitleBank;

  /// No description provided for @checkSubtitleUrl.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích cấu trúc tên miền và dấu hiệu giả mạo thương hiệu.'**
  String get checkSubtitleUrl;

  /// No description provided for @checkSubtitleContent.
  ///
  /// In vi, this message translates to:
  /// **'Dán SMS, email hoặc mô tả tình huống — AI phân tích đa góc nhìn.'**
  String get checkSubtitleContent;

  /// No description provided for @checkHintPhone.
  ///
  /// In vi, this message translates to:
  /// **'+84 9XX XXX XXX'**
  String get checkHintPhone;

  /// No description provided for @checkHintBank.
  ///
  /// In vi, this message translates to:
  /// **'VD: 1903 5762 8810'**
  String get checkHintBank;

  /// No description provided for @checkHintUrl.
  ///
  /// In vi, this message translates to:
  /// **'VD: vietcombank-online.xyz'**
  String get checkHintUrl;

  /// No description provided for @checkHintContent.
  ///
  /// In vi, this message translates to:
  /// **'VD: \"Vietcombank thông báo tài khoản của quý khách bị khoá. Vui lòng truy cập http://vcb-xacminh.tk để xác minh trong 10 phút...\"'**
  String get checkHintContent;

  /// No description provided for @checkBankLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngân hàng'**
  String get checkBankLabel;

  /// No description provided for @checkBankHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngân hàng của số tài khoản'**
  String get checkBankHint;

  /// No description provided for @checkBankHintOther.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tài khoản (6–30 chữ số)'**
  String get checkBankHintOther;

  /// No description provided for @checkBankValidationRange.
  ///
  /// In vi, this message translates to:
  /// **'Số tài khoản {bank} thường có {min}–{max} chữ số'**
  String checkBankValidationRange(String bank, int min, int max);

  /// No description provided for @segPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số ĐT'**
  String get segPhone;

  /// No description provided for @segBank.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get segBank;

  /// No description provided for @segUrl.
  ///
  /// In vi, this message translates to:
  /// **'Đường dẫn'**
  String get segUrl;

  /// No description provided for @segContent.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung'**
  String get segContent;

  /// No description provided for @engineTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hybrid Detection Engine'**
  String get engineTitle;

  /// No description provided for @engineSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Local blocklist  •  Gemini Flash AI'**
  String get engineSubtitle;

  /// No description provided for @historyTile.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get historyTile;

  /// No description provided for @historyTileSub.
  ///
  /// In vi, this message translates to:
  /// **'Xem các lượt đã kiểm tra'**
  String get historyTileSub;

  /// No description provided for @tipsTile.
  ///
  /// In vi, this message translates to:
  /// **'Mẹo bảo vệ'**
  String get tipsTile;

  /// No description provided for @tipsTileSub.
  ///
  /// In vi, this message translates to:
  /// **'Không cung cấp OTP, mã PIN cho ai'**
  String get tipsTileSub;

  /// No description provided for @reportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo lừa đảo'**
  String get reportTitle;

  /// No description provided for @reportSubPhone.
  ///
  /// In vi, this message translates to:
  /// **'Giúp cộng đồng — báo cáo số điện thoại giả mạo hoặc lừa đảo.'**
  String get reportSubPhone;

  /// No description provided for @reportSubBank.
  ///
  /// In vi, this message translates to:
  /// **'Giúp cộng đồng — báo cáo tài khoản ngân hàng giả mạo hoặc lừa đảo.'**
  String get reportSubBank;

  /// No description provided for @reportSubUrl.
  ///
  /// In vi, this message translates to:
  /// **'Giúp cộng đồng — báo cáo đường dẫn giả mạo hoặc lừa đảo.'**
  String get reportSubUrl;

  /// No description provided for @reportBtn.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get reportBtn;

  /// No description provided for @reportDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo lừa đảo'**
  String get reportDialogTitle;

  /// No description provided for @reportDialogLabelPhone.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số điện thoại bạn muốn báo cáo:'**
  String get reportDialogLabelPhone;

  /// No description provided for @reportDialogLabelBank.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tài khoản bạn muốn báo cáo:'**
  String get reportDialogLabelBank;

  /// No description provided for @reportDialogLabelUrl.
  ///
  /// In vi, this message translates to:
  /// **'Nhập đường dẫn bạn muốn báo cáo:'**
  String get reportDialogLabelUrl;

  /// No description provided for @reportDialogDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả ngắn (tuỳ chọn):'**
  String get reportDialogDesc;

  /// No description provided for @reportDialogDescHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Giả danh ngân hàng yêu cầu chuyển tiền...'**
  String get reportDialogDescHint;

  /// No description provided for @reportSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi báo cáo. Cảm ơn bạn đóng góp cho cộng đồng!'**
  String get reportSuccess;

  /// No description provided for @reportFail.
  ///
  /// In vi, this message translates to:
  /// **'Gửi báo cáo thất bại. Vui lòng thử lại.'**
  String get reportFail;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Huỷ'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @send.
  ///
  /// In vi, this message translates to:
  /// **'Gửi báo cáo'**
  String get send;

  /// No description provided for @resultTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả phân tích'**
  String get resultTitle;

  /// No description provided for @resultCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép kết quả'**
  String get resultCopied;

  /// No description provided for @resultShareReasons.
  ///
  /// In vi, this message translates to:
  /// **'Lý do:'**
  String get resultShareReasons;

  /// No description provided for @resultWarningReasons.
  ///
  /// In vi, this message translates to:
  /// **'Lý do cảnh báo'**
  String get resultWarningReasons;

  /// No description provided for @resultMultiAxis.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích đa góc nhìn'**
  String get resultMultiAxis;

  /// No description provided for @resultPsyVector.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích vector tâm lý'**
  String get resultPsyVector;

  /// No description provided for @resultRadarDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi trục là một thủ thuật tâm lý lừa đảo phổ biến (0–100). Diện tích càng lớn, mức độ thao túng càng cao.'**
  String get resultRadarDesc;

  /// No description provided for @resultOpenLink.
  ///
  /// In vi, this message translates to:
  /// **'Mở liên kết'**
  String get resultOpenLink;

  /// No description provided for @resultGoHome.
  ///
  /// In vi, this message translates to:
  /// **'Về trang chủ'**
  String get resultGoHome;

  /// No description provided for @resultUrlWarning.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo URL'**
  String get resultUrlWarning;

  /// No description provided for @resultWarnDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo'**
  String get resultWarnDialogTitle;

  /// No description provided for @resultWarnDialogContent.
  ///
  /// In vi, this message translates to:
  /// **'Liên kết này được đánh giá {level}. Bạn có chắc muốn mở?'**
  String resultWarnDialogContent(String level);

  /// No description provided for @resultWarnCancel.
  ///
  /// In vi, this message translates to:
  /// **'Huỷ'**
  String get resultWarnCancel;

  /// No description provided for @resultWarnOpen.
  ///
  /// In vi, this message translates to:
  /// **'Vẫn mở'**
  String get resultWarnOpen;

  /// No description provided for @resultOpenFail.
  ///
  /// In vi, this message translates to:
  /// **'Không mở được liên kết'**
  String get resultOpenFail;

  /// No description provided for @aiCardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích hành vi bằng AI'**
  String get aiCardTitle;

  /// No description provided for @aiCardSubUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu offline / cộng đồng. Để Gemini phân tích kịch bản, dấu hiệu thao túng và các yếu tố tâm lý.'**
  String get aiCardSubUnknown;

  /// No description provided for @aiCardSubKnown.
  ///
  /// In vi, this message translates to:
  /// **'Bổ sung phân tích hành vi (urgency / fear / authority / greed) và lý do chi tiết từ AI.'**
  String get aiCardSubKnown;

  /// No description provided for @aiCtaUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích sâu bằng AI Gemini'**
  String get aiCtaUnknown;

  /// No description provided for @aiCtaKnown.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích hành vi bằng AI'**
  String get aiCtaKnown;

  /// No description provided for @aiCtaRedo.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích lại bằng AI'**
  String get aiCtaRedo;

  /// No description provided for @aiAnalyzing.
  ///
  /// In vi, this message translates to:
  /// **'Đang phân tích…'**
  String get aiAnalyzing;

  /// No description provided for @aiOverlayMsg.
  ///
  /// In vi, this message translates to:
  /// **'Gemini đang phân tích hành vi…'**
  String get aiOverlayMsg;

  /// No description provided for @axisLinguistic.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ học'**
  String get axisLinguistic;

  /// No description provided for @axisLinguisticSub.
  ///
  /// In vi, this message translates to:
  /// **'Dấu hiệu trong cách diễn đạt / từ vựng'**
  String get axisLinguisticSub;

  /// No description provided for @axisCyber.
  ///
  /// In vi, this message translates to:
  /// **'An ninh mạng'**
  String get axisCyber;

  /// No description provided for @axisCyberSub.
  ///
  /// In vi, this message translates to:
  /// **'Dấu hiệu kỹ thuật / hạ tầng'**
  String get axisCyberSub;

  /// No description provided for @axisSocial.
  ///
  /// In vi, this message translates to:
  /// **'Tâm lý học xã hội'**
  String get axisSocial;

  /// No description provided for @axisSocialSub.
  ///
  /// In vi, this message translates to:
  /// **'Thủ thuật thuyết phục (Cialdini & thao túng cảm xúc)'**
  String get axisSocialSub;

  /// No description provided for @securityProtocolTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cần áp dụng quy trình bảo vệ'**
  String get securityProtocolTitle;

  /// No description provided for @securityProtocolBody.
  ///
  /// In vi, this message translates to:
  /// **'Không cung cấp OTP, mã PIN, mật khẩu cho bất kỳ ai. Báo cáo cho ngân hàng / cơ quan chức năng nếu đã chuyển tiền.'**
  String get securityProtocolBody;

  /// No description provided for @riskSafe.
  ///
  /// In vi, this message translates to:
  /// **'An toàn'**
  String get riskSafe;

  /// No description provided for @riskSuspicious.
  ///
  /// In vi, this message translates to:
  /// **'Nghi ngờ'**
  String get riskSuspicious;

  /// No description provided for @riskScam.
  ///
  /// In vi, this message translates to:
  /// **'Lừa đảo'**
  String get riskScam;

  /// No description provided for @riskUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác định'**
  String get riskUnknown;

  /// No description provided for @targetPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get targetPhone;

  /// No description provided for @targetBank.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản ngân hàng'**
  String get targetBank;

  /// No description provided for @targetUrl.
  ///
  /// In vi, this message translates to:
  /// **'Đường dẫn'**
  String get targetUrl;

  /// No description provided for @targetContent.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung'**
  String get targetContent;

  /// No description provided for @historyScreenTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử kiểm tra'**
  String get historyScreenTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lượt kiểm tra nào'**
  String get historyEmpty;

  /// No description provided for @historyDeleteAllConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xoá toàn bộ lịch sử?'**
  String get historyDeleteAllConfirmTitle;

  /// No description provided for @historyDeleteAllConfirmBody.
  ///
  /// In vi, this message translates to:
  /// **'Hành động này không thể hoàn tác.'**
  String get historyDeleteAllConfirmBody;

  /// No description provided for @historyDeleteBtn.
  ///
  /// In vi, this message translates to:
  /// **'Xoá'**
  String get historyDeleteBtn;

  /// No description provided for @notifTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notifTitle;

  /// No description provided for @notifEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có cuộc gọi nào được CallScreening xử lý.\nKhi có số trong danh sách lừa đảo gọi tới, bạn sẽ thấy ở đây.'**
  String get notifEmpty;

  /// No description provided for @notifCallBlocked.
  ///
  /// In vi, this message translates to:
  /// **'Đã chặn cuộc gọi'**
  String get notifCallBlocked;

  /// No description provided for @notifCallSuspicious.
  ///
  /// In vi, this message translates to:
  /// **'Cuộc gọi nghi ngờ'**
  String get notifCallSuspicious;

  /// No description provided for @callScreenTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo cuộc gọi'**
  String get callScreenTitle;

  /// No description provided for @callScreenOfflineList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách cảnh báo offline'**
  String get callScreenOfflineList;

  /// No description provided for @callScreenScamCount.
  ///
  /// In vi, this message translates to:
  /// **'Số lừa đảo'**
  String get callScreenScamCount;

  /// No description provided for @callScreenSuspiciousCount.
  ///
  /// In vi, this message translates to:
  /// **'Số nghi ngờ'**
  String get callScreenSuspiciousCount;

  /// No description provided for @callScreenResync.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ lại từ máy chủ'**
  String get callScreenResync;

  /// No description provided for @callScreenEnableBtn.
  ///
  /// In vi, this message translates to:
  /// **'Bật cảnh báo cuộc gọi'**
  String get callScreenEnableBtn;

  /// No description provided for @callScreenEnabledSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã bật cảnh báo cuộc gọi.'**
  String get callScreenEnabledSnack;

  /// No description provided for @callScreenPermissionSnack.
  ///
  /// In vi, this message translates to:
  /// **'Bạn cần cấp quyền sàng lọc cuộc gọi để dùng tính năng.'**
  String get callScreenPermissionSnack;

  /// No description provided for @callScreenResyncSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã tải {count} mục từ máy chủ • {scam} chặn / {suspicious} cảnh báo.'**
  String callScreenResyncSnack(int count, int scam, int suspicious);

  /// No description provided for @callScreenResyncFail.
  ///
  /// In vi, this message translates to:
  /// **'{error} (đang dùng cache: {scam} + {suspicious}).'**
  String callScreenResyncFail(String error, int scam, int suspicious);

  /// No description provided for @callScreenNoServer.
  ///
  /// In vi, this message translates to:
  /// **'Không thể kết nối máy chủ'**
  String get callScreenNoServer;

  /// No description provided for @callStatusAndroidOnly.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng chỉ khả dụng trên Android'**
  String get callStatusAndroidOnly;

  /// No description provided for @callStatusAndroidOnlyBody.
  ///
  /// In vi, this message translates to:
  /// **'CallScreeningService là API riêng của Android (10+). Trên iOS chỉ có thể dùng tab Kiểm tra thủ công.'**
  String get callStatusAndroidOnlyBody;

  /// No description provided for @callStatusActive.
  ///
  /// In vi, this message translates to:
  /// **'Đang bật cảnh báo cuộc gọi'**
  String get callStatusActive;

  /// No description provided for @callStatusActiveBody.
  ///
  /// In vi, this message translates to:
  /// **'Mọi cuộc gọi đến sẽ được đối chiếu với danh sách lừa đảo trên máy. Cuộc gọi lừa đảo sẽ bị từ chối, cuộc gọi nghi ngờ sẽ kèm thông báo cảnh báo.'**
  String get callStatusActiveBody;

  /// No description provided for @callStatusInactive.
  ///
  /// In vi, this message translates to:
  /// **'Chưa bật cảnh báo cuộc gọi'**
  String get callStatusInactive;

  /// No description provided for @callStatusInactiveBody.
  ///
  /// In vi, this message translates to:
  /// **'Bấm \"Bật cảnh báo cuộc gọi\" và chọn Scam Detector trong hộp thoại của hệ thống để cấp quyền sàng lọc.'**
  String get callStatusInactiveBody;

  /// No description provided for @callScreenNote.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo cuộc gọi sử dụng dữ liệu offline trong app, không gửi số điện thoại của bạn ra ngoài. Yêu cầu Android 10 trở lên.'**
  String get callScreenNote;

  /// No description provided for @navTileBlocklist.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách offline đang chặn'**
  String get navTileBlocklist;

  /// No description provided for @navTileBlocklistSub.
  ///
  /// In vi, this message translates to:
  /// **'Xem các số điện thoại CallScreening đang giám sát ngay trên máy.'**
  String get navTileBlocklistSub;

  /// No description provided for @navTileKnownRisks.
  ///
  /// In vi, this message translates to:
  /// **'Cơ sở dữ liệu lừa đảo'**
  String get navTileKnownRisks;

  /// No description provided for @navTileKnownRisksSub.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt / thêm / xoá số ĐT, tài khoản và đường dẫn rủi ro trên Supabase.'**
  String get navTileKnownRisksSub;

  /// No description provided for @navTileReset.
  ///
  /// In vi, this message translates to:
  /// **'Reset toàn bộ dữ liệu app'**
  String get navTileReset;

  /// No description provided for @navTileResetSub.
  ///
  /// In vi, this message translates to:
  /// **'Xoá lịch sử, blocklist offline, cache và device id. Bắt đầu lại từ trạng thái sạch.'**
  String get navTileResetSub;

  /// No description provided for @navTileSentry.
  ///
  /// In vi, this message translates to:
  /// **'Gửi sự kiện test tới Sentry'**
  String get navTileSentry;

  /// No description provided for @navTileSentrySub.
  ///
  /// In vi, this message translates to:
  /// **'Bắn 1 message + 1 exception để xác nhận crash reporting đang hoạt động.'**
  String get navTileSentrySub;

  /// No description provided for @sentrySnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi test event lên Sentry. Vào dashboard sentry.io để xác nhận.'**
  String get sentrySnack;

  /// No description provided for @resetDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Reset toàn bộ dữ liệu app?'**
  String get resetDialogTitle;

  /// No description provided for @resetDialogBody.
  ///
  /// In vi, this message translates to:
  /// **'Mọi lịch sử kiểm tra, danh sách offline, cache và device id sẽ bị xoá. Hành động này không thể hoàn tác.'**
  String get resetDialogBody;

  /// No description provided for @resetDialogRemoteCheck.
  ///
  /// In vi, this message translates to:
  /// **'Xoá luôn lịch sử trên Supabase'**
  String get resetDialogRemoteCheck;

  /// No description provided for @resetDialogRemoteCheckSub.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ chọn nếu chỉ muốn xoá local, giữ lịch sử trên cloud.'**
  String get resetDialogRemoteCheckSub;

  /// No description provided for @resetBtn.
  ///
  /// In vi, this message translates to:
  /// **'Reset'**
  String get resetBtn;

  /// No description provided for @resetDoneSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã reset toàn bộ dữ liệu app.'**
  String get resetDoneSnack;

  /// No description provided for @blocklistTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách offline đang chặn'**
  String get blocklistTitle;

  /// No description provided for @blocklistSummary.
  ///
  /// In vi, this message translates to:
  /// **'{total} số đang được giám sát'**
  String blocklistSummary(int total);

  /// No description provided for @blocklistSummarySub.
  ///
  /// In vi, this message translates to:
  /// **'{scam} số sẽ bị chặn, {suspicious} số sẽ kèm cảnh báo.'**
  String blocklistSummarySub(int scam, int suspicious);

  /// No description provided for @blocklistSectionScam.
  ///
  /// In vi, this message translates to:
  /// **'Số sẽ bị chặn (lừa đảo)'**
  String get blocklistSectionScam;

  /// No description provided for @blocklistSectionSuspicious.
  ///
  /// In vi, this message translates to:
  /// **'Số sẽ kèm cảnh báo (nghi ngờ)'**
  String get blocklistSectionSuspicious;

  /// No description provided for @blocklistEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có số nào trong danh sách offline. Bấm nút đồng bộ ở góc phải để tải về từ máy chủ.'**
  String get blocklistEmpty;

  /// No description provided for @blocklistSectionEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có số nào ở mức này.'**
  String get blocklistSectionEmpty;

  /// No description provided for @blocklistNote.
  ///
  /// In vi, this message translates to:
  /// **'Đây là danh sách số điện thoại đã được tải xuống máy. CallScreeningService chạy hoàn toàn offline — không gửi số ra ngoài.'**
  String get blocklistNote;

  /// No description provided for @blocklistResyncSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã đồng bộ {scam} số lừa đảo, {suspicious} số nghi ngờ.'**
  String blocklistResyncSnack(int scam, int suspicious);

  /// No description provided for @knownRisksTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cơ sở dữ liệu lừa đảo'**
  String get knownRisksTitle;

  /// No description provided for @knownRisksTabPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số ĐT ({count})'**
  String knownRisksTabPhone(int count);

  /// No description provided for @knownRisksTabBank.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản ({count})'**
  String knownRisksTabBank(int count);

  /// No description provided for @knownRisksTabUrl.
  ///
  /// In vi, this message translates to:
  /// **'Đường dẫn ({count})'**
  String knownRisksTabUrl(int count);

  /// No description provided for @knownRisksEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu cho danh mục này.\nKiểm tra kết nối Supabase rồi bấm tải lại.'**
  String get knownRisksEmpty;

  /// No description provided for @knownRisksAddBtn.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get knownRisksAddBtn;

  /// No description provided for @knownRisksAddedSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm vào cơ sở dữ liệu.'**
  String get knownRisksAddedSnack;

  /// No description provided for @knownRisksDeleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xoá khỏi cơ sở dữ liệu?'**
  String get knownRisksDeleteTitle;

  /// No description provided for @knownRisksDeleteBody.
  ///
  /// In vi, this message translates to:
  /// **'{value} sẽ bị xoá khỏi Supabase. Mọi thiết bị khác cũng sẽ không nhận được entry này khi đồng bộ.'**
  String knownRisksDeleteBody(String value);

  /// No description provided for @knownRisksDeletedSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã xoá {value}.'**
  String knownRisksDeletedSnack(String value);

  /// No description provided for @knownRisksDeleteFail.
  ///
  /// In vi, this message translates to:
  /// **'Không xoá được: {error}'**
  String knownRisksDeleteFail(String error);

  /// No description provided for @knownRisksSwipeDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xoá'**
  String get knownRisksSwipeDelete;

  /// No description provided for @addDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào cơ sở dữ liệu'**
  String get addDialogTitle;

  /// No description provided for @addDialogType.
  ///
  /// In vi, this message translates to:
  /// **'Loại'**
  String get addDialogType;

  /// No description provided for @addDialogTypePhone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get addDialogTypePhone;

  /// No description provided for @addDialogTypeBank.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản NH'**
  String get addDialogTypeBank;

  /// No description provided for @addDialogTypeUrl.
  ///
  /// In vi, this message translates to:
  /// **'Đường dẫn'**
  String get addDialogTypeUrl;

  /// No description provided for @addDialogBank.
  ///
  /// In vi, this message translates to:
  /// **'Ngân hàng'**
  String get addDialogBank;

  /// No description provided for @addDialogValue.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị'**
  String get addDialogValue;

  /// No description provided for @addDialogValueHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: 0888888888 / vietcombank-online.xyz'**
  String get addDialogValueHint;

  /// No description provided for @addDialogRisk.
  ///
  /// In vi, this message translates to:
  /// **'Mức rủi ro'**
  String get addDialogRisk;

  /// No description provided for @addDialogRiskScam.
  ///
  /// In vi, this message translates to:
  /// **'Lừa đảo (scam)'**
  String get addDialogRiskScam;

  /// No description provided for @addDialogRiskSuspicious.
  ///
  /// In vi, this message translates to:
  /// **'Nghi ngờ (suspicious)'**
  String get addDialogRiskSuspicious;

  /// No description provided for @addDialogRiskSafe.
  ///
  /// In vi, this message translates to:
  /// **'An toàn (safe)'**
  String get addDialogRiskSafe;

  /// No description provided for @addDialogSummary.
  ///
  /// In vi, this message translates to:
  /// **'Tóm tắt (1 câu)'**
  String get addDialogSummary;

  /// No description provided for @addDialogReasons.
  ///
  /// In vi, this message translates to:
  /// **'Lý do (mỗi dòng 1 ý)'**
  String get addDialogReasons;

  /// No description provided for @addDialogSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get addDialogSave;

  /// No description provided for @addDialogSaveFail.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thất bại.'**
  String get addDialogSaveFail;

  /// No description provided for @contentTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích nội dung'**
  String get contentTitle;

  /// No description provided for @contentHeadline.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích bằng AI đa góc nhìn'**
  String get contentHeadline;

  /// No description provided for @contentSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Dán tin nhắn, mô tả cuộc gọi hoặc đính kèm ảnh / video. Gemini đọc cả OCR trong ảnh + nội dung video để phân tích theo 3 góc: ngôn ngữ học, an ninh mạng và tâm lý xã hội.'**
  String get contentSubtitle;

  /// No description provided for @contentHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: \"Vietcombank xin chào quý khách, tài khoản của quý khách phát sinh giao dịch lạ...\"'**
  String get contentHint;

  /// No description provided for @contentPasteTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Dán từ clipboard'**
  String get contentPasteTooltip;

  /// No description provided for @contentClipboardEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Clipboard rỗng'**
  String get contentClipboardEmpty;

  /// No description provided for @contentAnalyzeBtn.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích bằng AI'**
  String get contentAnalyzeBtn;

  /// No description provided for @contentEmptyError.
  ///
  /// In vi, this message translates to:
  /// **'Nhập text hoặc đính kèm ảnh / video để AI phân tích.'**
  String get contentEmptyError;

  /// No description provided for @contentTextTooShort.
  ///
  /// In vi, this message translates to:
  /// **'Text quá ngắn (tối thiểu 5 ký tự) hoặc kèm thêm ảnh.'**
  String get contentTextTooShort;

  /// No description provided for @contentOverlayText.
  ///
  /// In vi, this message translates to:
  /// **'Gemini đang phân tích nội dung…'**
  String get contentOverlayText;

  /// No description provided for @contentOverlayMedia.
  ///
  /// In vi, this message translates to:
  /// **'Gemini đang đọc ảnh / video + phân tích…'**
  String get contentOverlayMedia;

  /// No description provided for @attachLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đính kèm ảnh / video (tuỳ chọn)'**
  String get attachLabel;

  /// No description provided for @attachLabelCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã đính kèm {count} ({size} / {max})'**
  String attachLabelCount(int count, String size, String max);

  /// No description provided for @attachGallery.
  ///
  /// In vi, this message translates to:
  /// **'Thư viện'**
  String get attachGallery;

  /// No description provided for @attachCamera.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh'**
  String get attachCamera;

  /// No description provided for @attachVideo.
  ///
  /// In vi, this message translates to:
  /// **'Video'**
  String get attachVideo;

  /// No description provided for @attachMaxImages.
  ///
  /// In vi, this message translates to:
  /// **'Tối đa {max} ảnh / lần phân tích.'**
  String attachMaxImages(int max);

  /// No description provided for @attachMaxVideo.
  ///
  /// In vi, this message translates to:
  /// **'Đã có 1 video — chỉ phân tích 1 video / lần.'**
  String get attachMaxVideo;

  /// No description provided for @attachSizeExceeded.
  ///
  /// In vi, this message translates to:
  /// **'Vượt quá tổng dung lượng cho phép (~18 MB). Hãy chọn file nhỏ hơn hoặc bớt media.'**
  String get attachSizeExceeded;

  /// No description provided for @attachPickImageFail.
  ///
  /// In vi, this message translates to:
  /// **'Không chọn được ảnh: {error}'**
  String attachPickImageFail(String error);

  /// No description provided for @attachPickVideoFail.
  ///
  /// In vi, this message translates to:
  /// **'Không chọn được video: {error}'**
  String attachPickVideoFail(String error);

  /// No description provided for @exampleSectionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hoặc thử với mẫu có sẵn'**
  String get exampleSectionLabel;

  /// No description provided for @exampleBankTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mạo danh ngân hàng'**
  String get exampleBankTitle;

  /// No description provided for @exampleBankBody.
  ///
  /// In vi, this message translates to:
  /// **'Vietcombank thông báo: tài khoản của quý khách bị khoá do nghi ngờ gian lận. Vui lòng nhấn link sau để xác minh: http://vcb-online-secure.xyz/login. Nếu không xác minh trong 30 phút, mọi giao dịch sẽ bị huỷ.'**
  String get exampleBankBody;

  /// No description provided for @exampleShopeeTitle.
  ///
  /// In vi, this message translates to:
  /// **'CTV Shopee lãi cao'**
  String get exampleShopeeTitle;

  /// No description provided for @exampleShopeeBody.
  ///
  /// In vi, this message translates to:
  /// **'Em chào anh/chị, em là tuyển dụng CTV Shopee. Anh/chị chỉ cần đặt đơn ảo, công ty hoàn lại tiền và cộng thêm 15% hoa hồng. Một ngày dễ kiếm 500-800k. Anh/chị quan tâm em gửi link nhóm Telegram.'**
  String get exampleShopeeBody;

  /// No description provided for @examplePoliceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giả công an'**
  String get examplePoliceTitle;

  /// No description provided for @examplePoliceBody.
  ///
  /// In vi, this message translates to:
  /// **'Đồng chí, đây là Đại uý Nguyễn Văn A — Phòng Cảnh sát Hình sự. Tài khoản của đồng chí có liên quan đường dây ma tuý xuyên quốc gia. Đồng chí phải chuyển toàn bộ tiền vào tài khoản tạm giữ của Bộ Công an để phục vụ điều tra trong 1 tiếng.'**
  String get examplePoliceBody;

  /// No description provided for @incomingSecurityWarning.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo bảo mật'**
  String get incomingSecurityWarning;

  /// No description provided for @incomingScamDetected.
  ///
  /// In vi, this message translates to:
  /// **'AI PHÁT HIỆN MẪU LỪA ĐẢO'**
  String get incomingScamDetected;

  /// No description provided for @incomingSuspiciousDetected.
  ///
  /// In vi, this message translates to:
  /// **'CẦN THẬN — DẤU HIỆU NGHI NGỜ'**
  String get incomingSuspiciousDetected;

  /// No description provided for @incomingCallLabel.
  ///
  /// In vi, this message translates to:
  /// **'CUỘC GỌI ĐẾN'**
  String get incomingCallLabel;

  /// No description provided for @incomingCopyTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép số'**
  String get incomingCopyTooltip;

  /// No description provided for @incomingCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép'**
  String get incomingCopied;

  /// No description provided for @incomingRiskAnalysis.
  ///
  /// In vi, this message translates to:
  /// **'PHÂN TÍCH NGUY CƠ'**
  String get incomingRiskAnalysis;

  /// No description provided for @incomingConfidence.
  ///
  /// In vi, this message translates to:
  /// **'NIỀM TIN'**
  String get incomingConfidence;

  /// No description provided for @incomingBlockBtn.
  ///
  /// In vi, this message translates to:
  /// **'CHẶN & NGẮT MÁY'**
  String get incomingBlockBtn;

  /// No description provided for @incomingWarnBtn.
  ///
  /// In vi, this message translates to:
  /// **'GHI NHẬN CẢNH BÁO'**
  String get incomingWarnBtn;

  /// No description provided for @incomingTrustBtn.
  ///
  /// In vi, this message translates to:
  /// **'Tôi vẫn tin số này'**
  String get incomingTrustBtn;

  /// No description provided for @incomingProtectedBy.
  ///
  /// In vi, this message translates to:
  /// **'Bảo vệ chủ động bởi Scam Detector'**
  String get incomingProtectedBy;

  /// No description provided for @incomingBlockedSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm {number} vào danh sách chặn lừa đảo.'**
  String incomingBlockedSnack(String number);

  /// No description provided for @incomingRemovedSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã gỡ {number} khỏi danh sách chặn.'**
  String incomingRemovedSnack(String number);

  /// No description provided for @incomingNotInListSnack.
  ///
  /// In vi, this message translates to:
  /// **'{number} không có trong danh sách offline.'**
  String incomingNotInListSnack(String number);

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get settingsAppearance;

  /// No description provided for @settingsLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get settingsDark;

  /// No description provided for @settingsSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get settingsSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageVi.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get settingsLanguageVi;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsBehavior.
  ///
  /// In vi, this message translates to:
  /// **'Điều hướng'**
  String get settingsBehavior;

  /// No description provided for @settingsPreventMinimize.
  ///
  /// In vi, this message translates to:
  /// **'Ngăn thu nhỏ khi bấm Back'**
  String get settingsPreventMinimize;

  /// No description provided for @settingsPreventMinimizeDesc.
  ///
  /// In vi, this message translates to:
  /// **'Bấm Back sẽ quay màn trước thay vì thoát app.'**
  String get settingsPreventMinimizeDesc;

  /// No description provided for @settingsAbout.
  ///
  /// In vi, this message translates to:
  /// **'Về ứng dụng'**
  String get settingsAbout;

  /// No description provided for @settingsAppName.
  ///
  /// In vi, this message translates to:
  /// **'Scam Guard'**
  String get settingsAppName;

  /// No description provided for @settingsDataReset.
  ///
  /// In vi, this message translates to:
  /// **'Reset toàn bộ dữ liệu'**
  String get settingsDataReset;

  /// No description provided for @settingsResetDialogBody.
  ///
  /// In vi, this message translates to:
  /// **'Hành động này sẽ xoá toàn bộ dữ liệu trên máy, bao gồm lịch sử, danh sách chặn và cài đặt. Tiếp tục?'**
  String get settingsResetDialogBody;

  /// No description provided for @settingsResetComingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng này sẽ được bổ sung sau.'**
  String get settingsResetComingSoon;

  /// No description provided for @checkEmptyInputError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập thông tin cần kiểm tra.'**
  String get checkEmptyInputError;

  /// No description provided for @screenedCallBlockedSummary.
  ///
  /// In vi, this message translates to:
  /// **'Cuộc gọi bị chặn tự động vì khớp danh sách lừa đảo.'**
  String get screenedCallBlockedSummary;

  /// No description provided for @screenedCallWarnedSummary.
  ///
  /// In vi, this message translates to:
  /// **'Cuộc gọi nghi ngờ — đã được cảnh báo nhưng không chặn.'**
  String get screenedCallWarnedSummary;

  /// No description provided for @screenedCallBlockedReason.
  ///
  /// In vi, this message translates to:
  /// **'CallScreeningService đã chặn cuộc gọi từ {number}.'**
  String screenedCallBlockedReason(String number);

  /// No description provided for @screenedCallWarnedReason.
  ///
  /// In vi, this message translates to:
  /// **'CallScreeningService cảnh báo cuộc gọi từ {number}.'**
  String screenedCallWarnedReason(String number);

  /// No description provided for @screenedCallOfflineReason.
  ///
  /// In vi, this message translates to:
  /// **'Số khớp danh sách offline được đồng bộ từ Scam Detector.'**
  String get screenedCallOfflineReason;

  /// No description provided for @incomingCallSummary.
  ///
  /// In vi, this message translates to:
  /// **'Cuộc gọi từ số có dấu hiệu {label}. Hãy thận trọng nếu bắt máy.'**
  String incomingCallSummary(String label);

  /// No description provided for @incomingCallScreenedReason.
  ///
  /// In vi, this message translates to:
  /// **'CallScreeningService phát hiện trùng danh sách offline.'**
  String get incomingCallScreenedReason;

  /// No description provided for @checkBankDigits.
  ///
  /// In vi, this message translates to:
  /// **'{count} chữ số'**
  String checkBankDigits(int count);

  /// No description provided for @checkBankDigitRange.
  ///
  /// In vi, this message translates to:
  /// **'{min}–{max} chữ số'**
  String checkBankDigitRange(int min, int max);

  /// No description provided for @checkBankHintWithRange.
  ///
  /// In vi, this message translates to:
  /// **'VD: {bank} — {range}'**
  String checkBankHintWithRange(Object bank, Object range);

  /// No description provided for @riskScoreLabel.
  ///
  /// In vi, this message translates to:
  /// **'ĐIỂM RỦI RO'**
  String get riskScoreLabel;

  /// No description provided for @radarPressure.
  ///
  /// In vi, this message translates to:
  /// **'Áp lực'**
  String get radarPressure;

  /// No description provided for @radarAuthority.
  ///
  /// In vi, this message translates to:
  /// **'Quyền lực'**
  String get radarAuthority;

  /// No description provided for @radarGreed.
  ///
  /// In vi, this message translates to:
  /// **'Lợi ích'**
  String get radarGreed;

  /// No description provided for @radarFear.
  ///
  /// In vi, this message translates to:
  /// **'Sợ hãi'**
  String get radarFear;

  /// No description provided for @scanningDefaultMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đang phân tích bằng AI…'**
  String get scanningDefaultMessage;

  /// No description provided for @scanningSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Gemini đang phân tích đa góc nhìn — 2–5 giây.'**
  String get scanningSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
