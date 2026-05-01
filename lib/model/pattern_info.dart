
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
}