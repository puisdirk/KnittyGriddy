import 'dart:convert';

import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/patterns/mainview/fleather/styled_stitch_icon.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';

class TextEditorFieldOutline extends StatefulWidget {
  final PatternTextEditorField field;

  const TextEditorFieldOutline({
    required this.field,
    super.key
  });

  @override
  State<TextEditorFieldOutline> createState() => _TextEditorFieldOutlineState();
}

class _TextEditorFieldOutlineState extends State<TextEditorFieldOutline> {

  late FleatherController _controller;

  @override
  void initState() {
    ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode(widget.field.docContents));
    _controller = FleatherController(document: document);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant TextEditorFieldOutline oldWidget) {
    ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode(widget.field.docContents));
    _controller = FleatherController(document: document);

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: widget.field.width,
        height: widget.field.height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(20),
            border: Border.all(color: Colors.grey.withAlpha(50)),
          ),
          child: Stack(
            children: [
              Positioned(
                left: widget.field.leftpadding + widget.field.contentOffsetX,
                top: widget.field.contentOffsetY,
                child: Opacity(
                  opacity: .2,
                  child: SizedBox(
                    width: widget.field.width - (2 * widget.field.padding),
                    height: widget.field.height - widget.field.bottompadding,
                    child: FleatherField(
                      embedBuilder: _embedBuilder,
                      readOnly: true,
                      showCursor: false,
                      padding: const EdgeInsets.only(
                        top: 1,
                        left: 5,
                        right: 5,
                        bottom: 5
                      ),
                      controller: _controller,
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                ),
              )
            ]
          ),
        ),
      ),
    );
  }

  Widget _embedBuilder(BuildContext context, EmbedNode node) {
    if (node.value.type == 'stitch') {
      final StitchDefinition stitchDefinition = StitchDefinition.fromJson(node.value.data['stitchdefinition']);

      return StyledStitchIcon(
        stitchDefinition: stitchDefinition,
        style: node.style,
        lineStyle: node.parent.style,
      );
    }

    return defaultFleatherEmbedBuilder(context, node);
  }

}