import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_editor_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_toolbar.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_operation_exception.dart';
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
  late FocusNode _focusNode;
  bool showToolbarContents = false;

  final UndoRedoManager<AbstractDrawing> _undoRedoManager = UndoRedoManager();

  @override
  void initState() {
    _focusNode = FocusNode();

    drawing = widget.drawing;
    _undoRedoManager.store(drawing);

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
    FocusScope.of(context).autofocus(_focusNode);

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
            Text('${(widget.drawing is PartDrawing) ? 'Part Drawing' : 'Drawing'} - ${drawing.name}'),
            hspacing,
            if (!showToolbarContents)
              IconButton(
                onPressed: () => setState(() => showToolbarContents = true),
                icon: const Icon(Icons.edit)
              ),
          ],
        ),
        backgroundColor: Colors.grey.shade300,
        bottom: PreferredSize(
          preferredSize: Size(2000, showToolbarContents ? 160 : 40), 
          child: DrawingToolbar(
            drawing: drawing,
            showToolbarContents: showToolbarContents,
            canUndo: _undoRedoManager.canUndo(),
            canRedo: _undoRedoManager.canRedo(),
            undo: _undo,
            redo: _redo,
            onDrawingChanged: (newDrawing) {
              setState(() => showToolbarContents = false);
              if (newDrawing != null) {
                _storeAndSetDrawing(newDrawing.validate());
              }
            }
          ),
        ),
        actions: [
          IconButton( 
            onPressed: () async {
              try {
                await Provider.of<DrawingsModel>(context, listen: false).exportDrawing(drawing);
              } on DrawingOperationException catch(e) {
                if (context.mounted) {
                  showDialog(context: context, builder: (context) => 
                    AlertDialog(
                      content: SizedBox(width: 400, height: 50, child: Text(e.message)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), 
                          child: const Text('Close'),
                        ),
                      ],
                    )  
                  );
                }
              }
            }, 
            icon: const Icon(Icons.ios_share)
          )
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
              child: DrawingEditorControl(
                drawing: drawing,
                onDrawingChanged: (newDrawing) => _storeAndSetDrawing(newDrawing),
              ),
          ),
        )
      ),
    );
  }
}