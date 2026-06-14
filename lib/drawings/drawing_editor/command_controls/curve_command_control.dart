import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/formulas/formula_field_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class CurveCommandControl extends StatefulWidget {
  final CurveCommand command;
  final bool sorting;
  final bool editing;

  const CurveCommandControl({
    required this.command,
    required this.sorting,
    required this.editing,
    super.key
  });

  @override
  State<CurveCommandControl> createState() => _CurveCommandControlState();
}

class _CurveCommandControlState extends State<CurveCommandControl> {

  void curveLabelChanged(String newText) {
    if (widget.command.label != newText) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(label: newText));
    }
  }

  void quadAmplitudeFormulaChanged(String formula) {
    if (widget.command.quadAmplitudeFormula != formula) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(quadAmplitudeFormula: formula));
    }
  }

  void quadSlantFormulaChanged(String formula) {
    if (widget.command.quadSlantFormula != formula) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(quadSlantFormula: formula));
    }
  }

  void cubicAmplitude1FormulaChanged(String formula) {
    if (widget.command.cubicAmplitudeFormula1 != formula) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(cubicAmplitudeFormula1: formula));
    }
  }

  void cubicSlant1FormulaChanged(String formula) {
    if (widget.command.cubicSlantFormula1 != formula) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(cubicSlantFormula1: formula));
    }
  }

  void cubicAmplitude2FormulaChanged(String formula) {
    if (widget.command.cubicAmplitudeFormula2 != formula) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(cubicAmplitudeFormula2: formula));
    }
  }

  void cubicSlant2FormulaChanged(String formula) {
    if (widget.command.cubicSlantFormula2 != formula) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(cubicSlantFormula2: formula));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget createViewContent() {
    final Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;

    String content = ' Curve ';

    String startPointLabel = '???';
    PointCommand? startPoint = drawing.pointById(widget.command.startPointId);
    if (startPoint != null) {
      startPointLabel = startPoint.label;
    }

    String endPointLabel = '???';
    PointCommand? endPoint = drawing.pointById(widget.command.endPointId);
    if (endPoint != null) {
      endPointLabel = endPoint.label;
    }

    content += 'between $startPointLabel and $endPointLabel ';

    switch (widget.command.curveDefinitionType) {
      case CurveDefinitionType.quadratic:
        String ampLabel = '???';
        String slantLabel = '???';
        if (widget.command.quadAmplitudeFormula.isNotEmpty) {
          ampLabel = widget.command.quadAmplitudeFormula;
        }

        if (widget.command.quadSlantFormula.isNotEmpty) {
          slantLabel = widget.command.quadSlantFormula;
        }

        content += 'quadratic with amplitude $ampLabel and slant $slantLabel';
        break;
      case CurveDefinitionType.cubic:
        String ampLabel = '???';
        String slantLabel = '???';
        if (widget.command.cubicAmplitudeFormula1.isNotEmpty) {
          ampLabel = widget.command.cubicAmplitudeFormula1;
        }

        if (widget.command.cubicSlantFormula1.isNotEmpty) {
          slantLabel = widget.command.cubicSlantFormula1;
        }

        content += 'cubic with amplitude $ampLabel and slant $slantLabel';
        break;
      case CurveDefinitionType.quadraticFromPoints:
        String ctrlPointLabel = '???';
        PointCommand? ctrlPoint = drawing.pointById(widget.command.quadCtrlPointId);
        if (ctrlPoint != null) {
          ctrlPointLabel = ctrlPoint.label;
        }

        content += 'quadratic with control point $ctrlPointLabel';
        break;
      case CurveDefinitionType.cubicFromPoints:
        String ctrlPoint1Label = '???';
        String ctrlPoint2Label = '???';
        PointCommand? ctrlPoint1 = drawing.pointById(widget.command.cubicCtrlPointId1);
        if (ctrlPoint1 != null) {
          ctrlPoint1Label = ctrlPoint1.label;
        }
        PointCommand? ctrlPoint2 = drawing.pointById(widget.command.cubicCtrlPointId2);
        if (ctrlPoint2 != null) {
          ctrlPoint2Label = ctrlPoint2.label;
        }

        content += 'cubic with control points $ctrlPoint1Label and $ctrlPoint2Label';
        break;
    }
  
    return Row(
      children: [
        const Icon(Symbols.line_curve),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold,),
                TextSpan(text: content, style: smallStyle,)
              ]
            )
          ),
        )
      ],
    );
  }

  Widget createEditContent() {
    final Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;
    final double labelWidth = widget.command.curveDefinitionType == CurveDefinitionType.cubicFromPoints ? 90 : 70;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Curve', style: smallStyle,),
            hspacing,
            DropdownButton<CurveDefinitionType>(
              key: GlobalObjectKey('${widget.command.id}-cdt'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                for (CurveDefinitionType cdt in CurveDefinitionType.values)
                  DropdownMenuItem(value: cdt, child: Text(cdt.label))
              ],
              value: widget.command.curveDefinitionType,
              onChanged: (value) {
                if (value != widget.command.curveDefinitionType) {
                  Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(curveDefinitionType: value));
                }
              },
            ),            
          ],
        ),
        vspacing,
        Row(
          children: [
            SmallLabel(label: 'Label', width: labelWidth,),
            hspacing,
            SmallTextField(
              key: GlobalObjectKey('${widget.command.id}-label'),
              initialText: widget.command.label,
              width: 100,
              onTextChanged: curveLabelChanged,
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            SmallLabel(label: 'From', width: labelWidth,),
            hspacing,
            DropdownButton<String>(
              key: GlobalObjectKey('${widget.command.id}-from'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),
                if (widget.command.endPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in drawing.points.where((p) => p.id != widget.command.endPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != widget.command.startPointId) {
                  Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(startPointId: value?? ''));
                }
              },
              value: widget.command.startPointId,
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            SmallLabel(label: 'To', width: labelWidth,),
            hspacing,
            DropdownButton<String>(
              key: GlobalObjectKey('${widget.command.id}-to'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),
                if (widget.command.startPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in drawing.points.where((p) => p.id != widget.command.startPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != widget.command.endPointId) {
                  Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(endPointId: value?? ''));
                }
              },
              value: widget.command.endPointId,
            ),
          ],
        ),
        vspacing,
        if (widget.command.curveDefinitionType == CurveDefinitionType.quadratic)
          Column(
            children: [
              Row(
                children: [
                  SmallLabel(label: 'Amplitude', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: GlobalObjectKey('${widget.command.id}-qamp'),
                    formula: widget.command.quadAmplitudeFormula, 
                    width: 240, 
                    excludeCommand: widget.command, 
                    onFormulaChanged: quadAmplitudeFormulaChanged,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  SmallLabel(label: 'Slant', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: GlobalObjectKey('${widget.command.id}-qslant'),
                    formula: widget.command.quadSlantFormula, 
                    width: 240, 
                    excludeCommand: widget.command,
                    onFormulaChanged: quadSlantFormulaChanged,
                  ),
                ]
              ),
            ],
          ),
        if (widget.command.curveDefinitionType == CurveDefinitionType.cubic)
          Column(
            children: [
              Row(
                children: [
                  SmallLabel(label: 'Amplitude 1', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: GlobalObjectKey('${widget.command.id}-camp1'),
                    formula: widget.command.cubicAmplitudeFormula1, 
                    width: 240, 
                    excludeCommand: widget.command, 
                    onFormulaChanged: cubicAmplitude1FormulaChanged,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  SmallLabel(label: 'Slant 1', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: GlobalObjectKey('${widget.command.id}-cslant1'),
                    formula: widget.command.cubicSlantFormula1, 
                    width: 240, 
                    excludeCommand: widget.command,
                    onFormulaChanged: cubicSlant1FormulaChanged,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  SmallLabel(label: 'Amplitude 2', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: GlobalObjectKey('${widget.command.id}-camp2'),
                    formula: widget.command.cubicAmplitudeFormula2, 
                    width: 240, 
                    excludeCommand: widget.command, 
                    onFormulaChanged: cubicAmplitude2FormulaChanged,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  SmallLabel(label: 'Slant 2', width: labelWidth,),
                  hspacing,
                  FormulaFieldControl(
                    key: GlobalObjectKey('${widget.command.id}-cslant1'),
                    formula: widget.command.cubicSlantFormula2, 
                    width: 240, 
                    excludeCommand: widget.command,
                    onFormulaChanged: cubicSlant2FormulaChanged,
                  ),
                ]
              ),
            ],
          ),
        if (widget.command.curveDefinitionType == CurveDefinitionType.quadraticFromPoints)
          Row(
            children: [
              SmallLabel(label: 'Control point', width: labelWidth,),
              hspacing,
              DropdownButton<String>(
                key: GlobalObjectKey('${widget.command.id}-qctrl'),
                isDense: true,
                autofocus: false,
                style: smallStyle,
                itemHeight: kMinInteractiveDimension,
                focusColor: Colors.transparent,
                underline: Container(),
                items: [
                  const DropdownMenuItem(value: '', child: Text('')),
                  if (widget.command.quadCtrlPointId != origin.id)
                    DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                  for (PointCommand point in drawing.points)
                    DropdownMenuItem(value: point.id, child: Text(point.label)),
                ],
                onChanged: (value) {
                  if (value != widget.command.quadCtrlPointId) {
                    Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(quadCtrlPointId: value?? ''));
                  }
                },
                value: widget.command.quadCtrlPointId,
              ),
            ],
          ),
        if (widget.command.curveDefinitionType == CurveDefinitionType.cubicFromPoints)
          Column(
            children: [
              Row(
                children: [
                  SmallLabel(label: 'Control point 1', width: labelWidth,),
                  hspacing,
                  DropdownButton<String>(
                    key: GlobalObjectKey('${widget.command.id}-cctrl1'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),
                      DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                      for (PointCommand point in drawing.points)
                        DropdownMenuItem(value: point.id, child: Text(point.label)),
                    ],
                    onChanged: (value) {
                      if (value != widget.command.cubicCtrlPointId1) {
                        Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(cubicCtrlPointId1: value?? ''));
                      }
                    },
                    value: widget.command.cubicCtrlPointId1,
                  ),
                ],
              ),
              vspacing,
              Row(
                children: [
                  SmallLabel(label: 'Control point 2', width: labelWidth,),
                  hspacing,
                  DropdownButton<String>(
                    key: GlobalObjectKey('${widget.command.id}-cctrl2'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),
                      DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                      for (PointCommand point in drawing.points)
                        DropdownMenuItem(value: point.id, child: Text(point.label)),
                    ],
                    onChanged: (value) {
                      if (value != widget.command.cubicCtrlPointId2) {
                        Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(cubicCtrlPointId2: value?? ''));
                      }
                    },
                    value: widget.command.cubicCtrlPointId2,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.editing && !widget.sorting) ? createEditContent() : createViewContent();
  }
}