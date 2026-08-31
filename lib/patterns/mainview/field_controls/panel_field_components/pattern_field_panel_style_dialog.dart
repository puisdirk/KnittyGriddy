import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/panel_field_components/border_radius_spin_box.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/panel_field_components/colour_well.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field_style.dart';
import 'package:knitty_griddy/patterns/model/pattern_page_layout.dart';
import 'package:knitty_griddy/common/pick_colour_control.dart';
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

  static const double _kSpinBoxWidth = 140;
  static const double _kMaxBorderWidth = 20;
  static const String _allBordersColour = 'All borders colour';

  late PatternPanelFieldStyle panelStyle;
  late Color currentColor;
  late ColorField currentColorField;
  bool syncBorders = true;

  @override
  void initState() {
    panelStyle = widget.panelStyle;

    currentColor = panelStyle.backgroundColor;
    currentColorField = ColorField.backgroundColor;

    super.initState();
  }

  Set<Color> get _knownColours => Set.from(widget.knownColours)..addAll(panelStyle.knownColours)..removeAll([Colors.black, Colors.white, Colors.transparent]);

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

  void _changeMaxHeight(double maxHeight) {
    setState(() => panelStyle = panelStyle.copyWith(maxHeight: maxHeight));
  }

  void _changeMaxWidth(double maxWidth) {
    setState(() => panelStyle = panelStyle.copyWith(maxWidth: maxWidth));
  }

  Widget _colourPopup(String colorFieldName, Color initialColor) =>
    SizedBox(
      width: 370,
      height: 490,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('$colorFieldName:'),
            ],
          ),
          vspacing,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 350,
                child: Center(
                  child: PickColourControl(
                    initialColor: initialColor,
                    knownColours: _knownColours.toList(),
                    knownColoursLabel: 'Pattern colours',
                    onChanged: _changeColour,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(1),
      title: const Text('Panel settings'),
      content: SizedBox(
        width: 640,
        height: 400,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: SizedBox(
                  width: 570,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Max. Width'),
                      hspacing,
                      SizedBox(
                        width: 160,
                        child: SpinBox(
                          min: 0,
                          max: PatternPageLayout.maxPageWidth,
                          value: panelStyle.maxWidth,
                          onChanged: (value) => _changeMaxWidth(value),
                        ),
                      ),
                      hspacing,
                      hspacing,
                      const Text('Max. Height'),
                      hspacing,
                      SizedBox(
                        width: 160,
                        child: SpinBox(
                          min: 0,
                          max: PatternPageLayout.maxPageHeight,
                          value: panelStyle.maxHeight,
                          onChanged: (value) => _changeMaxHeight(value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              vspacing,
              vspacing,
              SizedBox(
                width: 570,
                child: Column(
                  children: [
                    Row (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Background colour:', textAlign: TextAlign.end,),
                        hspacing,
                        CustomPopup(
                          content: _colourPopup(ColorField.backgroundColor.label, panelStyle.backgroundColor),
                          barrierColor: Colors.transparent,
                          contentDecoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            color: Colors.white
                          ),
                          arrowColor: Colors.grey,
                          onBeforePopup: () {
                            if (currentColorField != ColorField.backgroundColor) {
                              setState(() {
                                currentColorField = ColorField.backgroundColor;
                                currentColor = panelStyle.backgroundColor;
                              });
                            }
                          },
                          child: ColourWell(
                            selected: false, 
                            color: panelStyle.backgroundColor,
                          ),
                        ),
                      ],
                    ),
                    vspacing,
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
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: _kSpinBoxWidth,
                                    child: SpinBox(
                                      onChanged: (value) => _changeBorderWidth(BorderField.topBorder, value),
                                      min: 0,
                                      max: _kMaxBorderWidth,
                                      decimals: 1,
                                      step: .1,
                                      value: panelStyle.topBorderWidth,
                                    ),
                                  ),
                                  hspacing,
                                  CustomPopup(
                                    content: _colourPopup(
                                      syncBorders ? _allBordersColour : ColorField.topBorderColor.label,
                                      panelStyle.topBorderColor
                                    ),
                                    barrierColor: Colors.transparent,
                                    contentDecoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      color: Colors.white
                                    ),
                                    arrowColor: Colors.grey,
                                    onBeforePopup: () {
                                      if (currentColorField != ColorField.topBorderColor) {
                                        setState(() {
                                          currentColorField = ColorField.topBorderColor;
                                          currentColor = panelStyle.topBorderColor;
                                        });
                                      }
                                    },
                                    child: ColourWell(
                                      selected: false,
                                      color: panelStyle.topBorderColor,
                                    ),
                                  ),
                                ],
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
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: _kSpinBoxWidth,
                                    child: SpinBox(
                                      onChanged: (value) => _changeBorderWidth(BorderField.leftBorder, value),
                                      min: 0,
                                      max: _kMaxBorderWidth,
                                      decimals: 1,
                                      step: .1,
                                      value: panelStyle.leftBorderWidth,
                                    ),
                                  ),
                                  hspacing,
                                  CustomPopup(
                                    content: _colourPopup(
                                      syncBorders ? _allBordersColour : ColorField.leftBorderColor.label, 
                                      panelStyle.leftBorderColor
                                    ), 
                                    barrierColor: Colors.transparent,
                                    contentDecoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      color: Colors.white
                                    ),
                                    arrowColor: Colors.grey,
                                    onBeforePopup: () {
                                      if (currentColorField != ColorField.leftBorderColor) {
                                        setState(() {
                                          currentColorField = ColorField.leftBorderColor;
                                          currentColor = panelStyle.leftBorderColor;
                                        });
                                      }
                                    },
                                    child: ColourWell(
                                      selected: false,
                                      color: panelStyle.leftBorderColor,
                                    ),
                                  ),
                                ],
                              )
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SizedBox(
                                  width: 200,
                                  height: 100,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        child: Center(
                                          child: Container(
                                            height: panelStyle.maxHeight == PatternPanelFieldStyle.kDefaultMaxHeight ? null : panelStyle.maxHeight,
                                            width: panelStyle.maxWidth == PatternPanelFieldStyle.kDefaultMaxWidth ? null : panelStyle.maxWidth,
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
                                        ),
                                      ),
                                      Positioned(
                                        child: Center(
                                          child: IconButton(
                                            onPressed: () => setState(() => syncBorders = !syncBorders), 
                                            icon: Icon(syncBorders ? Icons.lock : Icons.lock_open)
                                          ),
                                         ),
                                      ),
                                    ]
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: _kSpinBoxWidth,
                                    child: SpinBox(
                                      onChanged: (value) => _changeBorderWidth(BorderField.rightBorder, value),
                                      min: 0,
                                      max: _kMaxBorderWidth,
                                      decimals: 1,
                                      step: .1,
                                      value: panelStyle.rightBorderWidth,
                                    ),
                                  ),
                                  hspacing,
                                  CustomPopup(
                                    content: _colourPopup(
                                      syncBorders ? _allBordersColour : ColorField.rightBorderColor.label, 
                                      panelStyle.rightBorderColor
                                    ), 
                                    barrierColor: Colors.transparent,
                                    contentDecoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      color: Colors.white
                                    ),
                                    arrowColor: Colors.grey,
                                    onBeforePopup: () {
                                      if (currentColorField != ColorField.rightBorderColor) {
                                        setState(() {
                                          currentColorField = ColorField.rightBorderColor;
                                          currentColor = panelStyle.rightBorderColor;
                                        });
                                      }
                                    },
                                    child: ColourWell(
                                      selected: false,
                                      color: panelStyle.rightBorderColor,
                                    ),
                                  ),
                                ],
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
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: _kSpinBoxWidth,
                                    child: SpinBox(
                                      onChanged: (value) => _changeBorderWidth(BorderField.bottomBorder, value),
                                      min: 0,
                                      max: _kMaxBorderWidth,
                                      decimals: 1,
                                      step: .1,
                                      value: panelStyle.bottomBorderWidth,
                                    ),
                                  ),
                                  hspacing,
                                  CustomPopup(
                                    content: _colourPopup(
                                      syncBorders ? _allBordersColour : ColorField.bottomBorderColor.label, 
                                      panelStyle.bottomBorderColor
                                    ), 
                                    barrierColor: Colors.transparent,
                                    contentDecoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      color: Colors.white
                                    ),
                                    arrowColor: Colors.grey,
                                    onBeforePopup: () {
                                      if (currentColorField != ColorField.bottomBorderColor) {
                                        setState(() {
                                          currentColorField = ColorField.bottomBorderColor;
                                          currentColor = panelStyle.bottomBorderColor;
                                        });
                                      }
                                    },
                                    child: ColourWell(
                                      selected: false,
                                      color: panelStyle.bottomBorderColor,
                                    ),
                                  ),
                                ],
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
              vspacing,
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