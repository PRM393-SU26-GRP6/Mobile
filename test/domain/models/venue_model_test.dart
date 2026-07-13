import 'package:exe101/domain/models/venue_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses production venue images with primary image first', () {
    final venue = VenueModel.fromJson({
      'venueId': 'venue-1',
      'images': [
        {'imageUrl': 'field.jpg', 'isPrimary': false},
        {'imageUrl': 'cover.jpg', 'isPrimary': true},
      ],
    });

    expect(venue.id, 'venue-1');
    expect(venue.images, ['cover.jpg', 'field.jpg']);
  });
}
