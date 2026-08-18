import 'package:fitted_scale/fitted_scale.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/panel_field_components/border_radius_spin_box.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/panel_field_components/border_width_and_colour_control.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/panel_field_components/colour_well.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field_style.dart';
import 'package:knitty_griddy/pick_colour_control.dart';
import 'package:knitty_griddy/utils/constants.dart';

class PatternFieldPanelStyleDialog extends StatefulWidget {
  final PatternPanelFieldStyle panelStyle;
  final List<Color> knownColours;

  const PatternFieldPanelStyleDialog({
    required this.panelStyle,
    required this.knownColours,
    super.key
  });

  @override
  State<PatternFieldPanelStyleDialog> createState() => _PatternFieldPanelStyleDialogState();
}

enum ColorField {
  backgroundColor(label: 'Background colour'),
  leftBorderColor(label: 'Left border colour'),
  rightBorderColor(label: 'Right border colour'),
  topBorderColor(label: 'Top border colour'),
  bottomBorderColor(label: 'Bottom border colour');

  final String label;

  const ColorField({required this.label});
}

enum BorderField {
  leftBorder(label: 'Left'),
  rightBorder(label: 'Right'),
  topBorder(label: 'Top'),
  bottomBorder(label: 'Bottom');

  final String label;

  const BorderField({required this.label});
}

enum BorderCorner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _PatternFieldPanelStyleDialogState extends State<PatternFieldPanelStyleDialog> {

  late PatternPanelFieldStyle panelStyle;
  late Color currentColor;
  late ColorField currentColorField;
  late bool syncBorders;

  @override
  void initState() {
    panelStyle = widget.panelStyle;

    currentColor = panelStyle.backgroundColor;
    currentColorField = ColorField.backgroundColor;

    syncBorders = true;

    super.initState();
  }

  String get _currentColorFieldName => 
    currentColorField == ColorField.backgroundColor ? currentColorField.label :
      syncBorders ? 'All borders colour' : currentColorField.label;

  void _changeColour(Color newColor) {
    bool syncBorderColor = syncBorders && currentColorField != ColorField.backgroundColor;
    setState(() {
      panelStyle = panelStyle.copyWith(
        backgroundColor: currentColorField == ColorField.backgroundColor ? newColor : null,
        leftBorderColor: syncBorderColor || currentColorField == ColorField.leftBorderColor ? newColor : null,
        rightBorderColor: syncBorderColor || currentColorField == ColorField.rightBorderColor ? newColor : null,
        topBorderColor: syncBorderColor || currentColorField == ColorField.topBorderColor ? newColor : null,
        bottomBorderColor: syncBorderColor || currentColorField == ColorField.bottomBorderColor ? newColor : null,
      );
      currentColor = newColor;
    });
  }

  void _changeBorderWidth(BorderField borderField, double newWidth) {
    setState(() {
      panelStyle = panelStyle.copyWith(
        leftBorderWidth: syncBorders || borderField == BorderField.leftBorder ? newWidth : null,
        rightBorderWidth: syncBorders || borderField == BorderField.rightBorder ? newWidth : null,
        topBorderWidth: syncBorders || borderField == BorderField.topBorder ? newWidth : null,
        bottomBorderWidth: syncBorders || borderField == BorderField.bottomBorder ? newWidth : null,
      );
    });
  }

  void _changeBorderRadius(BorderCorner borderCorner, double newRadius) {
    setState(() {
      panelStyle = panelStyle.copyWith(
        topLeftRadius: syncBorders || borderCorner == BorderCorner.topLeft ? newRadius : null,
        topRightRadius: syncBorders || borderCorner == BorderCorner.topRight ? newRadius : null,
        bottomLeftRadius: syncBorders || borderCorner == BorderCorner.bottomLeft ? newRadius : null,
        bottomRightRadius: syncBorders || borderCorner == BorderCorner.bottomRight ? newRadius : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(1),
      title: const Text('Field settings'),
      content: SizedBox(
        width: 570,
        height: 770,
        child: Center(
          child: Column(
            children: [
              vspacing,
              FittedScale(
                scale: .8,
                child: SizedBox(
                  width: 570,
                  child: Column(
                    children: [
                      Row (
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Background colour:', textAlign: TextAlign.end,),
                          hspacing,
                          ColourWell(
                            selected: currentColorField == ColorField.backgroundColor, 
                            color: panelStyle.backgroundColor,
                            onTap: () {
                              if (currentColorField != ColorField.backgroundColor) {
                                setState(() {
                                  currentColorField = ColorField.backgroundColor;
                                  currentColor = panelStyle.backgroundColor;
                                });
                              }
                            } ,
                          ),
                        ],
                      ),
                      vspacing,
                      Table(
                        children: [
                          TableRow(
                            children: [
                              TableCell(
                                child: BorderRadiusSpinBox(
                                  corner: BorderCorner.topLeft, 
                                  initialValue: panelStyle.topLeftRadius, 
                                  onChanged: _changeBorderRadius
                                ),
                              ),
                              TableCell(
                                child: BorderWidthAndColourControl(
                                  borderField: BorderField.topBorder, 
                                  initialWidth: panelStyle.topBorderWidth, 
                                  colour: panelStyle.topBorderColor, 
                                  colourSelected: currentColorField == ColorField.topBorderColor || (currentColorField != ColorField.backgroundColor && syncBorders), 
                                  onWidthChanged: _changeBorderWidth, 
                                  onColourSelected: () {
                                    if (currentColorField != ColorField.topBorderColor) {
                                      setState(() {
                                        currentColorField = ColorField.topBorderColor;
                                        currentColor = panelStyle.topBorderColor;
                                      });
                                    }
                                  },
                                )
                              ),
                              TableCell(
                                child: BorderRadiusSpinBox(
                                  corner: BorderCorner.topRight,
                                  initialValue: panelStyle.topRightRadius,
                                  onChanged: _changeBorderRadius,
                                ),
                              ),
                            ]
                          ),
                          TableRow(
                            children: [
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: BorderWidthAndColourControl(
                                  borderField: BorderField.leftBorder, 
                                  initialWidth: panelStyle.leftBorderWidth, 
                                  colour: panelStyle.leftBorderColor, 
                                  colourSelected: currentColorField == ColorField.leftBorderColor || (currentColorField != ColorField.backgroundColor && syncBorders), 
                                  onWidthChanged: _changeBorderWidth, 
                                  onColourSelected: () {
                                    if (currentColorField != ColorField.leftBorderColor) {
                                      setState(() {
                                        currentColorField = ColorField.leftBorderColor;
                                        currentColor = panelStyle.leftBorderColor;
                                      });
                                    }
                                  },
                                )
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: 200,
                                    height: 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: panelStyle.backgroundColor,
                                        border: Border(
                                          top: BorderSide(color: panelStyle.topBorderColor, width: panelStyle.topBorderWidth),
                                          bottom: BorderSide(color: panelStyle.bottomBorderColor, width: panelStyle.bottomBorderWidth),
                                          left: BorderSide(color: panelStyle.leftBorderColor, width: panelStyle.leftBorderWidth),
                                          right: BorderSide(color: panelStyle.rightBorderColor, width: panelStyle.rightBorderWidth),
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: panelStyle.canSetRadius && panelStyle.topLeftRadius != PatternPanelFieldStyle.kDefaultBorderRadius ? Radius.circular(panelStyle.topLeftRadius) : Radius.zero,
                                          topRight: panelStyle.canSetRadius && panelStyle.topRightRadius != PatternPanelFieldStyle.kDefaultBorderRadius ? Radius.circular(panelStyle.topRightRadius) : Radius.zero,
                                          bottomLeft: panelStyle.canSetRadius && panelStyle.bottomLeftRadius != PatternPanelFieldStyle.kDefaultBorderRadius ? Radius.circular(panelStyle.bottomLeftRadius) : Radius.zero,
                                          bottomRight: panelStyle.canSetRadius && panelStyle.bottomRightRadius != PatternPanelFieldStyle.kDefaultBorderRadius ? Radius.circular(panelStyle.bottomRightRadius) : Radius.zero,
                                        )
                                      ),
                                      child: Center(
                                        child: IconButton(
                                          onPressed: () => setState(() => syncBorders = !syncBorders), 
                                          icon: Icon(syncBorders ? Icons.lock : Icons.lock_open)
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: BorderWidthAndColourControl(
                                  borderField: BorderField.rightBorder, 
                                  initialWidth: panelStyle.rightBorderWidth, 
                                  colour: panelStyle.rightBorderColor, 
                                  colourSelected: currentColorField == ColorField.rightBorderColor || (currentColorField != ColorField.backgroundColor && syncBorders), 
                                  onWidthChanged: _changeBorderWidth, 
                                  onColourSelected: () {
                                    if (currentColorField != ColorField.rightBorderColor) {
                                      setState(() {
                                        currentColorField = ColorField.rightBorderColor;
                                        currentColor = panelStyle.rightBorderColor;
                                      });
                                    }
                                  },
                                )
                              ),
                            ]
                          ),
                          TableRow(
                            children: [
                              TableCell(
                                child: BorderRadiusSpinBox(
                                  corner: BorderCorner.bottomLeft, 
                                  initialValue: panelStyle.bottomLeftRadius, 
                                  onChanged: _changeBorderRadius
                                )
                              ),
                              TableCell(
                                child: BorderWidthAndColourControl(
                                  borderField: BorderField.bottomBorder, 
                                  initialWidth: panelStyle.bottomBorderWidth, 
                                  colour: panelStyle.bottomBorderColor, 
                                  colourSelected: currentColorField == ColorField.bottomBorderColor || (currentColorField != ColorField.backgroundColor && syncBorders), 
                                  onWidthChanged: _changeBorderWidth, 
                                  onColourSelected: () {
                                    if (currentColorField != ColorField.bottomBorderColor) {
                                      setState(() {
                                        currentColorField = ColorField.bottomBorderColor;
                                        currentColor = panelStyle.bottomBorderColor;
                                      });
                                    }
                                  }
                                )
                              ),
                              TableCell(
                                child: BorderRadiusSpinBox(
                                  corner: BorderCorner.bottomRight, 
                                  initialValue: panelStyle.bottomRightRadius, 
                                  onChanged: _changeBorderRadius
                                )
                              ),
                            ]
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              const Divider(indent: 15, endIndent: 15, color: Colors.grey,),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 30,),
                  Text('$_currentColorFieldName:'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 570,
                    child: Center(
                      child: PickColourControl(
                        initialColor: currentColor,
                        knownColours: widget.knownColours,
                        knownColoursLabel: 'Pattern colours',
                        onChanged: _changeColour,
                      ),
                    ),
                  ),
                ],
              ),
            ]
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
            Navigator.of(context).pop(panelStyle);
          }, 
          child: const Text('Ok')
        )
      ],
    );
  }
}