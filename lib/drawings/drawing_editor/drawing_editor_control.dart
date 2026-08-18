import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_viewer.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_commands_list.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';

class DrawingEditorControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final void Function(AbstractDrawing newDrawing) onDrawingChanged;
  final void Function() onUndo;
  final void Function() onRedo;

  const DrawingEditorControl({
    required this.drawing,
    required this.onDrawingChanged,
    required this.onUndo,
    required this.onRedo,
    super.key
  });

  @override
  State<DrawingEditorControl> createState() => _DrawingEditorControlState();
}

class _DrawingEditorControlState extends State<DrawingEditorControl> {
  String? selectedCommandId;
  late FocusNode _shortcutsFocusNode;

  @override
  void initState() {
    _shortcutsFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _shortcutsFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).autofocus(_shortcutsFocusNode);

    return KeyboardListener(
      focusNode: _shortcutsFocusNode,
      autofocus: true,
      onKeyEvent: (value) {
        if (value is KeyDownEvent && value.logicalKey == LogicalKeyboardKey.keyD && 
          (HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed)) {
            if (selectedCommandId != null) {
              DrawingCommand? original = widget.drawing.commandById(selectedCommandId!);
              if (original != null) {
                String newId = const UuidV4Gen().get();
                String newLabel = widget.drawing.nextLabelForType(original);
                widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                  commands: [
                    ...widget.drawing.commands, 
                    original.abstractCopyWith(
                      id: newId,
                      label: newLabel,
                      initiallyOpen: true,
                    )
                  ]
                ));
                setState(() => selectedCommandId = newId);
              }
            }
        }

        if (value is KeyDownEvent && value.logicalKey == LogicalKeyboardKey.keyZ && 
          (HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed)) {
          if (HardwareKeyboard.instance.isShiftPressed) {
            widget.onRedo();
          } else {
            widget.onUndo();
          }
        }
      },
      child: Row(
        children: [
          Expanded(
            child: DrawingViewer(
              drawing: widget.drawing, 
              selectedCommandId: selectedCommandId,
            )
          ),
          SizedBox(
            width: 410,
            child: DrawingCommandsList(
              drawing: widget.drawing,
              selectedCommandId: selectedCommandId,
              onSelect: (id) => setState(() => selectedCommandId = id),
              onDrawingChanged: widget.onDrawingChanged,
            )
          ),
        ],
      ),
    );
  }
}