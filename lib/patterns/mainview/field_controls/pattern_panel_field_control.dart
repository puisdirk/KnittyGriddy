import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field_style.dart';

class PatternPanelFieldControl extends StatelessWidget {
  final PatternPanelFieldStyle panelStyle;
  final void Function() onSelect;

  const PatternPanelFieldControl({
    required this.panelStyle,
    required this.onSelect,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        decoration: BoxDecoration(
          color: panelStyle.backgroundColor,
          border: Border(
            top: panelStyle.topBorderWidth == 0 ? BorderSide.none : BorderSide(color: panelStyle.topBorderColor, width: panelStyle.topBorderWidth),
            bottom: panelStyle.bottomBorderWidth == 0 ? BorderSide.none : BorderSide(color: panelStyle.bottomBorderColor, width: panelStyle.bottomBorderWidth),
            left: panelStyle.leftBorderWidth == 0 ? BorderSide.none : BorderSide(color: panelStyle.leftBorderColor, width: panelStyle.leftBorderWidth),
            right: panelStyle.rightBorderWidth == 0 ? BorderSide.none : BorderSide(color: panelStyle.rightBorderColor, width: panelStyle.rightBorderWidth),
          ),
          borderRadius: BorderRadius.only(
            topLeft: panelStyle.canSetRadius && panelStyle.topLeftRadius != PatternPanelFieldStyle.kDefaultBorderRadius ? Radius.circular(panelStyle.topLeftRadius) : Radius.zero,
            topRight: panelStyle.canSetRadius && panelStyle.topRightRadius != PatternPanelFieldStyle.kDefaultBorderRadius ? Radius.circular(panelStyle.topRightRadius) : Radius.zero,
            bottomLeft: panelStyle.canSetRadius && panelStyle.bottomLeftRadius != PatternPanelFieldStyle.kDefaultBorderRadius ? Radius.circular(panelStyle.bottomLeftRadius) : Radius.zero,
            bottomRight: panelStyle.canSetRadius && panelStyle.bottomRightRadius != PatternPanelFieldStyle.kDefaultBorderRadius ? Radius.circular(panelStyle.bottomRightRadius) : Radius.zero,
          )
        ),
      ),
    );
  }
}