
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/mainview/fleather/custom_parchment_attribute.dart';

class InfiniteIndentationButton extends StatefulWidget {
  final bool increase;
  final FleatherController controller;

  const InfiniteIndentationButton(
      {super.key, this.increase = true, required this.controller});

  @override
  State<InfiniteIndentationButton> createState() => _InfiniteIndentationButtonState();
}

class _InfiniteIndentationButtonState extends State<InfiniteIndentationButton> {
  ParchmentStyle get _selectionStyle => widget.controller.getSelectionStyle();

  void _didChangeEditingValue() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  void didUpdateWidget(covariant InfiniteIndentationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled =
        !_selectionStyle.containsSame(ParchmentAttribute.block.code);
    final theme = Theme.of(context);
    final iconColor = isEnabled ? theme.iconTheme.color : theme.disabledColor;
    return FLIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: 32,
      icon: Icon(
          widget.increase
              ? Icons.format_indent_increase
              : Icons.format_indent_decrease,
          size: 18,
          color: iconColor),
      fillColor: theme.canvasColor,
      onPressed: isEnabled
          ? () {
              final indentLevel =
                  _selectionStyle.get(ParchmentAttribute.indent)?.value ?? 0;
              if (indentLevel == 0 && !widget.increase) {
                return;
              }
              if (indentLevel == 1 && !widget.increase) {
                widget.controller
                    .formatSelection(ParchmentAttribute.indent.unset);
              } else {
                // see custom_parchment_attribute.dart
                widget.controller.formatSelection(ParchmentAttribute.indent
                    .withInfiniteLevel(indentLevel + (widget.increase ? 1 : -1)));
              }
//              FleatherToolbar._of(context).requestKeyboard();
            }
          : null,
    );
  }
}
