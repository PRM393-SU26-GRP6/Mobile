import 'package:flutter_test/flutter_test.dart';

import 'package:prm_web/app/app.dart';

void main() {
  testWidgets('PitchBook shows the login form after splash', (tester) async {
    await tester.pumpWidget(const App());

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
    expect(find.text('Tiếp tục với tài khoản demo'), findsNothing);
  });
}
