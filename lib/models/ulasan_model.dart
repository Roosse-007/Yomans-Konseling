class UlasanModel {
  final int id;
  final int bookingId;
  final int dokterId;
  final int userId;
  final int rating;

  final String komentar;
  final String nama;
  final String createdAt;
  final String fotoProfil;

  UlasanModel({
    required this.id,
    required this.bookingId,
    required this.dokterId,
    required this.userId,
    required this.rating,
    required this.komentar,
    required this.nama,
    required this.createdAt,
    required this.fotoProfil,
  });

  factory UlasanModel.fromJson(Map<String, dynamic> json) {
    return UlasanModel(
      id: int.parse(json["id"].toString()),
      bookingId: int.parse(json["booking_id"].toString()),
      dokterId: int.parse(json["dokter_id"].toString()),
      userId: int.parse(json["user_id"].toString()),
      rating: int.parse(json["rating"].toString()),
      komentar: json["komentar"] ?? "",
      nama: json["nama"] ?? "",
      createdAt: json["created_at"] ?? "",
      fotoProfil: json["foto_profil"] ?? "",
    );
  }
}