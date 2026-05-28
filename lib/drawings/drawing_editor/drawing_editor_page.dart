import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_editor_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_toolbar.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:provider/provider.dart';

class DrawingEditorPage extends StatefulWidget {
  const DrawingEditorPage({super.key});

  @override
  State<DrawingEditorPage> createState() => _DrawingEditorPageState();
}

class _DrawingEditorPageState extends State<DrawingEditorPage> {
  late FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).autofocus(_focusNode);
    String drawingName = Provider.of<DrawingsModel>(context, listen: false).drawing.name;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Provider.of<DrawingsModel>(context, listen: false).saveCurrentDrawing();
            Provider.of<DrawingsModel>(context, listen: false).clearUndoRedo();
            Navigator.maybePop(context);
          },
        ),
        title: Text('Drawing - $drawingName'),
        backgroundColor: Colors.grey.shade300,
        bottom: const PreferredSize(
          preferredSize: Size(2000, 40), 
          child: DrawingToolbar()
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: implement
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
              Provider.of<DrawingsModel>(context, listen: false).redo();
            } else {
              Provider.of<DrawingsModel>(context, listen: false).undo();
            }
          }
        },
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(5.0),
              child: DrawingEditorControl(),
          ),
        )
      ),
    );
  }
}