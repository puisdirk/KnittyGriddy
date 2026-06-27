import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_multiline_text_field.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/comment_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

class CommentCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final CommentCommand command;
  final bool sorting;
  final bool editing;
  final void Function(CommentCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(CommentCommand newCommand) onChanged;


  const CommentCommandControl({
    required this.drawing,
    required this.command,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<CommentCommandControl> createState() => _CommentCommandControlState();
}

class CommentPainter extends CustomPainter {
  final String text;

  const CommentPainter({
    required this.text,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: smallStyle), 
      maxLines: 3, 
      textDirection: TextDirection.ltr
    )
    ..layout(minWidth: 0, maxWidth: size.width,);

    textPainter.paint(canvas, Offset.zero);
  }
  
  @override
  bool shouldRepaint(covariant CommentPainter oldDelegate) {
    return oldDelegate.text != text;
  }
  
}

class _CommentCommandControlState extends State<CommentCommandControl> {

  static const double _fieldWidth = 300;

  void commentChanged(String newText) {
    if (widget.command.comment != newText) {
      widget.onChanged(widget.command.copyWith(comment: newText));
    }
  }

  Widget createViewContent() {
    return Row(
      children: [
        const Icon(Icons.comment_outlined),
        hspacing,
        SizedBox(
          width: commandControlViewWidthNoError,
          child: CustomPaint(
            size: MathUtitilies.textSize(
              widget.command.comment, smallStyle, maxLines: 3, maxWidth: _fieldWidth
            ),
            painter: CommentPainter(text: widget.command.comment),
          )
        )
      ],
    );
  }

  Widget createEditContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment_outlined),
            hspacing,
          ],
        ),
        vspacing,
        Row(
          children: [
            SmallMultilineTextField(
              key: GlobalObjectKey('${widget.command.id}-${widget.command.version}-comment'),
              width: _fieldWidth,
              lines: 3,
              initialText: widget.command.comment,
              onTextChanged: commentChanged,
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.editing && !widget.sorting) ? createEditContent() : createViewContent();
  }
}