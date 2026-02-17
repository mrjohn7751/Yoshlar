class AuthUser {
  final int id;
  final String name;
  final String? username;
  final String email;
  final String? phone;
  final String role;
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
      officerId: json['officer_id'],
      officerPhoto: json['officer_photo'] == true,
      officerPhotoUrl: json['officer_photo_url'],
    );
  }

  bool get isRahbariyat => role == 'rahbariyat';
  bool get isMasul => role == 'masul';
}
