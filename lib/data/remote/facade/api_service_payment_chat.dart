part of '../api_service.dart';

extension PaymentChatApiFacade on ApiServiceImpl {
  Future<List<PaymentModel>> getPaymentsByBooking(String bookingId) =>
      paymentService.getPaymentsByBooking(bookingId);
  Future<PaymentModel> createDepositPayment(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) =>
      paymentService.createDepositPayment(
        bookingId,
        paymentMethod: paymentMethod,
      );
  Future<PaymentModel> createFinalPayment(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) =>
      paymentService.createFinalPayment(
        bookingId,
        paymentMethod: paymentMethod,
      );
  Future<PaymentModel> createFullPayment(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) =>
      paymentService.createFullPayment(
        bookingId,
        paymentMethod: paymentMethod,
      );
  Future<SePayQRInfoModel?> getSePayQRInfo(String paymentId) =>
      paymentService.getSePayQRInfo(paymentId);
  Future<PaymentModel?> getPaymentById(String paymentId) =>
      paymentService.getPaymentById(paymentId);
  Future<SePayCheckoutFormModel?> getSePayCheckout(String paymentId) =>
      paymentService.getSePayCheckout(paymentId);
  Future<Map<String, dynamic>?> handleSePayWebhook({
    required String transferType,
    required String transferAmount,
    required String transferDate,
    required String bankAccount,
    String? reference,
  }) =>
      paymentService.handleSePayWebhook(
        transferType: transferType,
        transferAmount: transferAmount,
        transferDate: transferDate,
        bankAccount: bankAccount,
        reference: reference,
      );
  Future<Map<String, dynamic>?> handlePaymentCallback({
    required String gateway,
    required Map<String, dynamic> callbackData,
  }) =>
      paymentService.handlePaymentCallback(
        gateway: gateway,
        callbackData: callbackData,
      );
  Future<List<PaymentModel>> getPaymentHistory({
    int pageNumber = 1,
    int pageSize = 20,
  }) =>
      paymentService.getPaymentHistory(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

  Future<List<ChatRoomModel>> getChatRooms({
    int pageNumber = 1,
    int pageSize = 20,
  }) =>
      chatService.getChatRooms(pageNumber: pageNumber, pageSize: pageSize);
  Future<ChatRoomModel> createChatRoom(CreateChatRoomRequest request) =>
      chatService.createChatRoom(request);
  Future<List<MessageModel>> getChatMessages({
    required String roomId,
    int pageNumber = 1,
    int pageSize = 50,
  }) =>
      chatService.getChatMessages(
        roomId: roomId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
  Future<MessageModel> sendMessage({
    required String roomId,
    required String messageText,
  }) =>
      chatService.sendMessage(roomId: roomId, messageText: messageText);
  Future<void> markChatAsRead(String roomId) =>
      chatService.markChatAsRead(roomId);
}
