class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final int youthsCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.youthsCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      youthsCount: json['youthsCount'] ?? 0,
    );
  }
}
