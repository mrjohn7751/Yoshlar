class AuthUser {
  final int id;
  final String name;
  final String? username;
  final String email;
  final String? phone;
  final String role;
  final bool photo;
  final String? photoUrl;
  final int? officerId;
  final bool officerPhoto;
  final String? officerPhotoUrl;

  AuthUser({
    required this.id,
    required this.name,
    this.username,
    required this.email,
    this.phone,
    required this.role,
    this.photo = false,
    this.photoUrl,
    this.officerId,
    this.officerPhoto = false,
    this.officerPhotoUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'],
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      photo: json['photo'] == true,
      photoUrl: json['photo_url'],
      officerId: json['officer_id'],
      officerPhoto: json['officer_photo'] == true,
      officerPhotoUrl: json['officer_photo_url'],
    );
  }

  /// Profilga mos rasm URL - avval user photo, keyin officer photo
  String? get displayPhotoUrl => photoUrl ?? officerPhotoUrl;
  bool get hasDisplayPhoto => photo || officerPhoto;

  bool get isRahbariyat => role == 'rahbariyat';
  bool get isMasul => role == 'masul';
}
