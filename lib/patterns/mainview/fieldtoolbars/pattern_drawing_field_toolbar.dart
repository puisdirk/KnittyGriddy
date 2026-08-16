import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class PatternDrawingFieldToolbar extends StatefulWidget {
  final PatternDrawingField field;
  final void Function(PatternDrawingField newField) onChanged;

  const PatternDrawingFieldToolbar({
    required this.field,
    required this.onChanged,
    super.key
  });

  @override
  State<PatternDrawingFieldToolbar> createState() => _PatternDrawingFieldToolbarState();
}

class _PatternDrawingFieldToolbarState extends State<PatternDrawingFieldToolbar> {

  late PatternDrawingField field;

  @override
  void initState() {
    field = widget.field;

    super.initState();
  }

  void _updateField(PatternDrawingField newField) {
    setState(() => field = newField);
    widget.onChanged(newField);
  }

  @override
  void didUpdateWidget(covariant PatternDrawingFieldToolbar oldWidget) {
    field = widget.field;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Drawing:'),
        hspacing,
        DropdownButton<DrawingInfo>(
          autofocus: false, 
          focusColor: Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          underline: Container(),
          padding: const EdgeInsets.only(left: 10, right: 5),
          items: [
            const DropdownMenuItem(value: DrawingInfo.emptyDrawingInfo, child: Text('')),
            for (DrawingInfo drawingInfo in Provider.of<DrawingsModel>(context, listen: false).drawingInfos)
              DropdownMenuItem(value: drawingInfo, child: Text(drawingInfo.name))
          ], 
          onChanged: (value) async {
            if (value == DrawingInfo.emptyDrawingInfo) {
              _updateField(field.clearDrawing());
            } else {
              Drawing newDrawing = await Provider.of<DrawingsModel>(context, listen: false).getDrawing(value!);
              _updateField(field.copyWith(drawing: newDrawing.validate()));
            }
          },
          value: field.drawingInfo,
        ),
      ],
    );
  }
}