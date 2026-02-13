class RegionModel {
  final int id;
  final String name;
  final int youthsCount;

  RegionModel({
    required this.id,
    required this.name,
    this.youthsCount = 0,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'],
      name: json['name'] ?? '',
      youthsCount: json['youthsCount'] ?? 0,
    );
  }
}
