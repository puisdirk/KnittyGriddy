import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';

class LinkedSpinbox extends StatefulWidget {
  final Function(double value1, double value2) onChanged;
  final double value1;
  final double value2;
  final double min;
  final double max;
  final double step;
  final int precision;
  final double width;
  
  const LinkedSpinbox({
    required this.onChanged,
    required this.value1,
    required this.value2,
    double? min,
    double? max,
    double? step,
    int? precision,
    double? width,
    super.key
  }) : min = min?? 0, max = max?? 10000, step = step?? 1, precision = precision?? 0, width = width?? 70;

  @override
  State<LinkedSpinbox> createState() => _LinkedSpinboxState();
}

class _LinkedSpinboxState extends State<LinkedSpinbox> {
  bool valuesLocked = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: widget.width,
          child: SpinBox(
            min: widget.min,
            max: widget.max,
            decimals: widget.precision,
            step: widget.step,
            value: widget.value1,
            onChanged: (value) {
              if (valuesLocked) {
                double newVal2 = widget.value2 + (value - widget.value1);
                if (newVal2 < widget.min) {
                  newVal2 = widget.min;
                }
                if (newVal2 > widget.max) {
                  newVal2 = widget.max;
                }
                widget.onChanged(value, newVal2);
              } else {
                widget.onChanged(value, widget.value2);
              }
            },
          )
        ),
        const SizedBox(width: 10,),
        SizedBox(
          width: widget.width,
          child: SpinBox(
            min: widget.min,
            max: widget.max,
            decimals: widget.precision,
            step: widget.step,
            value: widget.value2,
            onChanged: (value) {
              if (valuesLocked) {
                double newVal1 = widget.value1 + (value - widget.value2);
                if (newVal1 < widget.min) {
                  newVal1 = widget.min;
                }
                if (newVal1 > widget.max) {
                  newVal1 = widget.max;
                }
                widget.onChanged(newVal1, value);
              } else {
                widget.onChanged(widget.value1, value);
              }
            },
          )
        ),
        const SizedBox(width: 10,),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => setState(() => valuesLocked = !valuesLocked),
            child: Icon(valuesLocked ? Icons.lock : Icons.lock_open)
          ),
        ),
      ],
    );
  }
}