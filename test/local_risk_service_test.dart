import 'package:flutter_test/flutter_test.dart';
import 'package:scam_detector/data/models/scam_check_result.dart';
import 'package:scam_detector/services/local_risk_service.dart';

void main() {
  group('LocalRiskService.normalize', () {
    test('phone numbers strip spaces, dashes and parentheses', () {
      expect(
        LocalRiskService.normalize(CheckTarget.phone, '(088) 888-8888'),
        '0888888888',
      );
    });

    test('phone numbers starting with +84 normalize to 0-form', () {
      // +84 888 888 888 → 11 digits (country code + 9 subscriber digits)
      // → canonical domestic: 0888888888
      expect(
        LocalRiskService.normalize(CheckTarget.phone, '+84 888 888 888'),
        '0888888888',
      );
    });

    test('phone numbers starting with +840 (with leading 0) normalize to 0-form', () {
      // +84 088 888 8888 → 12 digits (country code + extra 0 + 9 subscriber)
      // → canonical domestic: 0888888888
      expect(
        LocalRiskService.normalize(CheckTarget.phone, '+84 088 888 8888'),
        '0888888888',
      );
    });

    test('plain 0-form phone numbers unchanged', () {
      expect(
        LocalRiskService.normalize(CheckTarget.phone, '0888888888'),
        '0888888888',
      );
    });

    test('non-VN country codes keep digits-only (no conversion)', () {
      // +1 212 555 1234 → US number, stays as digits
      expect(
        LocalRiskService.normalize(CheckTarget.phone, '+1 212 555 1234'),
        '12125551234',
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
