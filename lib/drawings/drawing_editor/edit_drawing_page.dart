import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_editor_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_settings_dialog.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_toolbar.dart';
import 'package:knitty_griddy/drawings/export/export_drawing_page.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/undo_redo_manager.dart';
import 'package:provider/provider.dart';

class EditDrawingPage extends StatefulWidget {

  final AbstractDrawing drawing;

  const EditDrawingPage({
    required this.drawing, 
    super.key
  });

  @override
  State<EditDrawingPage> createState() => _EditDrawingPageState();
}

class _EditDrawingPageState extends State<EditDrawingPage> {
  late AbstractDrawing drawing;
//  late FocusNode _undoRedoFocusNode;

  final UndoRedoManager<AbstractDrawing> _undoRedoManager = UndoRedoManager();

  @override
  void initState() {
  //  _undoRedoFocusNode = FocusNode();

    drawing = widget.drawing;
    _undoRedoManager.store(drawing);

    super.initState();
  }

/*  @override
  void dispose() {
    _undoRedoFocusNode.dispose();
    super.dispose();
  }
*/

  void _storeAndSetDrawing(AbstractDrawing newDrawing) {
    _undoRedoManager.store(newDrawing);
    _setDrawing(newDrawing);
  }

  void _setDrawing(AbstractDrawing newDrawing) {
    Provider.of<DrawingsModel>(context, listen: false).updateDrawing(oldDrawing: drawing, newDrawing: newDrawing);
    setState(() => drawing = newDrawing);
  }

  void _undo() {
    if (_undoRedoManager.canUndo()) {
      _setDrawing(_undoRedoManager.undo()!);
    }
  }

  void _redo() {
    if (_undoRedoManager.canRedo()) {
      _setDrawing(_undoRedoManager.redo()!);
    }
  }

  @override
  Widget build(BuildContext context) {
    //FocusScope.of(context).autofocus(_undoRedoFocusNode);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            // Make sure infos are updated
            if (widget.drawing is Drawing) {
              Provider.of<DrawingsModel>(context, listen: false).saveCurrentDrawing();
            }
            _undoRedoManager.clear();
            Navigator.of(context).maybePop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.design_services), 
            hspacing, Text('${(widget.drawing is PartDrawing) ? 'Part Drawing' : 'Drawing'} - ${drawing.name}',),
          ],
        ),
        backgroundColor: Colors.grey.shade300,
        bottom: PreferredSize(
          preferredSize: const Size(2000, 40), 
          child: DrawingToolbar(
            canUndo: _undoRedoManager.canUndo(),
            canRedo: _undoRedoManager.canRedo(),
            undo: _undo,
            redo: _redo,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              AbstractDrawing? newDrawing = await showDialog(
                barrierDismissible: false,
                context: context, 
                builder: (context) => DrawingSettingsDialog(drawing: drawing)
              );

              if (newDrawing != null) {
                _storeAndSetDrawing(newDrawing);
              }
            }, 
            icon: const Icon(Icons.settings)
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ExportDrawingPage(drawing: drawing,))
            ),
            icon: const Icon(Icons.ios_share)
          ),
        ],
      ),
      body: /*KeyboardListener(
        focusNode: _undoRedoFocusNode, 
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
        child:*/ Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
              child: DrawingEditorControl(
                drawing: drawing,
                onDrawingChanged: (newDrawing) => _storeAndSetDrawing(newDrawing),
                onUndo: _undo,
                onRedo: _redo,
              ),
          ),
        )
      //),
    );
  }
}