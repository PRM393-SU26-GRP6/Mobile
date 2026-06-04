import 'package:flutter/material.dart';

import '../../domain/booking_models.dart';
import '../widgets/booking_ui.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    required this.cart,
    required this.onBack,
    required this.onRemove,
    required this.onCheckout,
    super.key,
  });

  final List<CartItem> cart;
  final VoidCallback onBack;
  final ValueChanged<CartItem> onRemove;
  final ValueChanged<PaymentInfo> onCheckout;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _discountController = TextEditingController();
  int _discount = 0;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.cart.fold<int>(0, (sum, item) => sum + item.price);
    final discountedTotal = subtotal - _discount;
    final total = discountedTotal < 0 ? 0 : discountedTotal;

    return BookingShell(
      key: const ValueKey('cart'),
      child: Column(
        children: [
          BookingTopBar(title: 'Giỏ hàng', onBack: widget.onBack),
          Expanded(
            child: widget.cart.isEmpty
                ? const BookingEmptyState(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Giỏ hàng trống',
                    message: 'Hãy chọn một vài khung giờ để đặt sân.',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 130),
                    children: [
                      ...widget.cart.map((item) => _CartTile(item: item, onRemove: () => widget.onRemove(item))),
                      const SizedBox(height: 12),
                      _DiscountBox(controller: _discountController, subtotal: subtotal, onChanged: (value) => setState(() => _discount = value)),
                      const SizedBox(height: 12),
                      _SummaryCard(subtotal: subtotal, discount: _discount, total: total, count: widget.cart.length),
                    ],
                  ),
          ),
          BookingBottomAction(
            label: 'Thanh toán ${money(total)}',
            icon: Icons.credit_card,
            enabled: widget.cart.isNotEmpty,
            onPressed: () => widget.onCheckout(
              PaymentInfo(
                cart: List.of(widget.cart),
                subtotal: subtotal,
                discount: _discount,
                discountCode: _discountController.text.trim(),
                total: total,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item, required this.onRemove});

  final CartItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: bookingMint, foregroundColor: bookingPrimary, child: Icon(Icons.sports_soccer)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.fieldName, style: const TextStyle(fontWeight: FontWeight.w900)),
                Text('${item.venueName}\n${item.date} · ${item.time}', style: const TextStyle(color: bookingMuted, height: 1.4)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(money(item.price), style: const TextStyle(color: bookingPrimary, fontWeight: FontWeight.w900)),
              IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiscountBox extends StatelessWidget {
  const _DiscountBox({required this.controller, required this.subtotal, required this.onChanged});

  final TextEditingController controller;
  final int subtotal;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, color: bookingPrimary),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'PITCH20 hoặc WELCOME50', border: InputBorder.none))),
          TextButton(
            onPressed: () {
              final code = controller.text.trim().toUpperCase();
              if (code == 'PITCH20') {
                onChanged((subtotal * 0.2).round());
              } else if (code == 'WELCOME50') {
                onChanged(50000);
              } else {
                onChanged(0);
              }
            },
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.subtotal, required this.discount, required this.total, required this.count});

  final int subtotal;
  final int discount;
  final int total;
  final int count;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      child: Column(
        children: [
          BookingAmountLine(label: 'Tạm tính ($count slot)', value: money(subtotal)),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            BookingAmountLine(label: 'Giảm giá', value: '-${money(discount)}'),
          ],
          const Divider(height: 24),
          BookingAmountLine(label: 'Tổng thanh toán', value: money(total), highlight: true),
        ],
      ),
    );
  }
}
