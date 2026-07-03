class CityModel {
  final String name;
  CityModel({required this.name});
  factory CityModel.fromMap(Map<String, dynamic> map) {
    return CityModel(name: map['name'] ?? '');
  }
}