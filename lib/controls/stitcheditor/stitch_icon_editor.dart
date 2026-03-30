
import 'package:flutter/material.dart';

class StitchIconEditor extends StatefulWidget {
  
  final List<int> iconData;
  
  const StitchIconEditor({
    required this.iconData,
    super.key
  });

  @override
  State<StitchIconEditor> createState() => _StitchIconEditorState();
}

class _StitchIconEditorState extends State<StitchIconEditor> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}