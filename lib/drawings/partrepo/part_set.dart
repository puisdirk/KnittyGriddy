import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/utils/constants.dart';

class PartSet {

  final String id;
  final String name;
  final List<PartDrawing> _partDrawings;

  List<PartDrawing> get partDrawings => List.from(_partDrawings);

  const PartSet({
    required this.id,
    required this.name,
    required List<PartDrawing> parts,
  }) : _partDrawings = parts;

  PartSet copyWith({
    String? name,
    List<PartDrawing>? partDrawings,
  }) {
    return PartSet(
      id: id, 
      name: name?? this.name, 
      parts: partDrawings?? _partDrawings
    );
  }

  PartDrawing? partById(String id) {
    return _partDrawings.any((p) => p.id == id) ? _partDrawings.firstWhere((p) => p.id == id) : null;
  }

  Map<String, Object> toJson() {
    return {
      'objectversion': objectversion,
      'id': id,
      'name': name,
      'parts': _partDrawings.map((p) => p.toJson()).toList(),
    };
  }

  static PartSet fromJson(Map<String, dynamic> json) {
    List<PartDrawing> partDrawings = [];
    List<Map<String, dynamic>> partDrawingObjects = (json['parts'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> partDrawingObject in partDrawingObjects) {
      partDrawings.add(PartDrawing.fromJson(partDrawingObject));
    }

    return PartSet(
      id: json['id'] as String, 
      name: json['name'] as String, 
      parts: partDrawings
    );
  }

}