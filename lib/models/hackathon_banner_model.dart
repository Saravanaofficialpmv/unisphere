import 'dart:convert';

class HackathonBannerModel {
  final dynamic id;
  final String title;
  final String posterImage;
  final String registrationLink;
  final DateTime uploadDate;
  final DateTime expiryDate;
  final bool isActive;

  HackathonBannerModel({
    required this.id,
    required this.title,
    required this.posterImage,
    required this.registrationLink,
    required this.uploadDate,
    required this.expiryDate,
    required this.isActive,
  });

  factory HackathonBannerModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return HackathonBannerModel(
      id: map['id'] ?? 1,
      title: map['title']?.toString() ?? '',
      posterImage: map['posterImage']?.toString() ?? map['poster_image']?.toString() ?? '',
      registrationLink: map['registrationLink']?.toString() ?? map['registration_link']?.toString() ?? '',
      uploadDate: parseDate(map['uploadDate'] ?? map['upload_date']),
      expiryDate: parseDate(map['expiryDate'] ?? map['expiry_date']),
      isActive: map['isActive'] ?? map['is_active'] ?? true,
    );
  }

  factory HackathonBannerModel.fromJson(String source) =>
      HackathonBannerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterImage': posterImage,
      'registrationLink': registrationLink,
      'uploadDate': uploadDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  String toJson() => json.encode(toMap());
}
