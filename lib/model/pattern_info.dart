
class PatternInfo {
  final String id;
  final String name;
  final String description;

  const PatternInfo({
    required this.id,
    required this.name,
    this.description = '',
  });

  PatternInfo copyWith({
    String? name,
    String? description
  }) {
    return PatternInfo(
      id: id, 
      name: name?? this.name,
      description: description?? this.description,
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  static PatternInfo fromJson(Map<String, dynamic> json) {
    return PatternInfo(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String
    );
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is PatternInfo &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description;

}