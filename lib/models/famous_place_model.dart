class FamousPlaceModel {
  final String name;
  final String type;
  final String description;
  FamousPlaceModel({
    required this.name,
    required this.type,
    required this.description,
  });
  factory FamousPlaceModel.fromMap(Map<String, dynamic> map, String name) {
    return FamousPlaceModel(
      name: name,
      type: map['type'] ?? '',
      description: map['description'] ?? '',
    );
  }
}