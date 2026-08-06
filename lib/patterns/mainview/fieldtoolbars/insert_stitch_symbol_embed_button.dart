import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/stitchicon_chooser_dialog.dart';

class InsertStitchSymbolEmbedButton extends StatelessWidget {
  final FleatherController controller;
  final Widget icon;

  const InsertStitchSymbolEmbedButton({
    super.key,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FLIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: 32,
      icon: icon,
      fillColor: Theme.of(context).canvasColor,
      onPressed: () async {
        StitchDefinition? stitchDefinition = await showDialog(context: context, builder: (context) => const StitchiconChooserDialog(),);
        if (stitchDefinition != null) {
          // Get snapshot of the style
          ParchmentStyle style = controller.getSelectionStyle();

          // Replace selection with embed
          final selection = controller.selection;
          controller.replaceText(
            selection.baseOffset,
            selection.extentOffset - selection.baseOffset,
            EmbeddableObject(
              'stitch', 
              inline: true, 
              data: {
                'stitchdefinition': stitchDefinition.toJson(),
              }
            ),
          );

          // Select the embed
          controller.updateSelection(TextSelection(baseOffset: selection.baseOffset, extentOffset: selection.baseOffset + 1));

          // Format with the style snapshot
          if (style.contains(ParchmentAttribute.foregroundColor)) {
            controller.formatSelection(style.get(ParchmentAttribute.foregroundColor)!);
          }
          if (style.contains(ParchmentAttribute.backgroundColor)) {
            controller.formatSelection(style.get(ParchmentAttribute.backgroundColor)!);
          }
          if (style.contains(ParchmentAttribute.underline)) {
            controller.formatSelection(style.get(ParchmentAttribute.underline)!);
          }
          if (style.contains(ParchmentAttribute.strikethrough)) {
            controller.formatSelection(style.get(ParchmentAttribute.strikethrough)!);
          }
          if (style.contains(ParchmentAttribute.italic)) {
            controller.formatSelection(style.get(ParchmentAttribute.italic)!);
          }
          if (style.contains(ParchmentAttribute.heading)) {
            controller.formatSelection(style.get(ParchmentAttribute.heading)!);
          }

          // Select after the embed
          controller.updateSelection(TextSelection.collapsed(offset: selection.baseOffset + 1));
        }
      },
    );
  }
}
