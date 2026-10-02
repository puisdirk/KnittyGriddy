import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class PatternToolbar extends StatelessWidget {
  final PatternField? selectedField;
  final bool keyboardShiftDown;
  final bool keyboardControlDown;
  final bool fieldIsAtBottom;
  final bool fieldIsAtTop;
  final bool showContentControls;
  final bool patternHasMultipleFields;
  final Widget? fieldToolbar;
  final void Function() onToggleShowContentControls;
  final void Function(PatternFieldType type) onAddField;
  final void Function(PatternFieldType type, bool reverse) onCycleSelectedField;
  final void Function(PatternField newField, {bool? storeForUndo}) onChanged;
  final void Function(bool allTheWay) onMoveBack;
  final void Function(bool allTheWay) onMoveForward;
  final void Function() onDuplicateSelectedField;

  const PatternToolbar({
    required this.selectedField,
    required this.keyboardShiftDown,
    required this.keyboardControlDown,
    required this.fieldIsAtBottom,
    required this.fieldIsAtTop,
    required this.showContentControls,
    required this.patternHasMultipleFields,
    required this.fieldToolbar,
    required this.onToggleShowContentControls,
    required this.onAddField,
    required this.onCycleSelectedField,
    required this.onChanged,
    required this.onMoveBack,
    required this.onMoveForward,
    required this.onDuplicateSelectedField,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Tooltip(
              message: keyboardControlDown ? keyboardShiftDown ? 'Select previous' : 'Select next' : 'Add text field',
              child: IconButton(
                onPressed: () => keyboardControlDown ? onCycleSelectedField(PatternFieldType.texteditor, keyboardShiftDown) : onAddField(PatternFieldType.texteditor),
                icon: const Icon(Icons.text_fields)
              ),
            ),
            Tooltip(
              message: keyboardControlDown ? keyboardShiftDown ? 'Select previous' : 'Select next' : 'Add knitting chart',
              child: IconButton(
                onPressed: () => keyboardControlDown ? onCycleSelectedField(PatternFieldType.knittingchart, keyboardShiftDown) : onAddField(PatternFieldType.knittingchart),
                icon: const Icon(Icons.grid_on)
              ),
            ),
            Tooltip(
              message: keyboardControlDown ? keyboardShiftDown ? 'Select previous' : 'Select next' : 'Add drawing',
              child: IconButton(
                onPressed: () => keyboardControlDown ? onCycleSelectedField(PatternFieldType.drawing, keyboardShiftDown) : onAddField(PatternFieldType.drawing),
                icon: const Icon(Icons.design_services)
              ),
            ),
            Tooltip(
              message: keyboardControlDown ? keyboardShiftDown ? 'Select previous' : 'Select next' : 'Add image',
              child: IconButton(
                onPressed: () => keyboardControlDown ? onCycleSelectedField(PatternFieldType.image, keyboardShiftDown) : onAddField(PatternFieldType.image),
                icon: const Icon(Icons.photo_camera)
              ),
            ),
            Tooltip(
              message: keyboardControlDown ? keyboardShiftDown ? 'Select previous' : 'Select next' : 'Add panel',
              child: IconButton(
                onPressed: () => keyboardControlDown ? onCycleSelectedField(PatternFieldType.panel, keyboardShiftDown) : onAddField(PatternFieldType.panel),
                icon: const Icon(Symbols.rectangle_add)
              ),
            ),
            const Spacer(),
            if (fieldToolbar != null)
              fieldToolbar!,
            if (fieldToolbar != null)
              const Spacer(),
            if (selectedField != null)
              Tooltip(
                message: 'Duplicate',
                child: IconButton(
                  iconSize: 18,
                  onPressed: onDuplicateSelectedField, 
                  icon: const Icon(Icons.content_copy)
                ),
              ),
            if (selectedField != null && patternHasMultipleFields)
              Row(
                children: [
                  Tooltip(
                    message: keyboardShiftDown ? 'Move to bottom' : 'Move back',
                    child: IconButton(
                      onPressed: fieldIsAtBottom ? null : () => onMoveBack(keyboardShiftDown), 
                      icon: const Icon(Icons.flip_to_back)
                    ),
                  ),
                  Tooltip(
                    message: keyboardShiftDown ? 'Move to front' : 'Move foreward',
                    child: IconButton(
                      onPressed: fieldIsAtTop ? null : () => onMoveForward(keyboardShiftDown), 
                      icon: const Icon(Icons.flip_to_front)
                    ),
                  ),
                  hspacing,
                ],
              ),
            if (selectedField != null && selectedField!.hasContent)
              GestureDetector(
                onTap: onToggleShowContentControls,
                child: Icon(showContentControls ? Icons.arrow_drop_down : Icons.arrow_left),
              ),
          ],
        ),
      ),
    );
  }
}