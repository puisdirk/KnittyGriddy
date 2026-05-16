import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';

class StitchSet {

  final String id;
  final String name;
  final List<StitchDefinition> _definitions;

  List<StitchDefinition> get definitions => List.from(_definitions);

  const StitchSet({
    required this.id,
    required this.name,
    required List<StitchDefinition> stitchDefinitions,
  }) : _definitions = stitchDefinitions;

  StitchSet copyWith({
    String? name,
    List<StitchDefinition>? stitchDefinitions,
  }) {
    return StitchSet(
      id: id,
      name: name?? this.name, 
      stitchDefinitions: stitchDefinitions?? _definitions
    );
  }

  StitchDefinition? stitchDefinitionById(String id) {
    return _definitions.any((def) => def.id == id) ? _definitions.firstWhere((def) => def.id == id) : null;
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'defs': _definitions.map((def) => def.toJson()).toList(),
    };
  }

  static StitchSet fromJson(Map<String, dynamic> json) {
    List<StitchDefinition> defs = [];
    List<Map<String, dynamic>> defObjects = (json['defs'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> defObject in defObjects) {
      defs.add(StitchDefinition.fromJson(defObject));
    }

    return StitchSet(
      id: json['id'],
      name: json['name'], 
      stitchDefinitions: defs
    );
  }

}