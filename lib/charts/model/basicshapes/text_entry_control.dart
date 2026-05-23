import 'package:flutter/material.dart';

class TextEntryControl extends StatefulWidget {
  final String initialText;
  final double width;
  final int maxlines;
  final void Function(String newText) onChanged;

  const TextEntryControl({
    required this.initialText,
    required this.width,
    int? maxlines,
    required this.onChanged,  
    super.key
  }) : maxlines = maxlines?? 1;

  @override
  State<TextEntryControl> createState() => _TextEntryControlState();
}

class _TextEntryControlState extends State<TextEntryControl> {

  late TextEditingController _controller;

  void _textChanged() {
    widget.onChanged(_controller.text);
  }

  @override
  void initState() {
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(_textChanged);

    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_textChanged);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextField(controller: _controller, maxLines: widget.maxlines,),
    );
  }
}