import 'dart:convert';

import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_chart_field_control.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_drawing_field_control.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_image_field_control.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_panel_field_control.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_text_editor_field_control.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';

class PreviewPatternFieldControl extends StatefulWidget {
  final PatternField field;

  const PreviewPatternFieldControl({
    required this.field,
    super.key
  });

  @override
  State<PreviewPatternFieldControl> createState() => _PreviewPatternFieldControlState();
}

class _PreviewPatternFieldControlState extends State<PreviewPatternFieldControl> {
  late FleatherController controller;

  @override
  void initState() {
    if (widget.field.fieldType == PatternFieldType.texteditor) {
      ParchmentDocument doc = ParchmentDocument.fromJson(jsonDecode((widget.field as PatternTextEditorField).docContents));
      controller = FleatherController(document: doc);
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PreviewPatternFieldControl oldWidget) {
    if (oldWidget.field.fieldType == PatternFieldType.texteditor) {
      controller.dispose();
    }
    
    if (widget.field.fieldType == PatternFieldType.texteditor) {
      ParchmentDocument doc = ParchmentDocument.fromJson(jsonDecode((widget.field as PatternTextEditorField).docContents));
      controller = FleatherController(document: doc);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (widget.field.fieldType == PatternFieldType.texteditor) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: widget.field.contentLeft,
          top: widget.field.contentTop,
          child: SizedBox(
            width: widget.field.contentWidth,
            height: widget.field.contentHeight,
            child: 
              widget.field.fieldType == PatternFieldType.texteditor ?
                PatternTextEditorFieldControl(
                  field: widget.field as PatternTextEditorField,
                  fleatherController: controller,
                  editorKey: null,
                  selected: false,
                  viewMode: true,
                  onChanged: (_) {},
                  onSelect: () {},
                ) :
              widget.field.fieldType == PatternFieldType.knittingchart ?
                PatternChartFieldControl(
                  opacity: widget.field.opacity.toDouble(),
                  chart: (widget.field as PatternChartField).chart,
                  viewSettings: (widget.field as PatternChartField).viewSettings,
                  selected: false,
                  onSelect: () {},
                ) :
              widget.field.fieldType == PatternFieldType.drawing ?
                PatternDrawingFieldControl(
                  opacity: widget.field.opacity.toDouble(),
                  drawing: (widget.field as PatternDrawingField).drawing, 
                  selected: false, 
                  onSelect: () {}
                ) :
              widget.field.fieldType == PatternFieldType.image ?
                PatternImageFieldControl(
                  imageData: (widget.field as PatternImageField).imageData, 
                  opacity: widget.field.opacity.toDouble(), 
                  onSelect: () {}
                ) :
              widget.field.fieldType == PatternFieldType.panel ?
                PatternPanelFieldControl(
                  panelStyle: (widget.field as PatternPanelField).style,
                  opacity: widget.field.opacity.toDouble(),
                  onSelect: () {},
                ) :
              Container()
          ),
        )
      ],
    );
  }
}