import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinkedRangeTextField extends StatefulWidget {
  final Function(double value1, double value2) onChanged;
  final double value1;
  final double value2;
  final double min;
  final double max;
  final double step;
  final int precision;
  final double width;
  
  const LinkedRangeTextField({
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
  State<LinkedRangeTextField> createState() => _LinkedRangeTextFieldState();
}

class _LinkedRangeTextFieldState extends State<LinkedRangeTextField> {
  late TextEditingController value1Controller;
  late TextEditingController value2Controller;
  bool valuesLocked = true;

  @override
  void initState() {
    value1Controller = TextEditingController(text: widget.value1.toString());
    value1Controller.addListener(_valueChanged);

    value2Controller = TextEditingController(text: widget.value2.toString());
    value2Controller.addListener(_valueChanged);

    super.initState();
  }

  @override
  void dispose() {
    value1Controller.removeListener(_valueChanged);
    value1Controller.dispose();

    value2Controller.removeListener(_valueChanged);
    value2Controller.dispose();

    super.dispose();
  }

  void _valueChanged() {
    double newValue1 = double.parse(value1Controller.text);
    double newValue2 = double.parse(value2Controller.text);
    widget.onChanged(newValue1, newValue2);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 48,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeUpDown,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                double newVal1 = double.parse(value1Controller.text) - (details.delta.dy * widget.step);
                if (newVal1 > widget.max) {
                  newVal1 = widget.max;
                } else if (newVal1 < widget.min) {
                  newVal1 = widget.min;
                }
                value1Controller.text = (newVal1).toStringAsFixed(widget.precision);
                if (valuesLocked == true) {
                  double newVal2 = double.parse(value2Controller.text) - (details.delta.dy * widget.step);
                  if (newVal2 > widget.max) {
                    newVal2 = widget.max;
                  } else if (newVal2 < widget.min) {
                    newVal2 = widget.min;
                  }
                  value2Controller.text = (newVal2).toStringAsFixed(widget.precision);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4.0), bottomLeft: Radius.circular(4.0))
                ),
                child: const Center(
                  child: Icon(Icons.unfold_more),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: widget.width,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            inputFormatters: [TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.isEmpty) {
                return newValue;
              }
              final double? val = double.tryParse(newValue.text);
              if (val == null) {
                return oldValue;
              }
              return newValue;
            })],
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4.0), 
                  bottomRight: Radius.circular(4.0)
                )
              ),
            ),
            controller: value1Controller,
            onChanged: (value) {
              if (valuesLocked) {
                value2Controller.text = ((double.parse(value2Controller.text) + (double.parse(value1Controller.text) - widget.value1))).toStringAsFixed(widget.precision);
              }
            },
          ),
        ),
        const SizedBox(width: 10,),
        SizedBox(
          width: 40,
          height: 48,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeUpDown,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                double newVal2 = double.parse(value2Controller.text) - (details.delta.dy * widget.step);
                if (newVal2 > widget.max) {
                  newVal2 = widget.max;
                } else if (newVal2 < widget.min) {
                  newVal2 = widget.min;
                }
                value2Controller.text = (newVal2).toStringAsFixed(widget.precision);
                if (valuesLocked) {
                  double newVal1 = double.parse(value1Controller.text) - (details.delta.dy * widget.step);
                  if (newVal1 > widget.max) {
                    newVal1 = widget.max;
                  } else if (newVal1 < widget.min) {
                    newVal1 = widget.min;
                  }
                  value1Controller.text = (newVal1).toStringAsFixed(widget.precision);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4.0), bottomLeft: Radius.circular(4.0))
                ),
                child: const Center(
                  child: Icon(Icons.unfold_more),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: widget.width,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            inputFormatters: [TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.isEmpty) {
                return newValue;
              }
              final double? val = double.tryParse(newValue.text);
              if (val == null) {
                return oldValue;
              }
              return newValue;
            })],
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4.0), 
                  bottomRight: Radius.circular(4.0)
                )
              ),
            ),
            controller: value2Controller,
            onChanged: (value) {
              if (valuesLocked) {
                value1Controller.text = ((double.parse(value1Controller.text) + (double.parse(value2Controller.text) - widget.value2))).toStringAsFixed(widget.precision);
              }
            },
          ),
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