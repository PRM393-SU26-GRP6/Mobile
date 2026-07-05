import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/sepay_qr_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('renders VietQR URL as a network image instead of re-encoding it',
      (tester) async {
    final qrInfo = SePayQRInfoModel(
      paymentId: 'payment-1',
      amount: 75000,
      description: 'CMDEP-2026-0001',
      status: 'Pending',
      qrUrl:
          'https://vietqr.app/img?bank=TPBank&acc=0000000001&amount=75000&des=CMDEP-2026-0001',
      bankInfo: BankInfoModel(
        bankId: 'TPB',
        accountNo: '84519828888',
        accountName: 'PHAM DUC HUNG',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SePayQrCard(qrInfo: qrInfo),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as NetworkImage).url, qrInfo.qrUrl);
    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('NgÃ¢n hÃ ng'), findsNothing);
    expect(find.text('Sá»‘ tÃ i khoáº£n'), findsNothing);
    expect(find.text('Chá»§ tÃ i khoáº£n'), findsNothing);
    expect(find.text('84519828888'), findsNothing);
  });
}
