import 'package:flutter/material.dart';

class StatelessTextEntryControl extends StatelessWidget {
  final String initialText;
  final double width;
  final int maxlines;
  final void Function(String newText) onChanged;

  const StatelessTextEntryControl({
    required this.initialText,
    required this.width,
    int? maxlines,
    required this.onChanged,  
    super.key
  }) : maxlines = maxlines?? 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        // Remark: this probably causes a resource leak, but I don't see another way of settings
        // the initial value (alternative is a stateful control, but then the text doesn't change when
        // the widget updates)
        controller: TextEditingController(text: initialText),
        onChanged: onChanged,
        maxLines: maxlines,
      ),
    );
  }
}