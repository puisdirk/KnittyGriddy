import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';

class SmallMultilineTextField extends StatefulWidget {
  final String initialText;
  final double width;
  final int lines;
  final void Function(String newText) onTextChanged;

  const SmallMultilineTextField({
    required this.initialText,
    required this.width,
    required this.lines,
    required this.onTextChanged,
    super.key
  });

  @override
  State<SmallMultilineTextField> createState() => _SmallMultilineTextFieldState();
}

class _SmallMultilineTextFieldState extends State<SmallMultilineTextField> {

  late TextEditingController controller;
  late FocusNode focusNode;

  void _focusChanged() {
    if (!focusNode.hasFocus) {
      widget.onTextChanged(controller.text);
    }
  }

  @override
  void initState() {
    controller = TextEditingController(text: widget.initialText);
    focusNode = FocusNode();
    focusNode.addListener(_focusChanged);

    super.initState();
  }

  @override
  void dispose() {
    focusNode.removeListener(_focusChanged);
    focusNode.dispose();

    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextField(
        style: smallStyle,
        maxLines: widget.lines,
        controller: controller,
        focusNode: focusNode,
        onTapOutside: (_) => widget.onTextChanged(controller.text),
      ),
    );
  }
}