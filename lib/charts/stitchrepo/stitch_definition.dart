
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/model/knitting_symbol_parts.dart';

@immutable
class StitchDefinition {
  final String id;
  final String name;
  final String abbreviation;
  // Note: each entry is a part (column). Within each part, we allow overlaying 
  // multiple paths on top of each other to combine symbols. Each path can have a transform 
  // and the symbol from those paths has another transform.
  final List<KnittingSymbol> symbols;
  final String category;
  final String description;
  final int consumes;
  final int produces;

  const StitchDefinition({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.symbols,
    String? category,
    String? description,
    int? consumes,
    int? produces,
  }) : 
    category = category?? '', 
    description = description?? '',
    consumes = consumes?? 1,
    produces = produces?? 1;

  StitchDefinition copyWith({
    String? id,
    String? name,
    String? abbreviation,
    List<KnittingSymbol>? symbols,
    String? category,
    String? description,
    int? consumes,
    int? produces,
  }) {
    return StitchDefinition(
      id: id?? this.id,
      name: name?? this.name, 
      abbreviation: abbreviation?? this.abbreviation, 
      symbols: symbols?? this.symbols,
      category: category?? this.category,
      description: description?? this.description,
      consumes: consumes?? this.consumes,
      produces: produces?? this.produces,
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name, 
      'abbreviation': abbreviation, 
      'symbols': symbols.map((s) => s.toJson()).toList(),
      'category': category,
      'description': description,
      'consumes': consumes,
      'produces': produces,
    };
  }

  static StitchDefinition fromJson(Map<String, dynamic> json) {
    List<KnittingSymbol> symbols = [];
    List<Map<String, dynamic>> symbolObjects = (json['symbols'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> symbolObject in symbolObjects) {
      symbols.add(KnittingSymbol.fromJson(symbolObject));
    }

    return StitchDefinition(
      id: json['id'] as String,
      name: json['name'] as String, 
      abbreviation: json['abbreviation'] as String, 
      symbols: symbols,
      category: json['category'] as String,
      description: json['description'] as String,
      consumes: json['consumes'] as int,
      produces: json['produces'] as int,
    );
  }

  StitchDefinition rotateSymbol(int symbolColumn, double newrotationDegrees) {
    double rotationRad = MathUtitilies.toRadians(newrotationDegrees);
    List<KnittingSymbol> newSymbols = [];

    for (int col = 0; col < columns; col++) {
      if (col == symbolColumn) {
        newSymbols.add(symbolAt(col).copyWith(rotationRad: rotationRad));
      } else {
        newSymbols.add(symbolAt(col));
      }
    }

    return copyWith(
      symbols: newSymbols
    );
  }

  StitchDefinition translateSymbolX(int symbolColumn, double newX) {
    List<KnittingSymbol> newSymbols = [];
    for (int col = 0; col < columns; col++) {
      if (col == symbolColumn) {
        newSymbols.add(symbolAt(col).copyWith(translation: Offset(newX, symbolAt(col).translation.dy)));
      } else {
        newSymbols.add(symbolAt(col));
      }
    }

    return copyWith(
      symbols: newSymbols
    );
  }

  StitchDefinition translateSymbolY(int symbolColumn, double newY) {
    List<KnittingSymbol> newSymbols = [];
    for (int col = 0; col < columns; col++) {
      if (col == symbolColumn) {
        newSymbols.add(symbolAt(col).copyWith(translation: Offset(symbolAt(col).translation.dx, newY)));
      } else {
        newSymbols.add(symbolAt(col));
      }
    }

    return copyWith(
      symbols: newSymbols
    );
  }

  StitchDefinition scaleSymbol(int symbolColumn, double newX, double newY) {
    List<KnittingSymbol> newSymbols = [];

    for (int col = 0; col < columns; col++) {
      if (col == symbolColumn) {
        newSymbols.add(symbolAt(col).copyWith(scale: Offset(newX, newY)));
      } else {
        newSymbols.add(symbolAt(col));
      }
    }

    return copyWith(
      symbols: newSymbols
    );
  }

  StitchDefinition rotateSymbolPart(int symbolPartColumn, int symbolPartRow, double newrotationDegrees) {
    double rotationRad = MathUtitilies.toRadians(newrotationDegrees);
    List<KnittingSymbol> newSymbols = [];

    for (int col = 0; col < columns; col++) {
      if (col == symbolPartColumn) {
        List<KnittingSymbolPart> newParts = [];
        for (int row = 0; row < symbolAt(col).rows; row++) {
          if (row == symbolPartRow) {
            newParts.add(symbolPartAt(col, row).copyWith(rotationRad: rotationRad));
          } else {
            newParts.add(symbolPartAt(col, row));
          }
        }
        newSymbols.add(symbolAt(col).copyWith(parts: newParts));
      } else {
        newSymbols.add(symbolAt(col));
      }
    }

    return copyWith(
      symbols: newSymbols
    );
  }

  StitchDefinition translateSymbolPartX(int symbolPartColumn, int symbolPartRow, double newX) {
    List<KnittingSymbol> newSymbols = [];

    for (int col = 0; col < columns; col++) {
      if (col == symbolPartColumn) {
        List<KnittingSymbolPart> newParts = [];
        for (int row = 0; row < symbolAt(col).rows; row++) {
          if (row == symbolPartRow) {
            newParts.add(symbolPartAt(col, row).copyWith(translation: Offset(newX, symbolPartAt(col, row).translation.dy)));
          } else {
            newParts.add(symbolPartAt(col, row));
          }
        }
        newSymbols.add(symbolAt(col).copyWith(parts: newParts));
      } else {
        newSymbols.add(symbolAt(col));
      }
    }

    return copyWith(
      symbols: newSymbols
    );
  }

  StitchDefinition translateSymbolPartY(int symbolPartColumn, int symbolPartRow, double newY) {
    List<KnittingSymbol> newSymbols = [];

    for (int col = 0; col < columns; col++) {
      if (col == symbolPartColumn) {
        List<KnittingSymbolPart> newParts = [];
        for (int row = 0; row < symbolAt(col).rows; row++) {
          if (row == symbolPartRow) {
            newParts.add(symbolPartAt(col, row).copyWith(translation: Offset(symbolPartAt(col, row).translation.dx, newY)));
          } else {
            newParts.add(symbolPartAt(col, row));
          }
        }
        newSymbols.add(symbolAt(col).copyWith(parts: newParts));
      } else {
        newSymbols.add(symbolAt(col));
      }
    }

    return copyWith(
      symbols: newSymbols
    );
  }

  StitchDefinition scaleSymbolPart(int symbolPartColumn, int symbolPartRow, double newX, double newY) {
    List<KnittingSymbol> newSymbols = [];

    for (int col = 0; col < columns; col++) {
      if (col == symbolPartColumn) {
        List<KnittingSymbolPart> newParts = [];
        for (int row = 0; row < symbolAt(col).rows; row++) {
          if (row == symbolPartRow) {
            newParts.add(symbolPartAt(col, row).copyWith(scale: Offset(newX, newY)));
          } else {
            newParts.add(symbolPartAt(col, row));
          }
        }
        newSymbols.add(symbolAt(col).copyWith(parts: newParts));
      } else {
        newSymbols.add(symbolAt(col));
      }
    }

    return copyWith(
      symbols: newSymbols
    );
  }

  KnittingSymbol symbolAt(int column) {
    return symbols[column];
  }
  int get columns => symbols.length;
  int get maxRows {
    int r = 0;
    for (KnittingSymbol symbol in symbols) {
      if (symbol.rows > r) {
        r = symbol.rows;
      }
    }
    return r;
  }
  
  bool hasPartAt(int col, int row) {
    return col >= 0 && row >= 0 && columns > col && symbols[col].rows > row;
  }

  KnittingSymbolPart symbolPartAt(int col, int row) {
    if (columns > col && symbols[col].rows > row) {
      return symbols[col].parts[row];
    }
    return KnittingSymbolParts.blankPart;
  }

  bool passesFilter(String filter) =>
    name.toLowerCase().contains(filter.toLowerCase()) || abbreviation.toLowerCase().contains(filter.toLowerCase()) || 
    category.toLowerCase().contains(filter.toLowerCase()) || description.toLowerCase().contains(filter.toLowerCase());

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ abbreviation.hashCode ^ symbols.hashCode ^
    category.hashCode ^ description.hashCode ^ consumes.hashCode ^ produces.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is StitchDefinition &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      abbreviation == other.abbreviation &&
      listEquals(symbols, other.symbols) &&
      category == other.category &&
      description == other.description &&
      consumes == other.consumes &&
      produces == other.produces;

  bool sameContentAs(StitchDefinition other) {
    return this == other ||
      name == other.name &&
      abbreviation == other.abbreviation &&
      symbols == other.symbols &&
      category == other.category &&
      description == other.description &&
      consumes == other.consumes &&
      produces == other.produces;      
  }

  @override
  String toString() {
    String symbolsString = '';
    for (KnittingSymbol symbol in symbols) {
      symbolsString += '$symbol, ';
    }
    String defString = '''
StitchDefinition(
  name: '$name',
  abbreviation: '$abbreviation',
  symbols: [$symbolsString]''';

    if (category.isNotEmpty) {
      defString += '''category: '$category',''';
    }
    
    if (description.isNotEmpty) {
      defString += '''description: '$description',''';
    }
    
    if (consumes != 1) {
      defString += '''consumes: $consumes,''';
    }
    
    if (produces != 1) {
      defString += '''produces: $produces,''';
    }
    
    defString += ''')''';

    return defString;
  }
}