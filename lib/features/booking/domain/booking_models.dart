enum BookingScreen {
  splash,
  login,
  venueList,
  venueDetail,
  cart,
  payment,
  success,
  notifications,
  conversations,
  chatRoom,
  map,
  account,
}

enum SlotStatus { available, locked, booked }

class FieldInfo {
  const FieldInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
  });

  final String id;
  final String name;
  final String type;
  final int price;
}

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.priceFrom,
    required this.priceTo,
    required this.types,
    required this.amenities,
    required this.openHours,
    required this.fields,
  });

  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final int priceFrom;
  final int priceTo;
  final List<String> types;
  final List<String> amenities;
  final String openHours;
  final List<FieldInfo> fields;
}

class SlotInfo {
  const SlotInfo({
    required this.id,
    required this.time,
    required this.status,
  });

  final String id;
  final String time;
  final SlotStatus status;
}

class CartItem {
  const CartItem({
    required this.id,
    required this.venueName,
    required this.fieldName,
    required this.date,
    required this.time,
    required this.price,
  });

  final String id;
  final String venueName;
  final String fieldName;
  final String date;
  final String time;
  final int price;
}

class PaymentInfo {
  const PaymentInfo({
    required this.cart,
    required this.subtotal,
    required this.discount,
    required this.discountCode,
    required this.total,
  });

  final List<CartItem> cart;
  final int subtotal;
  final int discount;
  final String discountCode;
  final int total;
}

class Conversation {
  const Conversation({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.online,
    this.isGroup = false,
  });

  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final bool online;
  final bool isGroup;
}

class ChatMessage {
  const ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.read,
  });

  final String sender;
  final String text;
  final String time;
  final bool read;
}
