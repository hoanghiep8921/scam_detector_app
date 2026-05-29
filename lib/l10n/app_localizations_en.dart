// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Scam Guard';

  @override
  String get navHome => 'Home';

  @override
  String get navCheck => 'Check';

  @override
  String get navHistory => 'History';

  @override
  String get navProtect => 'Protect';

  @override
  String get tooltipNotifications => 'Notifications';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String get tooltipCopy => 'Copy';

  @override
  String get tooltipRefresh => 'Reload from server';

  @override
  String get tooltipDeleteAll => 'Delete all';

  @override
  String get tooltipResync => 'Re-sync from server';

  @override
  String get homeControlCenter => 'Control Center';

  @override
  String get homeRecentActivity => 'Recent Activity';

  @override
  String get homeNoActivity =>
      'No checks yet. Try entering any phone number in the Check tab.';

  @override
  String get homeCheckPhone => 'Check phone number';

  @override
  String get homeCheckPhoneSub => 'Match against scam list + AI analysis';

  @override
  String get homeCheckBank => 'Check bank account';

  @override
  String get homeCheckBankSub =>
      'Verify account number before transferring money';

  @override
  String get homeCheckUrl => 'Analyze URL';

  @override
  String get homeCheckUrlSub => 'Detect phishing URLs and brand impersonation';

  @override
  String get homeCheckContent => 'Analyze content / message';

  @override
  String get homeCheckContentSub =>
      'Paste SMS, email, call description — AI multi-angle analysis';

  @override
  String get statChecked => 'Checked';

  @override
  String get statSafe => 'Safe';

  @override
  String get statScam => 'Scam';

  @override
  String get heroTitle => 'Real-Time Protection';

  @override
  String get heroSubtitleIos =>
      'iOS only supports manual checks — call screening requires Android.';

  @override
  String get heroSubtitleActive =>
      'AI is matching every incoming call against the on-device scam list.';

  @override
  String get heroSubtitleInactive =>
      'Enable to let Scam Detector auto-block calls from known scam numbers.';

  @override
  String get heroStatusChecking => 'Checking…';

  @override
  String get heroStatusIos => 'Manual check only (iOS)';

  @override
  String get heroStatusActive => 'Active';

  @override
  String get heroStatusInactive => 'Inactive';

  @override
  String get heroEnableBtn => 'Enable now';

  @override
  String get heroEnabledSnack => 'Real-time protection enabled.';

  @override
  String get heroPermissionSnack =>
      'You need to grant call screening permission to enable protection.';

  @override
  String get checkTitle => 'Scam Guard';

  @override
  String get checkVerifyTitle => 'Verify target';

  @override
  String get checkSubmitBtn => 'Check now';

  @override
  String get checkAnalyzeBtn => 'Analyze with AI';

  @override
  String get checkEmptyError => 'Please enter information to check.';

  @override
  String get checkValidationRequired => 'Please enter information';

  @override
  String get checkValidationPhone => 'Invalid phone number';

  @override
  String get checkValidationBank => 'Invalid account number';

  @override
  String get checkValidationUrl => 'Invalid URL';

  @override
  String get checkValidationContentShort =>
      'Content too short (minimum 5 characters)';

  @override
  String get checkSubtitlePhone =>
      'Cross-reference global risk lists and analyze scam psychology in real time.';

  @override
  String get checkSubtitleBank =>
      'Check if the recipient account has been reported in scam cases.';

  @override
  String get checkSubtitleUrl =>
      'Analyze domain structure and brand impersonation signals.';

  @override
  String get checkSubtitleContent =>
      'Paste SMS, email or describe a situation — AI multi-angle analysis.';

  @override
  String get checkHintPhone => '+84 9XX XXX XXX';

  @override
  String get checkHintBank => 'E.g. 1903 5762 8810';

  @override
  String get checkHintUrl => 'E.g. vietcombank-online.xyz';

  @override
  String get checkHintContent =>
      'E.g. \"Vietcombank notice: your account has been locked. Please visit http://vcb-verify.tk to verify within 10 minutes...\"';

  @override
  String get checkBankLabel => 'Bank';

  @override
  String get checkBankHint => 'Select the account\'s bank';

  @override
  String get checkBankHintOther => 'Enter account number (6–30 digits)';

  @override
  String checkBankValidationRange(String bank, int min, int max) {
    return '$bank account numbers are usually $min–$max digits';
  }

  @override
  String get segPhone => 'Phone';

  @override
  String get segBank => 'Account';

  @override
  String get segUrl => 'URL';

  @override
  String get segContent => 'Content';

  @override
  String get engineTitle => 'Hybrid Detection Engine';

  @override
  String get engineSubtitle => 'Local blocklist  •  Gemini Flash AI';

  @override
  String get historyTile => 'History';

  @override
  String get historyTileSub => 'View previous checks';

  @override
  String get tipsTile => 'Safety tips';

  @override
  String get tipsTileSub => 'Never share OTP or PIN with anyone';

  @override
  String get reportTitle => 'Report scam';

  @override
  String get reportSubPhone =>
      'Help the community — report a fake or scam phone number.';

  @override
  String get reportSubBank =>
      'Help the community — report a fake or scam bank account.';

  @override
  String get reportSubUrl => 'Help the community — report a fake or scam URL.';

  @override
  String get reportBtn => 'Report';

  @override
  String get reportDialogTitle => 'Report scam';

  @override
  String get reportDialogLabelPhone =>
      'Enter the phone number you want to report:';

  @override
  String get reportDialogLabelBank =>
      'Enter the account number you want to report:';

  @override
  String get reportDialogLabelUrl => 'Enter the URL you want to report:';

  @override
  String get reportDialogDesc => 'Short description (optional):';

  @override
  String get reportDialogDescHint =>
      'E.g. Impersonating a bank to request a transfer...';

  @override
  String get reportSuccess =>
      'Report submitted. Thank you for contributing to the community!';

  @override
  String get reportFail => 'Failed to submit report. Please try again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get send => 'Submit report';

  @override
  String get resultTitle => 'Analysis result';

  @override
  String get resultCopied => 'Result copied';

  @override
  String get resultShareReasons => 'Reasons:';

  @override
  String get resultWarningReasons => 'Warning reasons';

  @override
  String get resultMultiAxis => 'Multi-angle analysis';

  @override
  String get resultPsyVector => 'Psychological vector analysis';

  @override
  String get resultRadarDesc =>
      'Each axis represents a common psychological manipulation tactic (0–100). Larger area = higher manipulation level.';

  @override
  String get resultOpenLink => 'Open link';

  @override
  String get resultGoHome => 'Back to home';

  @override
  String get resultUrlWarning => 'URL Warning';

  @override
  String get resultWarnDialogTitle => 'Warning';

  @override
  String resultWarnDialogContent(String level) {
    return 'This link is rated $level. Are you sure you want to open it?';
  }

  @override
  String get resultWarnCancel => 'Cancel';

  @override
  String get resultWarnOpen => 'Open anyway';

  @override
  String get resultOpenFail => 'Could not open link';

  @override
  String get aiCardTitle => 'AI Behavioural Analysis';

  @override
  String get aiCardSubUnknown =>
      'No offline / community data found. Let Gemini analyze the scenario, manipulation signals and psychological factors.';

  @override
  String get aiCardSubKnown =>
      'Add behavioural analysis (urgency / fear / authority / greed) and detailed AI reasoning.';

  @override
  String get aiCtaUnknown => 'Deep analysis with Gemini AI';

  @override
  String get aiCtaKnown => 'Behavioural analysis with AI';

  @override
  String get aiCtaRedo => 'Re-analyze with AI';

  @override
  String get aiAnalyzing => 'Analyzing…';

  @override
  String get aiOverlayMsg => 'Gemini is analyzing behavior…';

  @override
  String get axisLinguistic => 'Linguistics';

  @override
  String get axisLinguisticSub => 'Signals in wording / vocabulary';

  @override
  String get axisCyber => 'Cybersecurity';

  @override
  String get axisCyberSub => 'Technical / infrastructure signals';

  @override
  String get axisSocial => 'Social psychology';

  @override
  String get axisSocialSub =>
      'Persuasion tactics (Cialdini & emotional manipulation)';

  @override
  String get securityProtocolTitle => 'Apply security protocol';

  @override
  String get securityProtocolBody =>
      'Never share OTP, PIN or passwords with anyone. Report to your bank / authorities if you have already transferred money.';

  @override
  String get riskSafe => 'Safe';

  @override
  String get riskSuspicious => 'Suspicious';

  @override
  String get riskScam => 'Scam';

  @override
  String get riskUnknown => 'Unknown';

  @override
  String get targetPhone => 'Phone number';

  @override
  String get targetBank => 'Bank account';

  @override
  String get targetUrl => 'URL';

  @override
  String get targetContent => 'Content';

  @override
  String get historyScreenTitle => 'Check history';

  @override
  String get historyEmpty => 'No checks yet';

  @override
  String get historyDeleteAllConfirmTitle => 'Delete all history?';

  @override
  String get historyDeleteAllConfirmBody => 'This action cannot be undone.';

  @override
  String get historyDeleteBtn => 'Delete';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifEmpty =>
      'No calls have been processed by CallScreening yet.\nWhen a number on the scam list calls, you will see it here.';

  @override
  String get notifCallBlocked => 'Call blocked';

  @override
  String get notifCallSuspicious => 'Suspicious call';

  @override
  String get callScreenTitle => 'Call screening';

  @override
  String get callScreenOfflineList => 'Offline warning list';

  @override
  String get callScreenScamCount => 'Scam numbers';

  @override
  String get callScreenSuspiciousCount => 'Suspicious numbers';

  @override
  String get callScreenResync => 'Re-sync from server';

  @override
  String get callScreenEnableBtn => 'Enable call screening';

  @override
  String get callScreenEnabledSnack => 'Call screening enabled.';

  @override
  String get callScreenPermissionSnack =>
      'You need to grant call screening permission to use this feature.';

  @override
  String callScreenResyncSnack(int count, int scam, int suspicious) {
    return 'Loaded $count entries from server • $scam blocked / $suspicious warned.';
  }

  @override
  String callScreenResyncFail(String error, int scam, int suspicious) {
    return '$error (using cache: $scam + $suspicious).';
  }

  @override
  String get callScreenNoServer => 'Cannot connect to server';

  @override
  String get callStatusAndroidOnly => 'Feature only available on Android';

  @override
  String get callStatusAndroidOnlyBody =>
      'CallScreeningService is an Android-only API (10+). On iOS only the manual Check tab is available.';

  @override
  String get callStatusActive => 'Call screening is active';

  @override
  String get callStatusActiveBody =>
      'Every incoming call will be matched against the on-device scam list. Scam calls will be rejected; suspicious calls will include a warning notification.';

  @override
  String get callStatusInactive => 'Call screening is inactive';

  @override
  String get callStatusInactiveBody =>
      'Tap \"Enable call screening\" and select Scam Detector in the system dialog to grant screening permission.';

  @override
  String get callScreenNote =>
      'Call screening uses offline data in the app and does not send your phone number externally. Requires Android 10 or later.';

  @override
  String get navTileBlocklist => 'Offline blocking list';

  @override
  String get navTileBlocklistSub =>
      'View phone numbers CallScreening is currently monitoring on this device.';

  @override
  String get navTileKnownRisks => 'Scam database';

  @override
  String get navTileKnownRisksSub =>
      'Browse / add / delete risky phone numbers, accounts and URLs on Supabase.';

  @override
  String get navTileReset => 'Reset all app data';

  @override
  String get navTileResetSub =>
      'Delete history, offline blocklist, cache and device id. Start fresh.';

  @override
  String get navTileSentry => 'Send test event to Sentry';

  @override
  String get navTileSentrySub =>
      'Fire 1 message + 1 exception to confirm crash reporting is working.';

  @override
  String get sentrySnack =>
      'Test event sent to Sentry. Check your sentry.io dashboard to confirm.';

  @override
  String get resetDialogTitle => 'Reset all app data?';

  @override
  String get resetDialogBody =>
      'All check history, offline lists, cache and device id will be deleted. This action cannot be undone.';

  @override
  String get resetDialogRemoteCheck => 'Also delete history on Supabase';

  @override
  String get resetDialogRemoteCheckSub =>
      'Uncheck to keep cloud history and only clear local data.';

  @override
  String get resetBtn => 'Reset';

  @override
  String get resetDoneSnack => 'All app data has been reset.';

  @override
  String get blocklistTitle => 'Offline blocking list';

  @override
  String blocklistSummary(int total) {
    return '$total numbers being monitored';
  }

  @override
  String blocklistSummarySub(int scam, int suspicious) {
    return '$scam numbers will be blocked, $suspicious numbers will show a warning.';
  }

  @override
  String get blocklistSectionScam => 'Numbers to be blocked (scam)';

  @override
  String get blocklistSectionSuspicious => 'Numbers with warning (suspicious)';

  @override
  String get blocklistEmpty =>
      'No numbers in the offline list. Tap the sync button in the top right to download from the server.';

  @override
  String get blocklistSectionEmpty => 'No numbers at this level.';

  @override
  String get blocklistNote =>
      'This is the list of phone numbers downloaded to this device. CallScreeningService runs fully offline — no numbers are sent externally.';

  @override
  String blocklistResyncSnack(int scam, int suspicious) {
    return 'Synced $scam scam numbers, $suspicious suspicious numbers.';
  }

  @override
  String get knownRisksTitle => 'Scam database';

  @override
  String knownRisksTabPhone(int count) {
    return 'Phone ($count)';
  }

  @override
  String knownRisksTabBank(int count) {
    return 'Account ($count)';
  }

  @override
  String knownRisksTabUrl(int count) {
    return 'URL ($count)';
  }

  @override
  String get knownRisksEmpty =>
      'No data for this category.\nCheck your Supabase connection and tap reload.';

  @override
  String get knownRisksAddBtn => 'Add';

  @override
  String get knownRisksAddedSnack => 'Added to database.';

  @override
  String get knownRisksDeleteTitle => 'Delete from database?';

  @override
  String knownRisksDeleteBody(String value) {
    return '$value will be deleted from Supabase. Other devices will also stop receiving this entry on sync.';
  }

  @override
  String knownRisksDeletedSnack(String value) {
    return 'Deleted $value.';
  }

  @override
  String knownRisksDeleteFail(String error) {
    return 'Could not delete: $error';
  }

  @override
  String get knownRisksSwipeDelete => 'Delete';

  @override
  String get addDialogTitle => 'Add to database';

  @override
  String get addDialogType => 'Type';

  @override
  String get addDialogTypePhone => 'Phone number';

  @override
  String get addDialogTypeBank => 'Bank account';

  @override
  String get addDialogTypeUrl => 'URL';

  @override
  String get addDialogBank => 'Bank';

  @override
  String get addDialogValue => 'Value';

  @override
  String get addDialogValueHint => 'E.g. 0888888888 / vietcombank-online.xyz';

  @override
  String get addDialogRisk => 'Risk level';

  @override
  String get addDialogRiskScam => 'Scam';

  @override
  String get addDialogRiskSuspicious => 'Suspicious';

  @override
  String get addDialogRiskSafe => 'Safe';

  @override
  String get addDialogSummary => 'Summary (1 sentence)';

  @override
  String get addDialogReasons => 'Reasons (one per line)';

  @override
  String get addDialogSave => 'Save';

  @override
  String get addDialogSaveFail => 'Save failed.';

  @override
  String get contentTitle => 'Content analysis';

  @override
  String get contentHeadline => 'AI multi-angle analysis';

  @override
  String get contentSubtitle =>
      'Paste a message, describe a call, or attach images / video. Gemini reads OCR in images + video content to analyze from 3 angles: linguistics, cybersecurity and social psychology.';

  @override
  String get contentHint =>
      'E.g. \"Vietcombank: your account has an unusual transaction...\"';

  @override
  String get contentPasteTooltip => 'Paste from clipboard';

  @override
  String get contentClipboardEmpty => 'Clipboard is empty';

  @override
  String get contentAnalyzeBtn => 'Analyze with AI';

  @override
  String get contentEmptyError =>
      'Enter text or attach images / video for AI analysis.';

  @override
  String get contentTextTooShort =>
      'Text too short (minimum 5 characters) or attach an image.';

  @override
  String get contentOverlayText => 'Gemini is analyzing content…';

  @override
  String get contentOverlayMedia =>
      'Gemini is reading images / video + analyzing…';

  @override
  String get attachLabel => 'Attach images / video (optional)';

  @override
  String attachLabelCount(int count, String size, String max) {
    return '$count attached ($size / $max)';
  }

  @override
  String get attachGallery => 'Gallery';

  @override
  String get attachCamera => 'Camera';

  @override
  String get attachVideo => 'Video';

  @override
  String attachMaxImages(int max) {
    return 'Maximum $max images per analysis.';
  }

  @override
  String get attachMaxVideo =>
      'Already have 1 video — only 1 video per analysis.';

  @override
  String get attachSizeExceeded =>
      'Total size limit exceeded (~18 MB). Choose smaller files or remove some media.';

  @override
  String attachPickImageFail(String error) {
    return 'Could not pick image: $error';
  }

  @override
  String attachPickVideoFail(String error) {
    return 'Could not pick video: $error';
  }

  @override
  String get exampleSectionLabel => 'Or try a sample';

  @override
  String get exampleBankTitle => 'Bank impersonation';

  @override
  String get exampleBankBody =>
      'Vietcombank notice: your account has been locked due to suspected fraud. Please click the link to verify: http://vcb-online-secure.xyz/login. If not verified within 30 minutes, all transactions will be cancelled.';

  @override
  String get exampleShopeeTitle => 'Shopee affiliate scam';

  @override
  String get exampleShopeeBody =>
      'Hi, I\'m a Shopee recruiter. You just need to place fake orders, the company refunds the money plus 15% commission. Easy 500-800k per day. Interested? I\'ll send you the Telegram group link.';

  @override
  String get examplePoliceTitle => 'Police impersonation';

  @override
  String get examplePoliceBody =>
      'This is Captain Nguyen Van A — Criminal Investigation Department. Your account is linked to an international drug trafficking network. You must transfer all funds to the Ministry of Public Security\'s holding account within 1 hour for investigation.';

  @override
  String get incomingSecurityWarning => 'Security Warning';

  @override
  String get incomingScamDetected => 'AI DETECTED SCAM PATTERN';

  @override
  String get incomingSuspiciousDetected => 'CAUTION — SUSPICIOUS SIGNALS';

  @override
  String get incomingCallLabel => 'INCOMING CALL';

  @override
  String get incomingCopyTooltip => 'Copy number';

  @override
  String get incomingCopied => 'Copied';

  @override
  String get incomingRiskAnalysis => 'RISK ANALYSIS';

  @override
  String get incomingConfidence => 'CONFIDENCE';

  @override
  String get incomingBlockBtn => 'BLOCK & HANG UP';

  @override
  String get incomingWarnBtn => 'ACKNOWLEDGE WARNING';

  @override
  String get incomingTrustBtn => 'I trust this number';

  @override
  String get incomingProtectedBy => 'Actively protected by Scam Detector';

  @override
  String incomingBlockedSnack(String number) {
    return 'Added $number to the scam blocklist.';
  }

  @override
  String incomingRemovedSnack(String number) {
    return 'Removed $number from the blocklist.';
  }

  @override
  String incomingNotInListSnack(String number) {
    return '$number is not in the offline list.';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsSystem => 'System default';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageVi => 'Tiếng Việt';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsBehavior => 'Navigation';

  @override
  String get settingsPreventMinimize => 'Prevent minimize on Back';

  @override
  String get settingsPreventMinimizeDesc =>
      'Back navigates to previous screen instead of exiting.';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAppName => 'Scam Guard';

  @override
  String get settingsDataReset => 'Reset all data';

  @override
  String get settingsResetDialogBody =>
      'This will delete all data on this device, including history, blocklist and settings. Continue?';

  @override
  String get settingsResetComingSoon => 'This feature will be added later.';

  @override
  String get checkEmptyInputError => 'Please enter information to check.';

  @override
  String get screenedCallBlockedSummary =>
      'Call automatically blocked — matched the scam list.';

  @override
  String get screenedCallWarnedSummary =>
      'Suspicious call — warned but not blocked.';

  @override
  String screenedCallBlockedReason(String number) {
    return 'CallScreeningService blocked the call from $number.';
  }

  @override
  String screenedCallWarnedReason(String number) {
    return 'CallScreeningService flagged the call from $number.';
  }

  @override
  String get screenedCallOfflineReason =>
      'Number matched the offline list synced from Scam Detector.';

  @override
  String incomingCallSummary(String label) {
    return 'Call from a number with $label signals. Be cautious if you answer.';
  }

  @override
  String get incomingCallScreenedReason =>
      'CallScreeningService detected a match in the offline list.';

  @override
  String checkBankDigits(int count) {
    return '$count digits';
  }

  @override
  String checkBankDigitRange(int min, int max) {
    return '$min–$max digits';
  }

  @override
  String checkBankHintWithRange(Object bank, Object range) {
    return 'E.g. $bank — $range';
  }
}
