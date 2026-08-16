import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/mainview/fleather/knitty_griddy_fleather_editor.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';

class PatternTextEditorFieldControl extends StatelessWidget {
  final KnittingPattern knittingPattern;
  final PatternTextEditorField field;
  final FleatherController fleatherController;
  final GlobalKey<EditorState>? editorKey;
  final bool selected;
  final bool viewMode;
  final void Function(PatternTextEditorField changedField) onChanged;
  final void Function() onSelect;

  const PatternTextEditorFieldControl({
    required this.knittingPattern,
    required this.field,
    required this.fleatherController,
    this.editorKey,
    required this.selected,
    required this.viewMode,
    required this.onChanged,
    required this.onSelect,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: field.opacity == 0 ? 0 : field.opacity / 255,
      child: KnittyGriddyFleatherEditor(
        knittingPattern: knittingPattern, 
        field: field,
        fleatherController: fleatherController,
        editorKey: editorKey,
        selected: selected,
        viewMode: viewMode,
        onChanged: onChanged,
        onSelect: onSelect,
      ),
    );
  }
}