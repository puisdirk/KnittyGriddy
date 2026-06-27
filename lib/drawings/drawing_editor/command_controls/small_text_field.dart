import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';

class SmallTextField extends StatefulWidget {
  final String initialText;
  final double width;
  final void Function(String newText) onTextChanged;

  const SmallTextField({
    required this.initialText,
    required this.width,
    required this.onTextChanged,
    super.key
  });

  @override
  State<SmallTextField> createState() => _SmallTextFieldState();
}

class _SmallTextFieldState extends State<SmallTextField> {
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
        decoration: InputDecoration(
          constraints: const BoxConstraints.tightFor(height: 40),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),         
        style: smallStyle,
        controller: controller,
        focusNode: focusNode,
        onTapOutside: (_) => widget.onTextChanged(controller.text),
      ),
    );
  }
}