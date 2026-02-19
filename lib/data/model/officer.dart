import 'package:yoshlar/data/model/region.dart';
import 'package:yoshlar/data/service/api_client.dart';

class OfficerModel {
  final int id;
  final int? userId;
  final String? username;
  final String fullName;
  final String position;
  final RegionModel? region;
  final int? regionId;
  final String? phone;
  final String? photo;
  final int youthsCount;

  OfficerModel({
    required this.id,
    this.userId,
    this.username,
    required this.fullName,
    required this.position,
    this.region,
    this.regionId,
    this.phone,
    this.photo,
    this.youthsCount = 0,
  });

  factory OfficerModel.fromJson(Map<String, dynamic> json) {
    return OfficerModel(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      fullName: json['fullName'] ?? '',
      position: json['position'] ?? '',
      region: json['region'] != null
          ? RegionModel.fromJson(json['region'])
          : null,
      regionId: json['region_id'],
      phone: json['phone'],
      photo: ApiClient.resolveImageUrl(json['photo']),
      youthsCount: json['youthsCount'] ?? 0,
    );
  }
}
