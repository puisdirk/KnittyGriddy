
import 'package:flutter/material.dart';

@immutable
class PatternSettings {
  final int rows;
  final int columns;

  const PatternSettings({
    required this.rows,
    required this.columns
  });

  PatternSettings copyWith({
    int? rows,
    int? columns,
  }) {
    return PatternSettings(
      rows: rows ?? this.rows, 
      columns: columns ?? this.columns
    );
  }

  @override
  int get hashCode => rows.hashCode ^ columns.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is PatternSettings &&
      rows == other.rows &&
      columns == other.columns;

}