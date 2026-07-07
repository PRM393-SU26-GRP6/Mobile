class NewsModel {
  final String? id;
  final String? idDanhMuc;
  final String? tieuDe;
  final String? noiDung;
  final String? tacGia;
  final String? urlAnhDaiDien;
  final bool? isActive;
  final bool? isDelete;
  final String? nguoiTao;
  final String? nguoiCapNhat;
  final DateTime? thoiGianTao;
  final DateTime? thoiGianCapNhat;
  final bool? isNoti;
  final List<dynamic>? dinhKemTinTuc;
  final Category? danhMucTinTuc;
  final NewsCount? count;

  NewsModel({
    this.id,
    this.idDanhMuc,
    this.tieuDe,
    this.noiDung,
    this.tacGia,
    this.urlAnhDaiDien,
    this.isActive,
    this.isDelete,
    this.nguoiTao,
    this.nguoiCapNhat,
    this.thoiGianTao,
    this.thoiGianCapNhat,
    this.isNoti,
    this.dinhKemTinTuc,
    this.danhMucTinTuc,
    this.count,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
        id: json["id"],
        idDanhMuc: json["id_danh_muc"],
        tieuDe: json["tieu_de"],
        noiDung: json["noi_dung"],
        tacGia: json["tac_gia"],
        urlAnhDaiDien: json["url_anh_dai_dien"],
        isActive: json["is_active"],
        isDelete: json["is_delete"],
        nguoiTao: json["nguoi_tao"],
        nguoiCapNhat: json["nguoi_cap_nhat"],
        thoiGianTao: json["thoi_gian_tao"] == null
            ? null
            : DateTime.parse(json["thoi_gian_tao"]),
        thoiGianCapNhat: json["thoi_gian_cap_nhat"] == null
            ? null
            : DateTime.parse(json["thoi_gian_cap_nhat"]),
        isNoti: json["is_noti"],
        dinhKemTinTuc: json["dinh_kem_tin_tuc"] == null
            ? []
            : List<dynamic>.from(json["dinh_kem_tin_tuc"]!.map((x) => x)),
        danhMucTinTuc: json["danh_muc_tin_tuc"] == null
            ? null
            : Category.fromJson(json["danh_muc_tin_tuc"]),
        count:
            json["_count"] == null ? null : NewsCount.fromJson(json["_count"]),
      );
}

class Category {
  final String? id;
  final String? tenDanhMuc;
  final String? moTa;
  final bool? isActive;
  final bool? isDelete;
  final String? nguoiTao;
  final String? nguoiCapNhat;
  final DateTime? thoiGianTao;
  final DateTime? thoiGianCapNhat;

  Category({
    this.id,
    this.tenDanhMuc,
    this.moTa,
    this.isActive,
    this.isDelete,
    this.nguoiTao,
    this.nguoiCapNhat,
    this.thoiGianTao,
    this.thoiGianCapNhat,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        tenDanhMuc: json["ten_danh_muc"],
        moTa: json["mo_ta"],
        isActive: json["is_active"],
        isDelete: json["is_delete"],
        nguoiTao: json["nguoi_tao"],
        nguoiCapNhat: json["nguoi_cap_nhat"],
        thoiGianTao: json["thoi_gian_tao"] == null
            ? null
            : DateTime.parse(json["thoi_gian_tao"]),
        thoiGianCapNhat: json["thoi_gian_cap_nhat"] == null
            ? null
            : DateTime.parse(json["thoi_gian_cap_nhat"]),
      );
}

// Model cho field _count
class NewsCount {
  final int? tinTucView;

  NewsCount({this.tinTucView});

  factory NewsCount.fromJson(Map<String, dynamic> json) => NewsCount(
        tinTucView: json["tin_tuc_view"],
      );
}
