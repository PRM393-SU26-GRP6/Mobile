import 'package:flutter/material.dart';

import '../../../domain/booking_models.dart';
import '../booking_ui.dart';

class ReviewTile extends StatelessWidget {
  const ReviewTile({required this.review, super.key});

  final ReviewInfo review;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.userName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const Icon(Icons.star, color: Colors.amber, size: 18),
              Text('${review.rating}'),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment, style: const TextStyle(color: bookingMuted)),
          ],
        ],
      ),
    );
  }
}
