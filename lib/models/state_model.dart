class StateModel {
  final String name;
  StateModel({required this.name});
  factory StateModel.fromMap(Map<String, dynamic> map) {
    return StateModel(name: map['name'] ?? '');
  }
}