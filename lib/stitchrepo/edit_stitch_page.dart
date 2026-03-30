import 'dart:math';

import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_path.dart';
import 'package:knitty_griddy/stitchrepo/linked_range_text_field.dart';
import 'package:knitty_griddy/stitchrepo/range_text_field.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/stitchrepo/edit_stitch_paths_control.dart';
import 'package:knitty_griddy/stitchrepo/stitch_path_chooser.dart';

class EditStitchPage extends StatefulWidget {

  final StitchDefinition stitchDefinition;

  const EditStitchPage({
    required this.stitchDefinition,
    super.key
  });

  @override
  State<EditStitchPage> createState() => _EditStitchPageState();
}

class _EditStitchPageState extends State<EditStitchPage> {
  late StitchDefinition newStitchDefinition;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController abbreviationController;

  // If nothing is selected, row and column are null. If a cell is selected, both have a value. 
  // If a column is selected, row is null and column has a value.
  int? selectedRow;
  int? selectedColumn;

  @override
  void initState() {

    newStitchDefinition = widget.stitchDefinition.copyWith();

    nameController = TextEditingController(text: newStitchDefinition.name);
    nameController.addListener(_stitchNameChanged);

    descriptionController = TextEditingController(text: newStitchDefinition.description);
    descriptionController.addListener(_stitchDescriptionChanged);

    abbreviationController = TextEditingController(text: newStitchDefinition.abbreviation);
    abbreviationController.addListener(_abbreviationChanged);

    super.initState();
  }

  @override
  void dispose() {
    nameController.removeListener(_stitchNameChanged);
    nameController.dispose();

    descriptionController.removeListener(_stitchDescriptionChanged);
    descriptionController.dispose();

    abbreviationController.removeListener(_abbreviationChanged);
    abbreviationController.dispose();

    super.dispose();
  }

  void _stitchNameChanged() {
    setState(() {
      newStitchDefinition = newStitchDefinition.copyWith(name: nameController.text);
    });
  }

  void _stitchDescriptionChanged() {
    setState(() {
      newStitchDefinition = newStitchDefinition.copyWith(description: descriptionController.text);
    });
  }

  void _abbreviationChanged() {
    setState(() {
      newStitchDefinition = newStitchDefinition.copyWith(abbreviation: abbreviationController.text);
    });
  }

  void _changeRotation(double value) {
    double valueRad = _toRadians(value);
    List<KnittingSymbol> newSymbols = [];
    if (selectedRow == null) {
      for (int col = 0; col < newStitchDefinition.columns; col++) {
        if (col == selectedColumn) {
          newSymbols.add(newStitchDefinition.symbolAt(col).copyWith(rotation: valueRad));
        } else {
          newSymbols.add(newStitchDefinition.symbolAt(col));
        }
      }
    } else {
      for (int col = 0; col < newStitchDefinition.columns; col++) {
        if (col == selectedColumn) {
          List<KnittingSymbolPath> newPaths = [];
          for (int row = 0; row < newStitchDefinition.symbolAt(col).rows; row++) {
            if (row == selectedRow) {
              newPaths.add(newStitchDefinition.symbolPathAt(col, row).copyWith(rotation: valueRad));
            } else {
              newPaths.add(newStitchDefinition.symbolPathAt(col, row));
            }
          }
          newSymbols.add(newStitchDefinition.symbolAt(col).copyWith(paths: newPaths));
        } else {
          newSymbols.add(newStitchDefinition.symbolAt(col));
        }
      }
    }

    setState(() {
      newStitchDefinition = newStitchDefinition.copyWith(
        symbols: newSymbols
      );
    });
  }

  void _changeTranslationX(double value) {
    List<KnittingSymbol> newSymbols = [];
    if (selectedRow == null) {
      for (int col = 0; col < newStitchDefinition.columns; col++) {
        if (col == selectedColumn) {
          newSymbols.add(newStitchDefinition.symbolAt(col).copyWith(translation: Offset(value, newStitchDefinition.symbolAt(col).translation.dy)));
        } else {
          newSymbols.add(newStitchDefinition.symbolAt(col));
        }
      }
    } else {
      for (int col = 0; col < newStitchDefinition.columns; col++) {
        if (col == selectedColumn) {
          List<KnittingSymbolPath> newPaths = [];
          for (int row = 0; row < newStitchDefinition.symbolAt(col).rows; row++) {
            if (row == selectedRow) {
              newPaths.add(newStitchDefinition.symbolPathAt(col, row).copyWith(translation: Offset(value, newStitchDefinition.symbolPathAt(col, row).translation.dy)));
            } else {
              newPaths.add(newStitchDefinition.symbolPathAt(col, row));
            }
          }
          newSymbols.add(newStitchDefinition.symbolAt(col).copyWith(paths: newPaths));
        } else {
          newSymbols.add(newStitchDefinition.symbolAt(col));
        }
      }
    }

    setState(() {
      newStitchDefinition = newStitchDefinition.copyWith(
        symbols: newSymbols
      );
    });
  }

  void _changeTranslationY(double value) {
    List<KnittingSymbol> newSymbols = [];
    if (selectedRow == null) {
      for (int col = 0; col < newStitchDefinition.columns; col++) {
        if (col == selectedColumn) {
          newSymbols.add(newStitchDefinition.symbolAt(col).copyWith(translation: Offset(newStitchDefinition.symbolAt(col).translation.dx, value)));
        } else {
          newSymbols.add(newStitchDefinition.symbolAt(col));
        }
      }
    } else {
      for (int col = 0; col < newStitchDefinition.columns; col++) {
        if (col == selectedColumn) {
          List<KnittingSymbolPath> newPaths = [];
          for (int row = 0; row < newStitchDefinition.symbolAt(col).rows; row++) {
            if (row == selectedRow) {
              newPaths.add(newStitchDefinition.symbolPathAt(col, row).copyWith(translation: Offset(newStitchDefinition.symbolPathAt(col, row).translation.dx, value)));
            } else {
              newPaths.add(newStitchDefinition.symbolPathAt(col, row));
            }
          }
          newSymbols.add(newStitchDefinition.symbolAt(col).copyWith(paths: newPaths));
        } else {
          newSymbols.add(newStitchDefinition.symbolAt(col));
        }
      }
    }

    setState(() {
      newStitchDefinition = newStitchDefinition.copyWith(
        symbols: newSymbols
      );
    });
  }

  void _changeScale(double newX, double newY) {
    List<KnittingSymbol> newSymbols = [];
    if (selectedRow == null) {
      for (int col = 0; col < newStitchDefinition.columns; col++) {
        if (col == selectedColumn) {
          newSymbols.add(newStitchDefinition.symbolAt(col).copyWith(scale: Offset(newX, newY)));
        } else {
          newSymbols.add(newStitchDefinition.symbolAt(col));
        }
      }
    } else {
      for (int col = 0; col < newStitchDefinition.columns; col++) {
        if (col == selectedColumn) {
          List<KnittingSymbolPath> newPaths = [];
          for (int row = 0; row < newStitchDefinition.symbolAt(col).rows; row++) {
            if (row == selectedRow) {
              newPaths.add(newStitchDefinition.symbolPathAt(col, row).copyWith(scale: Offset(newX, newY)));
            } else {
              newPaths.add(newStitchDefinition.symbolPathAt(col, row));
            }
          }
          newSymbols.add(newStitchDefinition.symbolAt(col).copyWith(paths: newPaths));
        } else {
          newSymbols.add(newStitchDefinition.symbolAt(col));
        }
      }
    }

    setState(() {
      newStitchDefinition = newStitchDefinition.copyWith(
        symbols: newSymbols
      );
    });
  }

  double _toDegrees(double radians) {
    return (180/pi) * radians;
  }

  double _toRadians(double degrees) {
    return (pi / 180) * degrees;
  }

  @override
  Widget build(BuildContext context) {
    const double space = 14;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit stitch'),
        backgroundColor: Colors.grey.shade300,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Name:'),
                  const SizedBox(width: space,),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: nameController,
                    ),
                  ),
                  const SizedBox(width: space * 2,),
                  const Text('Abbreviation:'),
                  const SizedBox(width: space,),
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: abbreviationController,
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  const Text('Description:'),
                  const SizedBox(width: space,),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: descriptionController,
                    ),
                  )
                ],
              ),
              const SizedBox(height: space,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 24,),
                  EditStitchPathsControl(
                    stitchDefinition: newStitchDefinition,
                    selectedColumn: selectedColumn,
                    selectedRow: selectedRow,
                    onStitchDefinitionChanged: (newDefinition) => setState(() => newStitchDefinition = newDefinition.prune()),
                    onSelectionChanged: (newSelectedColumn, newSelectedRow) => setState(() { 
                      selectedColumn = newSelectedColumn; 
                      selectedRow = newSelectedRow;
                    }),
                  ),
                  const SizedBox(width: 24,),
                  Flexible(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            OutlinedButton(
                              child: const Text('Add shapes'),
                              onPressed: () async {
                                List<List<KnittingSymbolPath>> pathsPerColumn = await showDialog(context: context, builder: (context) => const StitchPathChooser());
                                if (pathsPerColumn.isNotEmpty) {
                                  List<KnittingSymbol> newSymbols = List.from(newStitchDefinition.symbols);
                                  for (int idx = 0; idx < pathsPerColumn.length; idx++) {
                                    if (newSymbols.length < idx) {
                                      newSymbols.add(KnittingSymbol(name: '', paths: pathsPerColumn[idx]));
                                    } else {
                                      newSymbols[idx] = newSymbols[idx].copyWith(
                                        paths: [...newSymbols[idx].paths, ...pathsPerColumn[idx]]
                                      );
                                    }
                                  }
                                  setState(() {
                                    newStitchDefinition = newStitchDefinition.copyWith(
                                      symbols: newSymbols
                                    );
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20,),
                        if (selectedColumn != null)
                          Row(
                            children: [
                              const SizedBox(
                                width: 100,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('Translation')
                                )
                              ),
                              const SizedBox(width: 10,),
                              RangeTextField(
                                min: -stitchCellWidth,
                                max: stitchCellWidth,
                                step: 0.1,
                                precision: 1,
                                onChanged: (value, _) { _changeTranslationX(value); }, 
                                value: selectedRow == null ? newStitchDefinition.symbol.translation.dx : newStitchDefinition.symbolPathAt(selectedColumn!, selectedRow!).translation.dx,
                              ),
                              const SizedBox(width: 10,),
                              RangeTextField(
                                min: -stitchCellHeight,
                                max: stitchCellHeight,
                                step: 0.1,
                                precision: 1,
                                onChanged: (value, _) { _changeTranslationY(value); }, 
                                value: selectedRow == null ? newStitchDefinition.symbol.translation.dy : newStitchDefinition.symbolPathAt(selectedColumn!, selectedRow!).translation.dy,
                              ),
                            ]
                          ),
                        const SizedBox(height: 10,),
                        if (selectedColumn != null)
                          Row(
                            children: [
                              const SizedBox(
                                width: 100,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('Rotation'),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              RangeTextField(
                                min: -360,
                                max: 360,
                                onChanged: (value, _) { _changeRotation(value); }, 
                                value: selectedRow == null ? _toDegrees(newStitchDefinition.symbol.rotation) : _toDegrees(newStitchDefinition.symbolPathAt(selectedColumn!, selectedRow!).rotation), 
                              ),
                            ],
                          ),
                        const SizedBox(height: 10,),
                        if (selectedColumn != null)
                          Row(
                            children: [
                              const SizedBox(
                                width: 100,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('Scale'),
                                ),
                              ),
                              const SizedBox(width: 10,),
                            LinkedRangeTextField(
                              min: 0.01,
                              max: stitchCellWidth,
                              step: 0.01,
                              precision: 2,
                              onChanged: _changeScale, 
                              value1: selectedRow == null ? newStitchDefinition.symbol.scale.dx : newStitchDefinition.symbolPathAt(selectedColumn!, selectedRow!).scale.dx,
                              value2: selectedRow == null ? newStitchDefinition.symbol.scale.dy : newStitchDefinition.symbolPathAt(selectedColumn!, selectedRow!).scale.dy,
                            ),
                            ],
                          ),
                      ],
                    )
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}