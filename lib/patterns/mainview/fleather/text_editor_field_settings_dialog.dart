import 'dart:convert';

import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/patterns/mainview/fleather/fleather_theme_data_ext.dart';
import 'package:knitty_griddy/patterns/model/fields/text_editor_field_settings.dart';
import 'package:knitty_griddy/utils/constants.dart';

class TextEditorFieldSettingsDialog extends StatefulWidget {
  final TextEditorFieldSettings settings;

  const TextEditorFieldSettingsDialog({
    required this.settings,
    super.key
  });

  @override
  State<TextEditorFieldSettingsDialog> createState() => _TextEditorFieldSettingsDialogState();
}

class _TextEditorFieldSettingsDialogState extends State<TextEditorFieldSettingsDialog> {
  late TextEditorFieldSettings newSettings;
  late FleatherController _fleatherController;

  static const kSampleContent = '''[{"insert":"Normal styles: "},{"insert":"'Twas","attributes":{"b":true}},{"insert":" "},
    {"insert":"brillig","attributes":{"i":true}},{"insert":", "},{"insert":"and","attributes":{"u":true}},{"insert":" "},
    {"insert":"the","attributes":{"s":true}},{"insert":" "},{"insert":"slithy","attributes":{"fg":4294198070}},{"insert":" "},
    {"insert":"toves","attributes":{"bg":4283215696}},
    {"insert":"\\nHeading1: Did gyre and gimble in the wabe"},{"insert":"\\n","attributes":{"heading":1}},
    {"insert":"Heading2: All mimsy were the borogoves,"},{"insert":"\\n","attributes":{"heading":2}},
    {"insert":"Heading3: And the mome raths outgrabe."},{"insert":"\\n","attributes":{"heading":3}},
    {"insert":"Heading4: “Beware the Jabberwock, my son!"},{"insert":"\\n","attributes":{"heading":4}},
    {"insert":"Heading5: The jaws that bite, the claws that catch!"},{"insert":"\\n","attributes":{"heading":5}},
    {"insert":"Heading6: Beware the Jubjub bird, and shun"},{"insert":"\\n","attributes":{"heading":6}},
    {"insert":"Normal: The frumious Bandersnatch!”\\n\\n"}]''';

  @override
  void initState() {
    newSettings = widget.settings;

    ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode(kSampleContent));
    _fleatherController = FleatherController(document: document);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant TextEditorFieldSettingsDialog oldWidget) {
    newSettings = widget.settings;

    super.didUpdateWidget(oldWidget);
  }

  void _changeFontFamily(FontFamily newFontFamily) {
    if (newFontFamily != newSettings.fontFamily) {
      setState(() => newSettings = newSettings.copyWith(fontFamily: newFontFamily));
    }
  }

  void _changeFontSize(double newFontSize) {
    if (newFontSize != newSettings.fontSize) {
      setState(() => newSettings = newSettings.copyWith(fontSize: newFontSize));
    }
  }

  void _changeFontHeight(double newFontHeight) {
    if (newFontHeight != newSettings.fontHeight) {
      setState(() => newSettings = newSettings.copyWith(fontHeight: newFontHeight));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(1),
      title: const Text('Font settings'),
      content: SizedBox(
        width: 650,
        height: 560,
        child: Center(
          child: Column(
            children: [
              vspacing,
              Row(
                children: [
                  const SizedBox(width: 100, child: Text('Font', textAlign: TextAlign.right,)),
                  hspacing,
                  DropdownButton<FontFamily>(
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      for (FontFamily fontFamily in FontFamily.values)
                        DropdownMenuItem(
                          value: fontFamily, 
                          child: Text(
                            fontFamily.label, 
                            style: TextEditorFieldSettings(fontFamily: fontFamily, fontSize: 16, fontHeight: 1.3).style,
                          )
                        ),
                    ], 
                    onChanged: (value) {
                      if (value != null) {
                        _changeFontFamily(value);
                      }
                    },
                    value: newSettings.fontFamily,
                  ),
                  hspacing,
                  SizedBox(
                    width: 380,
                    child: Text(
                      newSettings.fontFamily.comment,
                      style: const TextStyle(fontSize: 10),
                      softWrap: true,
                    ),
                  )
                ],
              ),
              vspacing,
              vspacing,
              Row(
                children: [
                  const SizedBox(width: 100, child: Text('Size', textAlign: TextAlign.right,)),
                  hspacing,
                  SizedBox(
                    width: 160,
                    child: SpinBox(
                      onChanged: _changeFontSize,
                      min: 6,
                      max: 500,
                      value: newSettings.fontSize,
                    ),
                  ),
                  hspacing,
                  const SizedBox(width: 100, child: Text('Height', textAlign: TextAlign.right,)),
                  hspacing,
                  SizedBox(
                    width: 160,
                    child: SpinBox(
                      onChanged: _changeFontHeight,
                      min: 0,
                      max: 20,
                      decimals: 1,
                      digits: 1,
                      step: 0.1,
                      value: newSettings.fontHeight,
                    ),
                  )
                ],
              ),
              vspacing,
              vspacing,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 600,
                    height: 400,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: FleatherTheme(
                        data: FleatherThemeDataExt.withTextStyle(context, newSettings.style),
                        child: FleatherEditor(
                          autofocus: false,
                          padding: const EdgeInsets.all(5),
                          controller: _fleatherController,
                          readOnly: true,
                          showCursor: false,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          }, 
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: () {
            if (newSettings != widget.settings) {
              Navigator.of(context).pop(newSettings);
            } else {
              Navigator.of(context).pop(null);
            }
          }, 
          child: const Text('Ok')
        )
      ],
    );
  }
}