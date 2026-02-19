import 'package:yoshlar/data/model/category.dart';
import 'package:yoshlar/data/model/officer.dart';
import 'package:yoshlar/data/model/region.dart';
import 'package:yoshlar/data/service/api_client.dart';

class UserModel {
  final int? id;
  final String name;
  final String? phone;
  final String? image;
  final String birthDate;
  final String gender;
  final String location;
  final RegionModel? region;
  final int? regionId;
  final String status; // Ta'lim/Ish
  final String activity; // O'qimoqda/Ishsiz
  final String riskLevel; // O'rta, Yuqori, Past
  final List<String> tags;
  final List<String> categories;
  final List<CategoryModel> categoryModels;
  final List<OfficerModel> officers;
  final int activitiesCount;
  final String? description;

  UserModel({
    this.id,
    required this.name,
    this.phone,
    this.image,
    required this.birthDate,
    required this.gender,
    required this.location,
    this.region,
    this.regionId,
    required this.status,
    required this.activity,
    required this.riskLevel,
    required this.tags,
    required this.categories,
    this.categoryModels = const [],
    this.officers = const [],
    this.activitiesCount = 0,
    this.description,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final categoriesData = json['categories'] as List<dynamic>? ?? [];
    final officersData = json['officers'] as List<dynamic>? ?? [];
    final tagsData = json['tags'] as List<dynamic>? ?? [];

    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      image: ApiClient.resolveImageUrl(json['image']),
      birthDate: json['birthDate'] ?? '',
      gender: json['gender'] ?? '',
      location: json['location'] ?? '',
      region: json['region'] != null
          ? RegionModel.fromJson(json['region'])
          : null,
      regionId: json['region_id'],
      status: json['status'] ?? '',
      activity: json['activity'] ?? '',
      riskLevel: json['riskLevel'] ?? '',
      tags: tagsData.map((e) => e.toString()).toList(),
      categories: categoriesData.map((e) => (e['name'] ?? '').toString()).toList(),
      categoryModels: categoriesData
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      officers: officersData
          .map((e) => OfficerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      activitiesCount: json['activitiesCount'] ?? 0,
      description: json['description'],
    );
  }
}
