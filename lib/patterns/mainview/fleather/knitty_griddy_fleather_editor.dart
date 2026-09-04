import 'dart:convert';

import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/patterns/mainview/fleather/styled_stitch_icon.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';

import 'package:knitty_griddy/patterns/mainview/fleather/fleather_theme_data_ext.dart';

class KnittyGriddyFleatherEditor extends StatefulWidget {
  final KnittingPattern knittingPattern;
  final PatternTextEditorField field;
  final FleatherController fleatherController;
  final GlobalKey<EditorState>? editorKey;
  final bool selected;
  final bool viewMode;
  final void Function(PatternTextEditorField changedField) onChanged;
  final void Function() onSelect;

  const KnittyGriddyFleatherEditor({
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
  State<KnittyGriddyFleatherEditor> createState() => _KnittyGriddyFleatherEditorState();
}

class _KnittyGriddyFleatherEditorState extends State<KnittyGriddyFleatherEditor> {
  late FocusNode _fleatherFocusNode;
  final ScrollController _scrollController = ScrollController();

  void _docChanged() {
    widget.onChanged(
      widget.field.copyWith(
        docContents: jsonEncode(widget.fleatherController.document.toJson()),
        overflowing: _scrollController.position.maxScrollExtent > 20,
      )
    );
  }

  void _focusChanged() {
    if (_fleatherFocusNode.hasFocus) {
      widget.onSelect();
    }
  }

  @override
  void initState() {
    _fleatherFocusNode = FocusNode();
    _fleatherFocusNode.addListener(_focusChanged);

    widget.fleatherController.addListener(_docChanged);

    super.initState();
  }

  @override
  void dispose() {
    _fleatherFocusNode.removeListener(_focusChanged);
    _fleatherFocusNode.dispose();
    widget.fleatherController.removeListener(_docChanged);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (widget.selected) {
      _fleatherFocusNode.requestFocus();
    } else {
      _fleatherFocusNode.unfocus();
    }

    return Column(
      children: [
        FleatherTheme(data: FleatherThemeDataExt.withTextStyle(context, widget.field.settings.style), 
          child: Expanded(
            child: widget.viewMode ?
            FleatherField(
              embedBuilder: _embedBuilder,
              readOnly: true,
              showCursor: false,
              padding: const EdgeInsets.only(
                top: 1,
                left: 5,
                right: 5,
                bottom: 5
              ),
              controller: widget.fleatherController,
              decoration: const InputDecoration(border: InputBorder.none),
            )
            :
            // We override the undo/redo to do nothing (handled by our own undoredoManager in PatternPage)
            Actions(
              actions: <Type, Action<Intent>>{
                UndoTextIntent: CallbackAction<UndoTextIntent>(
                  onInvoke: (intent) {
                    return null;
                  }    
                ),
                RedoTextIntent: CallbackAction<RedoTextIntent>(
                  onInvoke: (intent) {
                    return null;
                  }    
                )
              },
              child: FleatherEditor(
                embedBuilder: _embedBuilder,
                autofocus: false,
                padding: const EdgeInsets.all(5),
                controller: widget.fleatherController,
                editorKey: widget.editorKey,
                scrollController: _scrollController,
                focusNode: _fleatherFocusNode,
              ),
            ),
          ),
        ),
      ],
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
