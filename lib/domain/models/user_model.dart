class UserModel {
  final String? id;
  final String? tenDangNhap;
  final String? hoVaTen;
  final String? email;
  final String? soDienThoai;
  final String? vaiTro;
  final bool? xacThucHaiYeuTo;
  final bool? isActive;
  final DateTime? thoiGianTao;
  final DateTime? thoiGianCapNhat;
  final List<String>? fcmToken;

  UserModel({
    this.id,
    this.tenDangNhap,
    this.hoVaTen,
    this.email,
    this.soDienThoai,
    this.vaiTro,
    this.xacThucHaiYeuTo,
    this.isActive,
    this.thoiGianTao,
    this.thoiGianCapNhat,
    this.fcmToken,
  });

  // Chuyển từ JSON sang Object
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        tenDangNhap: json["ten_dang_nhap"],
        hoVaTen: json["ho_va_ten"],
        email: json["email"],
        soDienThoai: json["so_dien_thoai"],
        vaiTro: json["vai_tro"],
        xacThucHaiYeuTo: json["xac_thuc_hai_yeu_to"],
        isActive: json["is_active"],
        thoiGianTao: json["thoi_gian_tao"] == null
            ? null
            : DateTime.parse(json["thoi_gian_tao"]),
        thoiGianCapNhat: json["thoi_gian_cap_nhat"] == null
            ? null
            : DateTime.parse(json["thoi_gian_cap_nhat"]),
        fcmToken: json["fcm_token"] == null
            ? []
            : List<String>.from(json["fcm_token"]!.map((x) => x.toString())),
      );

  // Chuyển từ Object sang JSON (Dùng khi cập nhật Profile)
  Map<String, dynamic> toJson() => {
        "id": id,
        "ten_dang_nhap": tenDangNhap,
        "ho_va_ten": hoVaTen,
        "email": email,
        "so_dien_thoai": soDienThoai,
        "vai_tro": vaiTro,
        "xac_thuc_hai_yeu_to": xacThucHaiYeuTo,
        "is_active": isActive,
        "thoi_gian_tao": thoiGianTao?.toIso8601String(),
        "thoi_gian_cap_nhat": thoiGianCapNhat?.toIso8601String(),
        "fcm_token": fcmToken == null 
            ? [] 
            : List<dynamic>.from(fcmToken!.map((x) => x)),
      };
}