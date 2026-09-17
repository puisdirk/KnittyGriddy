import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/mainview/export/preview_pattern_field_control.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';

// Remark: no longer really used. Called from the ExportPatternPagewisePage

class PatternPagePreview extends StatefulWidget {
  final KnittingPattern pattern;
  final int pageNumber;

  const PatternPagePreview({
    required this.pattern,
    required this.pageNumber,
    super.key
  });

  @override
  State<PatternPagePreview> createState() => _PatternPagePreviewState();
}

class _PatternPagePreviewState extends State<PatternPagePreview> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.pattern.pageLayout.pagewidth,
      height: widget.pattern.pageLayout.pagewidth,
      child: Stack(
        children: [
          for (PatternField field in widget.pattern.fieldsOnPage(widget.pageNumber))
            Positioned(
              left: field.positionX,
              top: field.positionY - (widget.pageNumber * widget.pattern.pageLayout.pageheight),
              child: SizedBox(
                width: field.width,
                height: field.height,
                child: PreviewPatternFieldControl(
                  field: field, 
                )
              )
            )
        ],
      ),
    );
  }
}