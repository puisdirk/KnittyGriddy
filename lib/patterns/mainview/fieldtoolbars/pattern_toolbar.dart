import 'package:fitted_scale/fitted_scale.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/nudge_control.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class PatternToolbar extends StatelessWidget {
  final PatternField? selectedField;
  final bool keyboardShiftDown;
  final bool keyboardControlDown;
  final bool fieldIsAtBottom;
  final bool fieldIsAtTop;
  final bool patternHasMultipleFields;
  final Widget? fieldToolbar;
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
    required this.patternHasMultipleFields,
    required this.fieldToolbar,
    required this.onAddField,
    required this.onCycleSelectedField,
    required this.onChanged,
    required this.onMoveBack,
    required this.onMoveForward,
    required this.onDuplicateSelectedField,
    super.key
  });

  bool _hasContent(PatternField field) {
    return (field.fieldType != PatternFieldType.drawing || (field as PatternDrawingField).drawing != null) &&
      (field.fieldType != PatternFieldType.knittingchart || (field as PatternChartField).chart != null) &&
      (field.fieldType != PatternFieldType.image || (field as PatternImageField).hasImage);
  }

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
            if (selectedField != null && _hasContent(selectedField!))
              Tooltip(
                message: 'Move field content',
                child: NudgeControl(
                  initialOffset: Offset(selectedField!.contentOffsetX, selectedField!.contentOffsetY), 
                  onNudged: (newOffset) => onChanged(selectedField!.abstractCopyWith(
                    contentOffsetX: newOffset.dx,
                    contentOffsetY: newOffset.dy)
                  ),
                ),
              ),
            if (selectedField != null && _hasContent(selectedField!))
              Tooltip(
                message: 'Opacity',
                child: Column(
                  children: [
                    Text('${((selectedField!.opacity / 255) * 100).toInt()}%', style: const TextStyle(fontSize: 10),),
                    Material(
                      child: FittedScale(
                        scale: .5,
                        child: Slider(
                          min: 0,
                          max: 255,
                          value: selectedField!.opacity as double, 
                          onChanged: (value) {
                            onChanged(selectedField!.abstractCopyWith(opacity: value.toInt()), storeForUndo: false);
                          },
                          onChangeEnd: (value) {
                            onChanged(selectedField!.abstractCopyWith(opacity: value.toInt()));
                          },
                        ),
                      ),
                    ),
                  ],
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
              )
          ],
        ),
      ),
    );
  }
}