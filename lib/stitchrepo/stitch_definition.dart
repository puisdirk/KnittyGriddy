
import 'package:flutter/material.dart';

@immutable
class StitchDefinition {
  final String name;
  final String abbreviation;
  // Note: each entry in the outer list is a part (column). Within each part, we allow overlaying 
  // multiple icons on top of each other to combine symbols
  final List<List<IconData>> iconData;
  final String category;
  final String description;
  // TODO: if we want to record consumes/produces as in StitchMastery, here is where we would add that data

  const StitchDefinition({
    required this.name,
    required this.abbreviation,
    required this.iconData,
    String? category,
    String? description,
  }) : 
    category = category?? '', 
    description = description?? '';

  List<IconData> get icon => iconData.first;
  List<IconData> iconAt(int column) {
    return iconData[column - 1];
  }
  int get columns => iconData.length;

  @override
  int get hashCode => name.hashCode ^ abbreviation.hashCode ^ iconData.hashCode ^ category.hashCode ^ description.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is StitchDefinition &&
      name == other.name &&
      abbreviation == other.abbreviation &&
      iconData == other.iconData &&
      category == other.category &&
      description == other.description;
}