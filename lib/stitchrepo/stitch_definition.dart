
import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_path.dart';
import 'package:knitty_griddy/model/knitting_symbol_paths.dart';
import 'package:knitty_griddy/model/knitting_symbols.dart';

@immutable
class StitchDefinition {
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
  final bool custom;

  const StitchDefinition({
    required this.name,
    required this.abbreviation,
    required this.symbols,
    String? category,
    String? description,
    int? consumes,
    int? produces,
    bool? custom,
  }) : 
    category = category?? '', 
    description = description?? '',
    consumes = consumes?? 1,
    produces = produces?? 1,
    custom = custom?? false;

  StitchDefinition copyWith({
    String? name,
    String? abbreviation,
    List<KnittingSymbol>? symbols,
    String? category,
    String? description,
    int? consumes,
    int? produces,
    bool? custom,
  }) {
    return StitchDefinition(
      name: name?? this.name, 
      abbreviation: abbreviation?? this.abbreviation, 
      symbols: symbols?? this.symbols,
      category: category?? this.category,
      description: description?? this.description,
      consumes: consumes?? this.consumes,
      produces: produces?? this.produces,
      custom: custom?? this.custom,
    );
  }

  StitchDefinition prune() {
    StitchDefinition newDefinition = copyWith(
      symbols: symbols.map((symbol) =>
        symbol == KnittingSymbols.blank ? symbol : symbol.copyWith(
          paths: symbol.paths.length == 1 ? symbol.paths : symbol.paths.where((p) => p != KnittingSymbolPaths.blankPath).toList()
        )
      ).toList()
    );

    if (newDefinition.columns == 0) {
      newDefinition = newDefinition.copyWith(
        symbols: [KnittingSymbols.blank]
      );
    }

    return newDefinition;
  }

  KnittingSymbol get symbol => symbols.first;
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
  
  KnittingSymbolPath symbolPathAt(int col, int row) {
    if (columns > col && symbols[col].rows > row) {
      return symbols[col].paths[row];
    }
    return KnittingSymbolPaths.blankPath;
  }

  bool passesFilter(String filter) =>
    name.toLowerCase().contains(filter.toLowerCase()) || abbreviation.toLowerCase().contains(filter.toLowerCase()) || 
    category.toLowerCase().contains(filter.toLowerCase()) || description.toLowerCase().contains(filter.toLowerCase());

  @override
  int get hashCode => name.hashCode ^ abbreviation.hashCode ^ symbols.hashCode ^ 
    category.hashCode ^ description.hashCode ^ consumes.hashCode ^ produces.hashCode ^ custom.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is StitchDefinition &&
      name == other.name &&
      abbreviation == other.abbreviation &&
      symbols == other.symbols &&
      category == other.category &&
      description == other.description &&
      consumes == other.consumes &&
      produces == other.produces &&
      custom == other.custom;
}