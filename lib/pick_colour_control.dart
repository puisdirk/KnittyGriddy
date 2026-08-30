import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';

class PickColourControl extends StatefulWidget {
  final List<Color> knownColours;
  final String knownColoursLabel;
  final Color initialColor;
  final void Function(Color newColor) onChanged;

  const PickColourControl({
    required this.onChanged,
    this.knownColours = const[],
    this.knownColoursLabel = 'Known colours',
    this.initialColor = Colors.black,
    super.key
  });

  @override
  State<PickColourControl> createState() => _PickColourControlState();
}

class _PickColourControlState extends State<PickColourControl> {
  late Color currentColour;

  void _colorChanged(Color newColor) {
    setState(() => currentColour = newColor);
  }

  @override
  void initState() {
    currentColour = widget.initialColor;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PickColourControl oldWidget) {
    currentColour = widget.initialColor;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 370,
          height: kColourPickerHeight + (widget.knownColours.isNotEmpty ? kKnowColoursHeight : 0),
          child: Column(
            children: [
              ColorPicker(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                enableShadesSelection: true,
                hasBorder: true,
                borderColor: Colors.grey,
                width: 20,
                height: 20,
                colorCodeHasColor: true,
                enableOpacity: true,
                showMaterialName: false,
                showColorName: true,
                showColorCode: true,
                opacityTrackHeight: 10,
                opacityThumbRadius: 12,
                showEditIconButton: true,
                pickersEnabled: const {ColorPickerType.wheel: true, ColorPickerType.accent: false, ColorPickerType.primary: false},
                color: currentColour,
                onColorChanged: (value) {
                  _colorChanged(value);
                },
                onColorChangeEnd: (value) {
                  widget.onChanged(value);
                },
              ),
              if (widget.knownColours.isNotEmpty)
                Row(
                  children: [
                    Column(
                      children: [
                        Text('${widget.knownColoursLabel}: '),
                        vspacing,
                        SizedBox(
                          width: 350,
                          height: kKnowColoursHeight,
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                for (Color col in widget.knownColours)
                                  Tooltip(
                                    message: ColorTools.nameThatColor(col.withAlpha(0xFF)),
                                    child: ColorIndicator(
                                      width: 20,
                                      height: 20,
                                      borderRadius: 6,
                                      hasBorder: true,
                                      color: col,
                                      onSelect: () {
                                        _colorChanged(col);
                                        widget.onChanged(col);
                                      }
                                    ),
                                  )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )
            ],
          )
        )
      ],
    );
  }
}