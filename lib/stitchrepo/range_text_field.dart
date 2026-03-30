import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RangeTextField extends StatefulWidget {
  final Function(double value, double delta) onChanged;
  final double value;
  final double min;
  final double max;
  final double step;
  final int precision;
  final double width;
  
  const RangeTextField({
    required this.onChanged,
    required this.value,
    double? min,
    double? max,
    double? step,
    int? precision,
    double? width,
    super.key
  }) : min = min?? 0, max = max?? 10000, step = step?? 1, precision = precision?? 0, width = width?? 70;

  @override
  State<RangeTextField> createState() => _RangeTextFieldState();
}

class _RangeTextFieldState extends State<RangeTextField> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: widget.value.toString());
    controller.addListener(_valueChanged);

    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_valueChanged);
    controller.dispose();

    super.dispose();
  }

  void _valueChanged() {
    double newValue = double.parse(controller.text);
    widget.onChanged(newValue, newValue - widget.value);
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
                double newVal = double.parse(controller.text) - (details.delta.dy * widget.step);
                if (newVal > widget.max) {
                  newVal = widget.max;
                } else if (newVal < widget.min) {
                  newVal = widget.min;
                }
                controller.text = (newVal).toStringAsFixed(widget.precision);
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
            controller: controller,
          ),
        )
      ],
    );
  }
}