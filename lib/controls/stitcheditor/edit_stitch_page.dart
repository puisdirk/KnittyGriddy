import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/controls/stitcheditor/symbol_part_controls.dart';
import 'package:knitty_griddy/controls/stitcheditor/symbol_transform_controls.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/model/knitting_symbol_parts.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/undo_redo_manager.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/controls/stitcheditor/edit_stitch_parts_control.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_parts_chooser.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

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
  late StitchDefinition stitchDefinition;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController abbreviationController;
  late TextEditingController categoryController;
  late FocusNode _focusNode;


  // If nothing is selected, row and column are null. If a cell is selected, both have a value. 
  // If a column is selected, row is null and column has a value.
  int? selectedRow;
  int? selectedColumn;

  final UndoRedoManager<StitchDefinition> _undoRedoManager = UndoRedoManager();

  @override
  void initState() {
    _focusNode = FocusNode();

    stitchDefinition = widget.stitchDefinition.copyWith();
    _undoRedoManager.store(stitchDefinition);

    nameController = TextEditingController(text: stitchDefinition.name);
    nameController.addListener(_stitchNameChanged);

    descriptionController = TextEditingController(text: stitchDefinition.description);
    descriptionController.addListener(_stitchDescriptionChanged);

    abbreviationController = TextEditingController(text: stitchDefinition.abbreviation);
    abbreviationController.addListener(_abbreviationChanged);

    categoryController = TextEditingController(text: stitchDefinition.category);
    categoryController.addListener(_categoryChanged);

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();

    nameController.removeListener(_stitchNameChanged);
    nameController.dispose();

    descriptionController.removeListener(_stitchDescriptionChanged);
    descriptionController.dispose();

    abbreviationController.removeListener(_abbreviationChanged);
    abbreviationController.dispose();

    categoryController.removeListener(_categoryChanged);
    categoryController.dispose();

    super.dispose();
  }

  void _storeAndSetStitchDefinition(StitchDefinition stitchDefinition) {
    _undoRedoManager.store(stitchDefinition);
    _setStitchDefinition(stitchDefinition);
  }

  void _setStitchDefinition(StitchDefinition newStitchDefinition) {
    Provider.of<KnittyGriddyModel>(context, listen: false).updateStitchDefinition(olddef: stitchDefinition, newdef: newStitchDefinition);
    setState(() {
      stitchDefinition = newStitchDefinition;
    });
  }

  void _undo() {
    if (_undoRedoManager.canUndo()) {
      _setStitchDefinition(_undoRedoManager.undo()!);
    }
  }

  void _redo() {
    if (_undoRedoManager.canRedo()) {
      _setStitchDefinition(_undoRedoManager.redo()!);
    }
  }

  void _stitchNameChanged() {
      _storeAndSetStitchDefinition(stitchDefinition.copyWith(name: nameController.text));
  }

  void _stitchDescriptionChanged() {
      _storeAndSetStitchDefinition(stitchDefinition.copyWith(description: descriptionController.text));
  }

  void _abbreviationChanged() {
    _storeAndSetStitchDefinition(stitchDefinition.copyWith(abbreviation: abbreviationController.text));
  }

  void _categoryChanged() {
    _storeAndSetStitchDefinition(stitchDefinition.copyWith(category: categoryController.text));
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).autofocus(_focusNode);
    const double space = 14;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit stitch'),
        backgroundColor: Colors.grey.shade300,
        actions: [
          IconButton(
            onPressed: () {
              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: const Text("Are you sure"),
                content: const Text('Are you sure you want to delete the stitch? This action cannot be undone'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Provider.of<KnittyGriddyModel>(context, listen: false).deleteStitch(stitchDefinition);
                      },
                      child: const Text('Yes')),
                ],
              );
              // show the dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            }, 
            icon: const Icon(Icons.delete)
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (value) {
          if (value is KeyDownEvent && value.logicalKey == LogicalKeyboardKey.keyZ && 
            (HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed)) {
            if (HardwareKeyboard.instance.isShiftPressed) {
              _redo();
            } else {
              _undo();
            }
          }
        },
        child: SingleChildScrollView(
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
                    ),
                    const SizedBox(width: space * 2,),
                    const Text('Category:'),
                    const SizedBox(width: space,),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: categoryController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const Text('Description:'),
                    const SizedBox(width: space,),
                    SizedBox(
                      width: 400,
                      child: TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 24,),
                    EditStitchPartsControl(
                      stitchDefinition: stitchDefinition,
                      selectedColumn: selectedColumn,
                      selectedRow: selectedRow, 
                      onStitchDefinitionChanged: (newDefinition) => _storeAndSetStitchDefinition(newDefinition),
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
                              OutlinedButton.icon(
                                label: const Text('Add shapes'),
                                icon: const Icon(Symbols.category),
                                onPressed: () async {
                                  List<List<KnittingSymbolPart>> partsPerColumn = 
                                    await showDialog(context: context, builder: (context) => const StitchPartsChooser());
                                  if (partsPerColumn.isNotEmpty) {
                                    List<KnittingSymbol> newSymbols = List.from(stitchDefinition.symbols);
                                    // If there's just one blank in the existing parts, remove it
                                    if (newSymbols.length == 1 && 
                                      newSymbols.first.parts.length == 1 && 
                                      newSymbols.first.parts.first == KnittingSymbolParts.blankPart) {
                                      newSymbols = [];
                                    }
                                    for (int idx = 0; idx < partsPerColumn.length; idx++) {
                                      if (newSymbols.length <= idx) {
                                        newSymbols.add(KnittingSymbol(name: '', parts: partsPerColumn[idx]));
                                      } else {
                                        newSymbols[idx] = newSymbols[idx].copyWith(
                                          parts: [...newSymbols[idx].parts, ...partsPerColumn[idx]]
                                        );
                                      }
                                    }
                                    _storeAndSetStitchDefinition(
                                      stitchDefinition.copyWith(
                                        symbols: newSymbols
                                      )
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 20,),
                              TextButton.icon(
                                onPressed: _undoRedoManager.canUndo() ? _undo : null, 
                                label: const Text('Undo'),
                                icon: const Icon(Icons.undo),
                              ),
                              TextButton.icon(
                                onPressed: _undoRedoManager.canRedo() ? _redo : null, 
                                label: const Text('Redo'),
                                icon: const Icon(Icons.redo),
                              ),
                                                          ],
                          ),
                          const SizedBox(height: 20,),
                          if (selectedColumn != null && selectedRow == null)
                            SymbolTransformControls(
                              stitchDefinition: stitchDefinition, 
                              symbolColumn: selectedColumn!, 
                              onChanged: (newDefinition) => _storeAndSetStitchDefinition(newDefinition,),
                            ),
                          if (selectedColumn != null && selectedRow != null)
                            SymbolPartControls(
                              stitchDefinition: stitchDefinition,
                              symbolPartColumn: selectedColumn!,
                              symbolPartRow: selectedRow!,
                              onChanged: (newDefinition) => _storeAndSetStitchDefinition(newDefinition,),
                            )
                        ],
                      )
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}