import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/controls/stitcheditor/symbol_part_controls.dart';
import 'package:knitty_griddy/controls/stitcheditor/symbol_transform_controls.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/model/undo_redo_manager.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/controls/stitcheditor/edit_stitch_parts_control.dart';
import 'package:knitty_griddy/stitchrepo/stitch_parts_chooser.dart';

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
  late FocusNode _focusNode;


  // If nothing is selected, row and column are null. If a cell is selected, both have a value. 
  // If a column is selected, row is null and column has a value.
  int? selectedRow;
  int? selectedColumn;

  final UndoRedoManager<StitchDefinition> _undoRedoManager = UndoRedoManager();

  @override
  void initState() {
    _focusNode = FocusNode();

    newStitchDefinition = widget.stitchDefinition.copyWith();
    _undoRedoManager.store(newStitchDefinition);

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
    _focusNode.dispose();

    nameController.removeListener(_stitchNameChanged);
    nameController.dispose();

    descriptionController.removeListener(_stitchDescriptionChanged);
    descriptionController.dispose();

    abbreviationController.removeListener(_abbreviationChanged);
    abbreviationController.dispose();

    super.dispose();
  }

  void _storeAndSetStitchDefinition(StitchDefinition stitchDefinition) {
    _undoRedoManager.store(stitchDefinition);
    _setStitchDefinition(stitchDefinition);
  }

  void _setStitchDefinition(StitchDefinition stitchDefinition) {
    setState(() {
      newStitchDefinition = stitchDefinition;
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
      _storeAndSetStitchDefinition(newStitchDefinition.copyWith(name: nameController.text));
  }

  void _stitchDescriptionChanged() {
      _storeAndSetStitchDefinition(newStitchDefinition.copyWith(description: descriptionController.text));
  }

  void _abbreviationChanged() {
    _storeAndSetStitchDefinition(newStitchDefinition.copyWith(abbreviation: abbreviationController.text));
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
          OutlinedButton(onPressed: () => print(newStitchDefinition), child: const Text('Print'))
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
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 24,),
                    EditStitchPartsControl(
                      stitchDefinition: newStitchDefinition,
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
                              OutlinedButton(
                                child: const Text('Add shapes'),
                                onPressed: () async {
                                  List<List<KnittingSymbolPart>> partsPerColumn = await showDialog(context: context, builder: (context) => const StitchPartsChooser());
                                  if (partsPerColumn.isNotEmpty) {
                                    List<KnittingSymbol> newSymbols = List.from(newStitchDefinition.symbols);
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
                                      newStitchDefinition.copyWith(
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
                              stitchDefinition: newStitchDefinition, 
                              symbolColumn: selectedColumn!, 
                              onChanged: (newDefinition) => _storeAndSetStitchDefinition(newDefinition,),
                            ),
                          if (selectedColumn != null && selectedRow != null)
                            SymbolPartControls(
                              stitchDefinition: newStitchDefinition,
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