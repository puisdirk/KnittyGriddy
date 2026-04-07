
import 'package:flutter/material.dart';

enum GridType {
  flat(label: 'Flat'),
  round(label: 'Round'),
  lace(label: 'Lace'),
  fromMiddle(label: 'Centre');

  final String label;
  const GridType({required this.label});

  @override
  String toString() => label;
}

@immutable
class PatternSettings {
  final int rows;
  final int columns;
  final GridType gridType;

  const PatternSettings({
    required this.rows,
    required this.columns,
    required this.gridType,
  });

  PatternSettings copyWith({
    int? rows,
    int? columns,
    GridType? gridType,
  }) {
    return PatternSettings(
      rows: rows ?? this.rows, 
      columns: columns ?? this.columns,
      gridType: gridType?? this.gridType,
    );
  }

  @override
  int get hashCode => rows.hashCode ^ columns.hashCode ^ gridType.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is PatternSettings &&
      rows == other.rows &&
      columns == other.columns &&
      gridType == other.gridType;

  List<String> getLeftSideRowIndicators() {
    switch (gridType) {
      case GridType.flat:
        // Only show even numbers, descending
        return List<String>.generate(rows, (row) => (row + 1).isEven ? '${row + 1}' : '-').reversed.toList();
      case GridType.round:
      case GridType.lace:
        return List<String>.generate(rows, (row) => '-');
      case GridType.fromMiddle:
        List<String> nums = [];
        if (rows.isEven) {
          int middle = rows ~/ 2;
          for (int row = middle; row > 0; row--) {
            nums.add('$row');
          }
          for (int row = 2; row <= middle + 1; row++) {
            nums.add('$row');
          }
        } else {
          int middle = (rows + 1) ~/ 2;
          for (int row = middle; row > 0; row--) {
            nums.add('$row');
          }
          for (int row = 2; row <= middle; row++) {
            nums.add('$row');
          }
        }
        return nums;
    }
  }

  List<String> getRightSideRowIndicators() {
    switch (gridType) {
      case GridType.flat:
        // Only show odd numbers
        return List<String>.generate(rows, (row) => (row + 1).isOdd ? '${row + 1}' : '-').reversed.toList();
      case GridType.round:
        return List<String>.generate(rows, (row) => '${row + 1}').reversed.toList();
      case GridType.lace:
        // only show odd rows
        List<String> nums = [];
        for (int row = 0; row < rows * 2; row++) {
          if ((row + 1).isOdd) {
            nums.add('${row + 1}');
          }
        }
        return nums.reversed.toList();
      case GridType.fromMiddle:
        List<String> nums = [];
        if (rows.isEven) {
          int middle = rows ~/ 2;
          for (int row = middle; row > 0; row--) {
            nums.add('$row');
          }
          for (int row = 2; row <= middle + 1; row++) {
            nums.add('$row');
          }
        } else {
          int middle = (rows + 1) ~/ 2;
          for (int row = middle; row > 0; row--) {
            nums.add('$row');
          }
          for (int row = 2; row <= middle; row++) {
            nums.add('$row');
          }
        }
        return nums;
    }
  }

  List<String> getTopSideColumnIndicators() {
    switch (gridType) {
      case GridType.flat:
      case GridType.round:
      case GridType.lace:
        // ltr
        return List<String>.generate(columns, (col) => '${columns - col}');
      case GridType.fromMiddle:
        List<String> nums = [];
        if (columns.isEven) {
          int middle = columns ~/ 2;
          for (int col = middle; col > 0; col--) {
            nums.add('$col');
          }
          for (int col = 2; col <= middle + 1; col++) {
            nums.add('$col');
          }
        } else {
          int middle = (columns + 1) ~/ 2;
          for (int col = middle; col > 0; col--) {
            nums.add('$col');
          }
          for (int col = 2; col <= middle; col++) {
            nums.add('$col');
          }
        }
        return nums;
    }
  }

  List<String> getBottomSideColumnIndicators() {
    switch (gridType) {
      case GridType.flat:
      case GridType.round:
      case GridType.lace:
        // ltr
        return List<String>.generate(columns, (col) => '${columns - col}');
      case GridType.fromMiddle:
        List<String> nums = [];
        if (columns.isEven) {
          int middle = columns ~/ 2;
          for (int col = middle; col > 0; col--) {
            nums.add('$col');
          }
          for (int col = 2; col <= middle + 1; col++) {
            nums.add('$col');
          }
        } else {
          int middle = (columns + 1) ~/ 2;
          for (int col = middle; col > 0; col--) {
            nums.add('$col');
          }
          for (int col = 2; col <= middle; col++) {
            nums.add('$col');
          }
        }
        return nums;
    }
  }
}