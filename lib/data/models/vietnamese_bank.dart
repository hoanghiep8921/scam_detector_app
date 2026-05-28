/// Vietnamese bank metadata for account number validation and display.
class VietnameseBank {
  final String code;
  final String name;
  final String shortName;
  final int minDigits;
  final int maxDigits;

  const VietnameseBank({
    required this.code,
    required this.name,
    required this.shortName,
    required this.minDigits,
    required this.maxDigits,
  });

  static const VietnameseBank other = VietnameseBank(
    code: 'OTHER',
    name: 'Ngân hàng khác',
    shortName: 'Ngân hàng khác',
    minDigits: 6,
    maxDigits: 30,
  );

  /// Resolve a bank by its short code. Returns [other] if not found.
  static VietnameseBank fromCode(String? code) {
    if (code == null || code == 'OTHER') return other;
    return VietnameseBanks.all.firstWhere(
      (b) => b.code == code,
      orElse: () => other,
    );
  }

  @override
  String toString() => shortName;
}

/// Master list of Vietnamese banks commonly used in scam detection.
abstract final class VietnameseBanks {
  static const vietcombank = VietnameseBank(
    code: 'VCB',
    name: 'Ngân hàng TMCP Ngoại Thương Việt Nam',
    shortName: 'Vietcombank',
    minDigits: 6,
    maxDigits: 15,
  );

  static const bidv = VietnameseBank(
    code: 'BIDV',
    name: 'Ngân hàng TMCP Đầu tư và Phát triển Việt Nam',
    shortName: 'BIDV',
    minDigits: 14,
    maxDigits: 14,
  );

  static const vietinbank = VietnameseBank(
    code: 'CTG',
    name: 'Ngân hàng TMCP Công Thương Việt Nam',
    shortName: 'VietinBank',
    minDigits: 12,
    maxDigits: 12,
  );

  static const techcombank = VietnameseBank(
    code: 'TCB',
    name: 'Ngân hàng TMCP Kỹ Thương Việt Nam',
    shortName: 'Techcombank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const mbBank = VietnameseBank(
    code: 'MB',
    name: 'Ngân hàng TMCP Quân đội',
    shortName: 'MB Bank',
    minDigits: 8,
    maxDigits: 12,
  );

  static const acb = VietnameseBank(
    code: 'ACB',
    name: 'Ngân hàng TMCP Á Châu',
    shortName: 'ACB',
    minDigits: 8,
    maxDigits: 16,
  );

  static const vpbank = VietnameseBank(
    code: 'VPB',
    name: 'Ngân hàng TMCP Việt Nam Thịnh Vượng',
    shortName: 'VPBank',
    minDigits: 10,
    maxDigits: 10,
  );

  static const tpBank = VietnameseBank(
    code: 'TPB',
    name: 'Ngân hàng TMCP Tiên Phong',
    shortName: 'TPBank',
    minDigits: 9,
    maxDigits: 12,
  );

  static const agribank = VietnameseBank(
    code: 'VBA',
    name: 'Ngân hàng Nông nghiệp và Phát triển Nông thôn Việt Nam',
    shortName: 'Agribank',
    minDigits: 13,
    maxDigits: 13,
  );

  static const sacombank = VietnameseBank(
    code: 'STB',
    name: 'Ngân hàng TMCP Sài Gòn Thương Tín',
    shortName: 'Sacombank',
    minDigits: 12,
    maxDigits: 16,
  );

  static const ocb = VietnameseBank(
    code: 'OCB',
    name: 'Ngân hàng TMCP Phương Đông',
    shortName: 'OCB',
    minDigits: 11,
    maxDigits: 14,
  );

  static const hdbank = VietnameseBank(
    code: 'HDB',
    name: 'Ngân hàng TMCP Phát triển Thành phố Hồ Chí Minh',
    shortName: 'HDBank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const eximbank = VietnameseBank(
    code: 'EIB',
    name: 'Ngân hàng TMCP Xuất Nhập khẩu Việt Nam',
    shortName: 'Eximbank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const shb = VietnameseBank(
    code: 'SHB',
    name: 'Ngân hàng TMCP Sài Gòn — Hà Nội',
    shortName: 'SHB',
    minDigits: 10,
    maxDigits: 14,
  );

  static const vib = VietnameseBank(
    code: 'VIB',
    name: 'Ngân hàng TMCP Quốc tế Việt Nam',
    shortName: 'VIB',
    minDigits: 10,
    maxDigits: 14,
  );

  static const msb = VietnameseBank(
    code: 'MSB',
    name: 'Ngân hàng TMCP Hàng Hải Việt Nam',
    shortName: 'MSB',
    minDigits: 10,
    maxDigits: 14,
  );

  static const namA = VietnameseBank(
    code: 'NAB',
    name: 'Ngân hàng TMCP Nam Á',
    shortName: 'Nam A Bank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const pvcomBank = VietnameseBank(
    code: 'WB',
    name: 'Ngân hàng TMCP Đại Chúng Việt Nam',
    shortName: 'PVcomBank',
    minDigits: 12,
    maxDigits: 14,
  );

  static const baoViet = VietnameseBank(
    code: 'BVB',
    name: 'Ngân hàng TMCP Bảo Việt',
    shortName: 'BaoVietBank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const oceanBank = VietnameseBank(
    code: 'Ocean',
    name: 'Ngân hàng TMCP Đại Dương',
    shortName: 'OceanBank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const gpBank = VietnameseBank(
    code: 'GPB',
    name: 'Ngân hàng TMCP Xăng dầu Petrolimex',
    shortName: 'GPBank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const publicBank = VietnameseBank(
    code: 'PVCB',
    name: 'Ngân hàng TNHH MTV Public Việt Nam',
    shortName: 'PublicBank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const kienLong = VietnameseBank(
    code: 'KLB',
    name: 'Ngân hàng TMCP Kiên Long',
    shortName: 'KienLongBank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const seABank = VietnameseBank(
    code: 'SeAB',
    name: 'Ngân hàng TMCP Đông Nam Á',
    shortName: 'SeABank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const lpBank = VietnameseBank(
    code: 'LPB',
    name: 'Ngân hàng TMCP Bưu Điện Liên Việt',
    shortName: 'LPBank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const vietBank = VietnameseBank(
    code: 'VB',
    name: 'Ngân hàng TMCP Việt Nam Thương Tín',
    shortName: 'VietBank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const cbBank = VietnameseBank(
    code: 'CBB',
    name: 'Ngân hàng TNHH MTV Xây dựng Việt Nam',
    shortName: 'CBBank',
    minDigits: 10,
    maxDigits: 14,
  );

  static const ncb = VietnameseBank(
    code: 'NCB',
    name: 'Ngân hàng TMCP Quốc Dân',
    shortName: 'NCB',
    minDigits: 10,
    maxDigits: 14,
  );

  static const saigonBank = VietnameseBank(
    code: 'SCB',
    name: 'Ngân hàng TMCP Sài Gòn',
    shortName: 'SCB',
    minDigits: 10,
    maxDigits: 14,
  );

  static const uob = VietnameseBank(
    code: 'UOB',
    name: 'Ngân hàng United Overseas Bank Việt Nam',
    shortName: 'UOB',
    minDigits: 10,
    maxDigits: 14,
  );

  /// Complete list including "Ngân hàng khác" as the last option for UI dropdowns.
  static const List<VietnameseBank> all = [
    vietcombank,
    bidv,
    vietinbank,
    techcombank,
    mbBank,
    acb,
    vpbank,
    tpBank,
    agribank,
    sacombank,
    ocb,
    hdbank,
    eximbank,
    shb,
    vib,
    msb,
    namA,
    pvcomBank,
    baoViet,
    oceanBank,
    gpBank,
    publicBank,
    kienLong,
    seABank,
    lpBank,
    vietBank,
    cbBank,
    ncb,
    saigonBank,
    uob,
    // "Ngân hàng khác" must be inlined — const list can't reference a static
    // field within the same class.
    VietnameseBank(
      code: 'OTHER',
      name: 'Ngân hàng khác',
      shortName: 'Ngân hàng khác',
      minDigits: 6,
      maxDigits: 30,
    ),
  ];
}
