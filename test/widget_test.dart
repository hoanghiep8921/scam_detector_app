import 'package:flutter_test/flutter_test.dart';
import 'package:scam_detector/app.dart';

void main() {
  testWidgets('Home dashboard renders hero and command center', (tester) async {
    await tester.pumpWidget(const ScamDetectorApp());
    await tester.pump();

    expect(find.text('Bảo vệ thời gian thực'), findsOneWidget);
    expect(find.text('Trung tâm điều khiển'), findsOneWidget);
    expect(find.text('Kiểm tra số điện thoại'), findsOneWidget);
  });

  testWidgets('Bottom navigation has 4 destinations', (tester) async {
    await tester.pumpWidget(const ScamDetectorApp());
    await tester.pump();

    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Kiểm tra'), findsOneWidget);
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.text('Bảo vệ'), findsOneWidget);
  });
}
