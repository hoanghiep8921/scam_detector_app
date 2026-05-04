import 'package:flutter_test/flutter_test.dart';
import 'package:scam_detector/data/models/scam_check_result.dart';
import 'package:scam_detector/services/local_risk_service.dart';

void main() {
  group('LocalRiskService.normalize', () {
    test('phone numbers strip spaces, dashes and parentheses', () {
      expect(
        LocalRiskService.normalize(CheckTarget.phone, '(088) 8888-888'),
        '0888888888',
      );
    });

    test('bank accounts strip formatting', () {
      expect(
        LocalRiskService.normalize(CheckTarget.bankAccount, '1903 5762 8810'),
        '190357628810',
      );
    });

    test('urls drop scheme, www, path and are lowercased', () {
      expect(
        LocalRiskService.normalize(
          CheckTarget.url,
          'https://www.Vietcombank-Online.XYZ/login',
        ),
        'vietcombank-online.xyz',
      );
    });

    test('plain hosts are unchanged after lowercase', () {
      expect(
        LocalRiskService.normalize(CheckTarget.url, 'vietcombank.com.vn'),
        'vietcombank.com.vn',
      );
    });
  });
}
