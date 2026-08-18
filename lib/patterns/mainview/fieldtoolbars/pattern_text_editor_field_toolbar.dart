import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/stitch_icon.dart';
import 'package:knitty_griddy/charts/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/insert_stitch_symbol_embed_button.dart';
import 'package:knitty_griddy/patterns/mainview/fleather/infinite_indentation_button.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/pick_colour_dialog.dart';

class PatternTextEditorFieldToolbar extends StatelessWidget {
  final FleatherController fleatherController;
  final KnittingPattern pattern;
  final EdgeInsetsGeometry? padding;
  final GlobalKey? editorKey;
  final void Function() onTextStyleSettingsButtonClicked;

  const PatternTextEditorFieldToolbar({
    required this.fleatherController,
    required this.pattern,
    required this.onTextStyleSettingsButtonClicked,
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
      editorKey: editorKey as GlobalKey<EditorState>,
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

        VerticalDivider(
          indent: 10, endIndent: 10, color: Colors.grey.shade400
        ),

        Builder(builder: (context) {
          return Tooltip(
            message: 'Text color',
            preferBelow: false,
            child: ColorButton(
              controller: fleatherController,
              attributeKey: ParchmentAttribute.foregroundColor,
              nullColorLabel: FleatherLocalizations.of(context)!.foregroundColorAutomatic,
              builder: textColorBuilder,
              pickColor: (context, nullColorLabel) async {
                return await showDialog(context: context, builder: (context) {
                  ParchmentStyle style = fleatherController.getSelectionStyle();
                  Color initialColor = Colors.black;
                  if (style.contains(ParchmentAttribute.foregroundColor)) {
                    initialColor = Color(style.get(ParchmentAttribute.foregroundColor)!.value!);
                  }
                  return PickColourDialog(
                    initialColor: initialColor,
                    knownColours: pattern.knownColours,
                  );
                },
                );
              },
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
                pickColor: (context, nullColorLabel) async {
                  return await showDialog(context: context, builder: (context) {
                    ParchmentStyle style = fleatherController.getSelectionStyle();
                    Color initialColor = Colors.white;
                    if (style.contains(ParchmentAttribute.backgroundColor)) {
                      initialColor = Color(style.get(ParchmentAttribute.backgroundColor)!.value!);
                    }
                    return PickColourDialog(
                      initialColor: initialColor,
                      knownColours: pattern.knownColours,
                    );
                  },
                  );
                },
              ),
            ),
          );
        }),
        
        VerticalDivider(
          indent: 10, endIndent: 10, color: Colors.grey.shade400
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
            indent: 10, endIndent: 10, color: Colors.grey.shade400
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
            indent: 10, endIndent: 10, color: Colors.grey.shade400),

        /// ################################################################

        SelectHeadingButton(controller: fleatherController),
        VerticalDivider(
          indent: 10, endIndent: 10, color: Colors.grey.shade400
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
          indent: 10, endIndent: 10, color: Colors.grey.shade400
        ),

        /// ################################################################
/*        Tooltip(
          message: 'Quote',
          preferBelow: false,
          child: ToggleStyleButton(
            attribute: ParchmentAttribute.block.quote,
            controller: fleatherController,
            icon: Icons.format_quote,
          ),
        ),
        VerticalDivider(
            indent: 16, endIndent: 16, color: Colors.grey.shade400),
*/
        Tooltip(
          message: 'Insert stitch symbol',
          preferBelow: false,
          child: InsertStitchSymbolEmbedButton(
            controller: fleatherController, 
            icon: StitchIcon(
              stitchDefinition: BasicStitchesSet.sssp, 
              iconSize: 18, 
              iconColor: Theme.of(context).iconTheme.color,
            )
          ),
        ),
        VerticalDivider(
            indent: 10, endIndent: 10, color: Colors.grey.shade400),

        /// ################################################################
/*
        UndoRedoButton.undo(
          controller: fleatherController,
        ),
        UndoRedoButton.redo(
          controller: fleatherController,
        ),

        VerticalDivider(
            indent: 16, endIndent: 16, color: Colors.grey.shade400),
*/
        Tooltip(
          message: 'Font settings',
          preferBelow: false,
          child: FLIconButton(
            highlightElevation: 0,
            hoverElevation: 0,
            size: 32,
            icon: Icon(Icons.settings, size: 16, color: Theme.of(context).iconTheme.color),
            fillColor: Theme.of(context).canvasColor,
            onPressed: onTextStyleSettingsButtonClicked
          ),
        )
      ],
    );
  }
}