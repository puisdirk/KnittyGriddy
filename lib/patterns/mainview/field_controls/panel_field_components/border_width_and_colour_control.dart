import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/panel_field_components/colour_well.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/panel_field_components/pattern_field_panel_style_dialog.dart';
import 'package:knitty_griddy/utils/constants.dart';

class BorderWidthAndColourControl extends StatelessWidget {

  final BorderField borderField;
  final double initialWidth;
  final Color colour;
  final bool colourSelected;
  final void Function(BorderField borderField, double newWidth) onWidthChanged;
  final void Function() onColourSelected;

  const BorderWidthAndColourControl({
    required this.borderField,
    required this.initialWidth,
    required this.colour,
    required this.colourSelected,
    required this.onWidthChanged,
    required this.onColourSelected,
    super.key
  });

  static const double kSpinBoxWidth = 140;
  static const double kMaxBorderWidth = 20;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: kSpinBoxWidth,
          child: SpinBox(
            onChanged: (value) => onWidthChanged(borderField, value),
            min: 0,
            max: kMaxBorderWidth,
            decimals: 1,
            step: .1,
            value: initialWidth,
          ),
        ),
        hspacing,
        ColourWell(
          selected: colourSelected, 
          color: colour,
          onTap: onColourSelected
        ),
      ],
    );
  }
}