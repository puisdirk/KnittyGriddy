import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/mainview/infinite_indentation_button.dart';

class PatternTextEditorFieldToolbar extends StatelessWidget {
  final FleatherController fleatherController;
  final EdgeInsetsGeometry? padding;
  final GlobalKey<EditorState>? editorKey;

  const PatternTextEditorFieldToolbar({
    required this.fleatherController,
    this.padding,
    this.editorKey,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    Widget backgroundColorBuilder(context, value) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.mode_edit_outline_outlined,
          size: 16,
        ),
        Container(
          width: 18,
          height: 4,
          decoration: BoxDecoration(color: value),
        )
      ],
    );
    Widget textColorBuilder(context, value) {
      Color effectiveColor =
          value ?? DefaultTextStyle.of(context).style.color ?? Colors.black;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.text_fields_sharp,
            size: 16,
          ),
          Container(
            width: 18,
            height: 4,
            decoration: BoxDecoration(color: effectiveColor),
          )
        ],
      );
    }

    return FleatherToolbar(
      key: key,
      editorKey: editorKey,
      padding: padding,
      children: [
        ToggleStyleButton(
          attribute: ParchmentAttribute.bold,
          icon: Icons.format_bold,
          controller: fleatherController,
        ),
        const SizedBox(width: 1),
        ToggleStyleButton(
          attribute: ParchmentAttribute.italic,
          icon: Icons.format_italic,
          controller: fleatherController,
        ),
        const SizedBox(width: 1),
        ToggleStyleButton(
          attribute: ParchmentAttribute.underline,
          icon: Icons.format_underline,
          controller: fleatherController,
        ),
        const SizedBox(width: 1),
        ToggleStyleButton(
          attribute: ParchmentAttribute.strikethrough,
          icon: Icons.format_strikethrough,
          controller: fleatherController,
        ),
        const SizedBox(width: 1),
        Builder(builder: (context) {
          return Tooltip(
            message: 'Text color',
            preferBelow: false,
            child: ColorButton(
              controller: fleatherController,
              attributeKey: ParchmentAttribute.foregroundColor,
              nullColorLabel: FleatherLocalizations.of(context)!.foregroundColorAutomatic,
              builder: textColorBuilder,
            ),
          );
        }),
        Builder(builder: (context) {
          return Tooltip(
            message: 'Background color',
            preferBelow: false,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ColorButton(
                controller: fleatherController,
                attributeKey: ParchmentAttribute.backgroundColor,
                nullColorLabel: FleatherLocalizations.of(context)!.backgroundColorNoColor,
                builder: backgroundColorBuilder,
              ),
            ),
          );
        }),
        
        VerticalDivider(
          indent: 16, endIndent: 16, color: Colors.grey.shade400
        ),

        ToggleStyleButton(
          attribute: ParchmentAttribute.left,
          icon: Icons.format_align_left,
          controller: fleatherController,
        ),
        const SizedBox(width: 1),
        ToggleStyleButton(
          attribute: ParchmentAttribute.center,
          icon: Icons.format_align_center,
          controller: fleatherController,
        ),
        const SizedBox(width: 1),
        ToggleStyleButton(
          attribute: ParchmentAttribute.right,
          icon: Icons.format_align_right,
          controller: fleatherController,
        ),
        const SizedBox(width: 1),
        ToggleStyleButton(
          attribute: ParchmentAttribute.justify,
          icon: Icons.format_align_justify,
          controller: fleatherController,
        ),
        
        VerticalDivider(
            indent: 16, endIndent: 16, color: Colors.grey.shade400
        ),

        /// ################################################################

        InfiniteIndentationButton(
          increase: false,
          controller: fleatherController,
        ),
        InfiniteIndentationButton(
          controller: fleatherController,
        ),
        
        VerticalDivider(
            indent: 16, endIndent: 16, color: Colors.grey.shade400),

        /// ################################################################

        SelectHeadingButton(controller: fleatherController),
        VerticalDivider(
          indent: 16, endIndent: 16, color: Colors.grey.shade400
        ),

        /// ################################################################
        ToggleStyleButton(
          attribute: ParchmentAttribute.block.numberList,
          controller: fleatherController,
          icon: Icons.format_list_numbered,
        ),

        ToggleStyleButton(
          attribute: ParchmentAttribute.block.bulletList,
          controller: fleatherController,
          icon: Icons.format_list_bulleted,
        ),
        ToggleStyleButton(
          attribute: ParchmentAttribute.block.checkList,
          controller: fleatherController,
          icon: Icons.checklist,
        ),

        VerticalDivider(
          indent: 16, endIndent: 16, color: Colors.grey.shade400
        ),

        /// ################################################################
        Tooltip(
          message: 'Block',
          preferBelow: false,
          child: ToggleStyleButton(
            attribute: ParchmentAttribute.block.code,
            controller: fleatherController,
            icon: Icons.code,
          ),
        ),
        Tooltip(
          message: 'Quote',
          preferBelow: false,
          child: ToggleStyleButton(
            attribute: ParchmentAttribute.block.quote,
            controller: fleatherController,
            icon: Icons.format_quote,
          ),
        ),
        Tooltip(
          message: 'Horizontal line',
          preferBelow: false,
          child: InsertEmbedButton(
            controller: fleatherController,
            icon: Icons.horizontal_rule,
          ),
        ),
        VerticalDivider(
            indent: 16, endIndent: 16, color: Colors.grey.shade400),

        // TODO: button for knitting symbols

        /// ################################################################

        UndoRedoButton.undo(
          controller: fleatherController,
        ),
        UndoRedoButton.redo(
          controller: fleatherController,
        ),

      ],
    );
  }
}