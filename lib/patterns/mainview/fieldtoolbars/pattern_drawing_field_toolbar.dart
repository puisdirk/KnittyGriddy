import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_chooser/drawing_chooser_view.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/drawing_picker.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:provider/provider.dart';

class PatternDrawingFieldToolbar extends StatelessWidget {
  final PatternDrawingField field;
  final void Function(PatternDrawingField newField) onChanged;

  const PatternDrawingFieldToolbar({
    required this.field,
    required this.onChanged,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () async {
            DrawingInfo? newDrawingInfo = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const DrawingPicker(),
            );

            if (newDrawingInfo != null && newDrawingInfo != DrawingInfo.emptyDrawingInfo) {
              if (context.mounted) {
                Drawing newDrawing = await Provider.of<DrawingsModel>(context, listen: false).getDrawing(newDrawingInfo);
                onChanged(field.copyWith(drawing: newDrawing.validate()));
              }
            }
          }, 
          icon: const Icon(Icons.design_services, color: Colors.black,),
          label: field.drawing == null ? 
            const Text('No drawing selected', style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic)) : 
            Text(field.drawing!.name, style: const TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}