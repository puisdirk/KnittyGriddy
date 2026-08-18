import 'package:fitted_scale/fitted_scale.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/nudge_control.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class PatternToolbar extends StatelessWidget {
  final PatternField? selectedField;
  final bool patternHasMultipleFields;
  final Widget? fieldToolbar;
  final void Function(PatternFieldType type) onAddField;
  final void Function(PatternField newField) onChanged;
  final void Function() onMoveBack;
  final void Function() onMoveForward;
  final void Function() onDuplicateSelectedField;

  const PatternToolbar({
    required this.selectedField,
    required this.patternHasMultipleFields,
    required this.fieldToolbar,
    required this.onAddField,
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
              message: 'Add text field',
              child: IconButton(
                onPressed: () => onAddField(PatternFieldType.texteditor),
                icon: const Icon(Icons.text_fields)
              ),
            ),
            Tooltip(
              message: 'Add knitting chart',
              child: IconButton(
                onPressed: () => onAddField(PatternFieldType.knittingchart),
                icon: const Icon(Icons.grid_on)
              ),
            ),
            Tooltip(
              message: 'Add drawing',
              child: IconButton(
                onPressed: () => onAddField(PatternFieldType.drawing),
                icon: const Icon(Icons.design_services)
              ),
            ),
            Tooltip(
              message: 'Add image',
              child: IconButton(
                onPressed: () => onAddField(PatternFieldType.image),
                icon: const Icon(Icons.photo_camera)
              ),
            ),
            Tooltip(
              message: 'Add panel',
              child: IconButton(
                onPressed: () => onAddField(PatternFieldType.panel),
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
            if (selectedField != null)
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
            if (selectedField != null && selectedField!.fieldType != PatternFieldType.panel)
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
                            onChanged(selectedField!.abstractCopyWith(opacity: value.toInt()));
                          }
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
                    message: 'Move back',
                    child: IconButton(
                      onPressed: onMoveBack, 
                      icon: const Icon(Icons.flip_to_back)
                    ),
                  ),
                  Tooltip(
                    message: 'Move foreward',
                    child: IconButton(
                      onPressed: onMoveForward, 
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