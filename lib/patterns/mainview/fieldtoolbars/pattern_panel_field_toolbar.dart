import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/panel_field_components/pattern_field_panel_style_dialog.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field_style.dart';
import 'package:knitty_griddy/utils/constants.dart';

class PatternPanelFieldToolbar extends StatelessWidget {
  final PatternPanelField field;
  final void Function(PatternPanelField newField) onChanged;

  const PatternPanelFieldToolbar({
    required this.field,
    required this.onChanged,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Style:'),
        hspacing,
        IconButton(
          onPressed: () async {
            PatternPanelFieldStyle? newStyle = await showDialog(
              context: context, builder: (context) => PatternFieldPanelStyleDialog(
                panelStyle: field.style,
              ),
            );
            if (newStyle != null && newStyle != field.style) {
              onChanged(field.copyWith(style: newStyle));
            }
          }, 
          icon: const Icon(Icons.palette)
        ),
      ],
    );
  }
}