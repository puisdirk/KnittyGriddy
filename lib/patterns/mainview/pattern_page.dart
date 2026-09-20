import 'package:flutter/material.dart';
import 'package:knitty_griddy/common/undo_redo_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/pattern_editor.dart';
import 'package:knitty_griddy/patterns/mainview/pattern_linker.dart';
import 'package:knitty_griddy/patterns/mainview/pattern_page_mode.dart';
import 'package:knitty_griddy/patterns/mainview/pattern_settings_dialog.dart';
import 'package:knitty_griddy/patterns/mainview/pattern_viewer.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/patterns_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/undo_redo_manager.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class PatternPage extends StatefulWidget {
  final KnittingPattern knittingPattern;

  const PatternPage({
    required this.knittingPattern,
    super.key
  });

  @override
  State<PatternPage> createState() => _PatternPageState();
}

class _PatternPageState extends State<PatternPage> {
  late KnittingPattern stateKnittingPattern;
  late PatternPageMode patternPageMode;

  final UndoRedoManager<KnittingPattern> _undoRedoManager = UndoRedoManager();

  @override
  void initState() {
    stateKnittingPattern = widget.knittingPattern;
    _undoRedoManager.store(stateKnittingPattern);

    patternPageMode = widget.knittingPattern.fields.length > 2 ? 
      PatternPageMode.view : PatternPageMode.edit;

    super.initState();
  }

  void _storeAndSetKnittingPattern(KnittingPattern newPattern, {bool? storeForUndo}) {
    if (storeForUndo != false &&_undoRedoManager.lastState != newPattern) {
      _undoRedoManager.store(newPattern);
    }
    _setKnittingPattern(newPattern);

  }

  void _setKnittingPattern(KnittingPattern newPattern) {
    Provider.of<PatternsModel>(context, listen: false).updateKnittingPattern(
      oldPattern: stateKnittingPattern, 
      newPattern: newPattern
    );
    setState(() {
      stateKnittingPattern = newPattern;
    });
  }

  void _undo() {
    if (_undoRedoManager.canUndo()) {
      _setKnittingPattern(_undoRedoManager.undo()!);
    }
  }

  void _redo() {
    if (_undoRedoManager.canRedo()) {
      _setKnittingPattern(_undoRedoManager.redo()!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Provider.of<PatternsModel>(context, listen: false).saveCurrentPattern(clear: true);
            _undoRedoManager.clear();
            Navigator.maybePop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_mosaic_outlined),
            hspacing,
            Text('Pattern - ${stateKnittingPattern.name}')
          ],
        ),
        backgroundColor: Colors.grey.shade300,
        bottom: PreferredSize(
          preferredSize: const Size(2000, 40), 
          child: Visibility(
            visible: patternPageMode == PatternPageMode.edit, 
            maintainSize: true, maintainState: true, maintainAnimation: true,
            child: UndoRedoToolbar(
              canUndo: _undoRedoManager.canUndo(),
              canRedo: _undoRedoManager.canRedo(),
              undo: _undo,
              redo: _redo,
            ),
          ),
        ),
        actions: [
          SegmentedButton<PatternPageMode>(
            emptySelectionAllowed: false,
            multiSelectionEnabled: false,
            segments: [
              const ButtonSegment(value: PatternPageMode.edit, icon: Icon(Icons.edit)),
              const ButtonSegment(value: PatternPageMode.view, icon: Icon(Icons.visibility)),
              if (stateKnittingPattern.textEditorFields.length > 1)
                const ButtonSegment(value: PatternPageMode.links, icon: Icon(Symbols.conversion_path)),
            ], 
            selected: {patternPageMode},
            onSelectionChanged: (newMode) => setState(() => patternPageMode = newMode.first),
          ),
          const SizedBox(width: 30,),
          Visibility(
            visible: patternPageMode == PatternPageMode.edit,
            maintainSize: true,maintainAnimation: true,maintainState: true,
            child: Tooltip(
              message: 'Pattern settings',
              child: IconButton(
                onPressed: () async {
                  KnittingPattern? newPattern = await showDialog(
                    barrierDismissible: false,
                    context: context, 
                    builder: (context) => PatternSettingsDialog(pattern: stateKnittingPattern),
                  );
                  if (newPattern != null) {
                    _storeAndSetKnittingPattern(newPattern);
                  }
                }, 
                icon: const Icon(Icons.settings),
              ),
            ),
          ),
          hspacing,
        ],
      ),
      body: patternPageMode == PatternPageMode.edit ? PatternEditor(
        pattern: stateKnittingPattern,
        undoRedoManager: _undoRedoManager,
        onChanged: _storeAndSetKnittingPattern,
      ) :
      patternPageMode == PatternPageMode.view ? PatternViewer(pattern: stateKnittingPattern) :
      PatternLinker(
        pattern: stateKnittingPattern,
        onChanged: _storeAndSetKnittingPattern
      )
    );
  }
}