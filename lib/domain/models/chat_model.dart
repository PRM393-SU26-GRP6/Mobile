class ChatRoomModel {
  final String roomId;
  final String customerId;
  final String hostId;
  final DateTime createdAt;
  final String? customerName;
  final String? hostName;
  final String? lastMessagePreview;
  final DateTime? lastMessageTime;

  ChatRoomModel({
    required this.roomId,
    required this.customerId,
    required this.hostId,
    required this.createdAt,
    this.customerName,
    this.hostName,
    this.lastMessagePreview,
    this.lastMessageTime,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      roomId: json["roomId"] ?? '',
      customerId: json["customerId"] ?? '',
      hostId: json["hostId"] ?? '',
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
      customerName: json["customerName"],
      hostName: json["hostName"],
      lastMessagePreview: json["lastMessagePreview"],
      lastMessageTime: json["lastMessageTime"] != null
          ? DateTime.tryParse(json["lastMessageTime"])
          : null,
    );
  }

  String get displayName => customerName ?? hostName ?? 'Chat';

  String getPartnerName(String? currentUserId) {
    // Xác định người đang chat cùng dựa trên userId
    // Nếu mình là customer (customerId == currentUserId) → hiện hostName
    // Nếu mình là owner (hostId == currentUserId) → hiện customerName
    if (currentUserId == customerId) {
      return hostName ?? customerName ?? 'Chat';
    } else if (currentUserId == hostId) {
      return customerName ?? hostName ?? 'Chat';
    }
    // Fallback
    return displayName;
  }

  String getCurrentUserRoleLabel(String? currentUserId) {
    if (currentUserId == customerId) return 'Customer';
    if (currentUserId == hostId) return 'Owner';
    return 'Thanh vien';
  }

  String getPartnerRoleLabel(String? currentUserId) {
    if (currentUserId == customerId) return 'Owner';
    if (currentUserId == hostId) return 'Customer';
    return 'Thanh vien';
  }

  String getCurrentUserRoleLabelForAuthRole(
    String? currentUserId,
    String? currentUserRole,
  ) {
    final authRole = _normalizeRole(currentUserRole);
    if (authRole != null) return authRole;
    return getCurrentUserRoleLabel(currentUserId);
  }

  String getPartnerRoleLabelForAuthRole(
    String? currentUserId,
    String? currentUserRole,
  ) {
    final authRole = _normalizeRole(currentUserRole);
    if (authRole == 'Owner') return 'Customer';
    if (authRole == 'Customer') return 'Owner';
    return getPartnerRoleLabel(currentUserId);
  }

  String? _normalizeRole(String? role) {
    if (role == null) return null;
    final value = role.trim().toLowerCase();
    if (value == 'owner') return 'Owner';
    if (value == 'customer') return 'Customer';
    return null;
  }

  String get contextLabel => 'Chat chung';

  String getPartnerAvatarText(String? currentUserId) {
    final name = getPartnerName(currentUserId);
    if (name.isEmpty || name == 'Chat') return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get avatarText {
    final name = displayName;
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get timeAgo {
    if (lastMessageTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageTime!);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}p';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${lastMessageTime!.day}/${lastMessageTime!.month}';
  }
}

class MessageModel {
  final String messageId;
  final String roomId;
  final String senderId;
  final String? senderName;
  final String? messageText;
  final bool isRead;
  final DateTime sentAt;

  MessageModel({
    required this.messageId,
    required this.roomId,
    required this.senderId,
    this.senderName,
    this.messageText,
    required this.isRead,
    required this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json["messageId"] ?? '',
      roomId: json["roomId"] ?? '',
      senderId: json["senderId"] ?? '',
      senderName: json["senderName"],
      messageText: json["messageText"],
      isRead: json["isRead"] ?? false,
      sentAt: json["sentAt"] != null
          ? DateTime.parse(json["sentAt"])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "messageId": messageId,
      "roomId": roomId,
      "senderId": senderId,
      "senderName": senderName,
      "messageText": messageText,
      "isRead": isRead,
      "sentAt": sentAt.toIso8601String(),
    };
  }
}

class CreateChatRoomRequest {
  final String customerId;
  final String ownerId;
  final String? venueId;
  final String? bookingId;

  CreateChatRoomRequest({
    required this.customerId,
    required this.ownerId,
    this.venueId,
    this.bookingId,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'ownerId': ownerId,
      if (venueId != null) 'venueId': venueId,
      if (bookingId != null) 'bookingId': bookingId,
    };
  }
}
