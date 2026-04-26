import 'package:flutter_test/flutter_test.dart';

import 'package:scam_detector/app.dart';

void main() {
  testWidgets('Home screen shows three check tiles', (WidgetTester tester) async {
    await tester.pumpWidget(const ScamDetectorApp());
    await tester.pump();

    expect(find.text('Số điện thoại'), findsOneWidget);
    expect(find.text('Tài khoản ngân hàng'), findsOneWidget);
    expect(find.text('Đường dẫn website'), findsOneWidget);
  });
}
