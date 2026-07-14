part of 'booking_controller.dart';

extension BookingDiscountActions on BookingController {
  Future<void> validateDiscount({
    required String code,
    required String? fieldId,
    required List<String> slotIds,
    required double totalAmount,
  }) async {
    try {
      final request = ValidateDiscountRequestDto(
        code: code,
        fieldId: fieldId,
        slotIds: slotIds,
        totalAmount: totalAmount,
      );
      final response =
          await (apiService as ApiServiceImpl).validateDiscount(request);
      if (response == null) return;

      isDiscountValid.value = response.isValid;
      discountMessage.value = response.message ?? '';
      if (response.isValid) {
        discountCode.value = code;
        discountAmount.value = response.discountAmount;
        finalPrice.value = response.finalAmount;
      } else {
        clearDiscount(totalAmount);
        discountMessage.value = response.message ?? '';
      }
    } catch (_) {
      isDiscountValid.value = false;
      discountMessage.value = 'Không thể kiểm tra mã giảm giá';
    }
  }

  void clearDiscount(double originalTotal) {
    discountCode.value = '';
    discountAmount.value = 0;
    finalPrice.value = originalTotal;
    isDiscountValid.value = false;
    discountMessage.value = '';
  }
}
