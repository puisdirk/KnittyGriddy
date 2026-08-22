import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/panel_field_components/pattern_field_panel_style_dialog.dart';

class BorderRadiusSpinBox extends StatelessWidget {
  
  final BorderCorner corner;
  final double initialValue;
  final void Function (BorderCorner corner, double newValue) onChanged;

  const BorderRadiusSpinBox({
    required this.corner,
    required this.initialValue,
    required this.onChanged,
    super.key
  });

  static const double kSpinBoxWidth = 140;
  static const double kMaxBorderRadius = 600;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: kSpinBoxWidth,
        child: SpinBox(
          onChanged: (value) => onChanged(corner, value),
          min: 0,
          max: kMaxBorderRadius,
          value: initialValue,
        ),
      ),
    );
  }
}