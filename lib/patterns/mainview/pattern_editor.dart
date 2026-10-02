import 'dart:convert';
import 'dart:math';

import 'package:fitted_scale/fitted_scale.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_field_control.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/nudge_control.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_chart_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_drawing_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_image_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_panel_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_text_editor_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fleather/fleather_font_style.dart';
import 'package:knitty_griddy/patterns/mainview/fleather/text_editor_field_settings_dialog.dart';
import 'package:knitty_griddy/patterns/mainview/page_margin_painter.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/fields/text_editor_field_settings.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/pattern_page_layout.dart';
import 'package:knitty_griddy/utils/app_platform_ext.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:knitty_griddy/utils/undo_redo_manager.dart';

class PatternEditor extends StatefulWidget {
  final KnittingPattern pattern;
  final UndoRedoManager undoRedoManager;
  final void Function(KnittingPattern newPattern, {bool? storeForUndo}) onChanged;

  const PatternEditor({
    required this.pattern,
    required this.undoRedoManager,
    required this.onChanged,
    super.key
  });

  @override
  State<PatternEditor> createState() => _PatternEditorState();
}

class _PatternEditorState extends State<PatternEditor> {
  late KnittingPattern stateKnittingPattern;

  late FocusNode _keyboardFocusNode;
  bool keyboardShiftDown = false;
  bool keyboardControlDown = false;
  late bool showContentControls;

  PatternField? selectedField;

  late Map<String, FleatherController> fleatherControllers;
  late Map<String, GlobalKey> fleaterEditorKeys;

  late FleatherClipboardData? clipboardData;

  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    _keyboardFocusNode = FocusNode();

    stateKnittingPattern = widget.pattern;
    selectedField = null;
    clipboardData = null;

    showContentControls = false;

    fleatherControllers = {};
    fleaterEditorKeys = {};
    for (PatternTextEditorField field in widget.pattern.textEditorFields) {
      ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode(field.docContents));
      fleatherControllers[field.id] = FleatherController(document: document);
      final GlobalKey<EditorState> editorKey = GlobalKey();
      fleaterEditorKeys[field.id] = editorKey;
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PatternEditor oldWidget) {
    stateKnittingPattern = widget.pattern;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    for (FleatherController controller in fleatherControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  void _storeAndSetKnittingPattern(
    KnittingPattern newPattern, {
      void Function()? additionalState,
      bool? storeForUndo,
    }) {
    widget.onChanged(newPattern, storeForUndo: storeForUndo);
    setState(() {
      stateKnittingPattern = newPattern;
      if (additionalState != null) additionalState();
    });
  }

  void _addNewField(PatternFieldType type) {
    double posY = _verticalScrollController.offset;
    double posX = PatternPageLayout.margin;
    // If we didn't scroll, place the new field inside the margins
    if (posY == 0) {
      posY = PatternPageLayout.margin;
    }
    PatternField newField = _createNewField(type, posX, posY);
    _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
      fields: [...stateKnittingPattern.fields, newField]
    ), additionalState: () {
      if (newField.fieldType == PatternFieldType.texteditor) {
        ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode((newField as PatternTextEditorField).docContents));
        FleatherController controller = FleatherController(document: document);
        fleatherControllers = Map.from(fleatherControllers)..addAll({newField.id: controller});
        final GlobalKey<EditorState> editorKey = GlobalKey();
        fleaterEditorKeys = Map.from(fleaterEditorKeys)..addAll({newField.id: editorKey});
      }
      selectedField = newField;
    });
  }

  void _deleteField(String fieldId) {
    PatternField fieldToDelete = stateKnittingPattern.fields.firstWhere((f) => f.id == fieldId);
    if (fieldToDelete is PatternTextEditorField && stateKnittingPattern.textFieldLinks.hasLink(fieldToDelete.id)) {
      _reflowField(fieldToDelete.id, forDeletion: true);
    } else {
      _storeAndSetKnittingPattern(
        stateKnittingPattern.copyWith(
          fields: stateKnittingPattern.fields.where((f) => f.id != fieldToDelete.id).toList()
        ),
        additionalState: () {
          if (fieldToDelete.fieldType == PatternFieldType.texteditor) {
            FleatherController? controller = fleatherControllers[fieldToDelete.id];
            if (controller != null) {
              controller.dispose();
            }
            fleatherControllers = Map.from(fleatherControllers)..remove(fieldToDelete.id);
            fleaterEditorKeys = Map.from(fleaterEditorKeys)..remove(fieldToDelete.id);
          }
          if (selectedField?.id == fieldId) {
            selectedField = null;
          }
        },
      );
    }
  }

  PatternField _createNewField(PatternFieldType type, double posX, double posY) {
    final String id = const UuidV4Gen().get();
    switch (type) {
      case PatternFieldType.texteditor:
        return PatternTextEditorField(
          id: id,
          positionX: posX,
          positionY: posY
        );
      case PatternFieldType.knittingchart:
        return PatternChartField(
          id: id,
          positionX: posX,
          positionY: posY
        );
      case PatternFieldType.drawing:
        return PatternDrawingField(
          id: id,
          positionX: posX,
          positionY: posY
        );
      case PatternFieldType.image:
        return PatternImageField(
          id: id,
          positionX: posX,
          positionY: posY
        );
      case PatternFieldType.panel:
        return PatternPanelField(
          id: id,
          positionX: posX,
          positionY: posY
        );
    }
  }

  void _moveSelectedFieldForward (bool allTheWay) {
    if (selectedField == null) return;

    List<PatternField> newFields = List.from(stateKnittingPattern.fields);
    int idx = newFields.indexWhere((f) => f.id == selectedField!.id);
    if (idx < newFields.length - 1) {
      PatternField temp = newFields.removeAt(idx);
      if (allTheWay) {
        newFields.add(temp);
      } else {
        newFields.insert(idx + 1, temp);
      }
      _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
        fields: newFields,
      ));
    }
  }

  void _moveSelectedFieldBackward(bool allTheWay) {
    if (selectedField == null) return;

    List<PatternField> newFields = List.from(stateKnittingPattern.fields);
    int idx = newFields.indexWhere((f) => f.id == selectedField!.id);
    if (idx > 0) {
      PatternField temp = newFields.removeAt(idx);
      newFields.insert(allTheWay ? 0 : idx - 1, temp);
      _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
        fields: newFields,
      ));
    }
  }

  void _cycleSelectedField(PatternFieldType type, bool reversed) {
    List<PatternField> fieldsOfType = stateKnittingPattern.fields.where((f) => f.fieldType == type).toList();
    if (fieldsOfType.isEmpty) return;

    if (fieldsOfType.length == 1) {
      if (selectedField != fieldsOfType.first) {
        setState(() => selectedField = fieldsOfType.first);
      }
      return;
    }
    
    if (selectedField?.fieldType != type) {
      setState(() => selectedField = reversed ? fieldsOfType.last : fieldsOfType.first);
      return;
    }
    
    int idx = fieldsOfType.indexWhere((f) => f.id == selectedField?.id);
    if (idx != -1) {
      if (idx == 0 && reversed) {
        setState(() => selectedField = fieldsOfType.last);
        return;
      }
      if (idx == fieldsOfType.length - 1 && !reversed) {
        setState(() => selectedField = fieldsOfType.first);
        return;
      }

      int newIdx = reversed ? idx - 1 : idx + 1;
      setState(() => selectedField = fieldsOfType[newIdx]);
    }
  }

  void _reflowField(String fromFieldId, {bool forDeletion = false}) {
    // Concatenate all contents of the linked fields into one document

    // Find the start link
    String? startId = stateKnittingPattern.textFieldLinks.getStartId(fromFieldId);
    if (startId == null) return;

    List<PatternTextEditorField> linkedFields = [];

    PatternTextEditorField nextField = stateKnittingPattern.textEditorFields.firstWhere((f) => f.id == startId);
    if (!forDeletion || nextField.id != fromFieldId) {
      linkedFields.add(nextField);
    }

    List<dynamic> completeDocJson = [];

    if (nextField.docContents != PatternTextEditorField.emptyDoc) {
      completeDocJson.addAll(jsonDecode(nextField.docContents));
    }

    // while we have a linked field, add content to the complete document
    while (true) {
      String nextFieldId = stateKnittingPattern.textFieldLinks.links.firstWhere((l) => l.fromId == nextField.id).toId;
      nextField = stateKnittingPattern.textEditorFields.firstWhere((f) => f.id == nextFieldId);
      if (!forDeletion || nextFieldId != fromFieldId) {
        linkedFields.add(nextField);
      }
      if (nextField.docContents != PatternTextEditorField.emptyDoc) {
        completeDocJson.addAll(jsonDecode(nextField.docContents));
      }
      
      if (!stateKnittingPattern.textFieldLinks.hasOutgoingLink(nextFieldId)) {
        break;
      }
    }

    Map<String, PatternTextEditorField> changedFields = {};

    // If we have content, divide it over the linked fields
    if (completeDocJson.isNotEmpty) {
      ParchmentDocument completeDocument = ParchmentDocument.fromJson(completeDocJson);

      LookupResult res = completeDocument.lookupLine(0);
      if (res.isEmpty) {
        return;
      }
      LineNode? lineNode = res.node! as LineNode;

      for (PatternTextEditorField field in linkedFields) {
        if (lineNode == null) {
          changedFields[field.id] = field.copyWith(docContents: PatternTextEditorField.emptyDoc);
          continue;
        }

        FleatherFontStyle fs = FleatherFontStyle(textStyle: field.settings.style);
        Delta fieldDelta = Delta();
        // We have draggerheight as padding around + padding of 5 inside the editor
        double remainingHeight = field.height - (2 * kDraggerHeight) - (2 * 5);

        while (true) {
          if (field == linkedFields.last) {
            // We are the last field in the link chain, so keep adding lines without measuring
            fieldDelta = lineNode!.toDelta().compose(fieldDelta);
          } else {
            // Check if the line would still fit
            TextStyle lineStyle = fs.textStyleForParchmentStyle(lineNode!.style);

            TextAlign lineAlign = TextAlign.left;
            if (lineNode.style.contains(ParchmentAttribute.alignment)) {
              String? alignment = lineNode.style.get(ParchmentAttribute.alignment)!.value;
              if (alignment == 'right') lineAlign = TextAlign.right;
              if (alignment == 'center') lineAlign = TextAlign.center;
              if (alignment == 'justify') lineAlign = TextAlign.justify;
            }

            // We have draggerheight as padding around + padding of 5 inside the editor
            double maxWidth = field.width - (2 * kDraggerHeight) - (2 * 5);
            if (lineNode.style.contains(ParchmentAttribute.indent)) {
              int? indents = lineNode.style.get(ParchmentAttribute.indent)!.value;
              if (indents != null) {
                String indentSpaces = ''.padRight(indents * 4);
                maxWidth -= MathUtitilies.textSize(indentSpaces, lineStyle).width;
              }
            }

            // Measure the height of the line
            double lineHeight = MathUtitilies.textSize(
              lineNode.toPlainText().trim(), 
              lineStyle, 
              maxLines: null, 
              maxWidth: maxWidth,
              textAlign: lineAlign,
            ).height;

            VerticalSpacing spacing = FleatherFontStyle.spacingForParchmentStyle(lineNode.style);
            lineHeight += spacing.top + spacing.bottom;

            if (lineHeight < remainingHeight) {
              fieldDelta = lineNode.toDelta().compose(fieldDelta);
              remainingHeight -= lineHeight;
            } else {
              // No more space in this field
              break;
            }
          }

          lineNode = lineNode.nextLine;
          if (lineNode == null) {
            break;
          }
        }

        // Delta for this field is complete
        changedFields[field.id] = field.copyWith(docContents: fieldDelta.isEmpty ? PatternTextEditorField.emptyDoc : jsonEncode(fieldDelta.toJson()));
      }
    }

    if (forDeletion) {
      // If this is for the deletion of a link, also reroute
      _storeAndSetKnittingPattern(
        stateKnittingPattern.copyWith(
          fields: stateKnittingPattern.fields.where((f) => f.id != fromFieldId).map((f) => changedFields.containsKey(f.id) ? changedFields[f.id]! : f).toList(),
          textFieldLinks: stateKnittingPattern.textFieldLinks.rerouteLinksForDeletion(fromFieldId),
        ), additionalState: () {
        for (PatternTextEditorField changedField in changedFields.values) {
          fleatherControllers[changedField.id] = FleatherController(document: ParchmentDocument.fromJson(jsonDecode(changedField.docContents)));
        }

        fleatherControllers[fromFieldId]!.dispose();
        fleatherControllers = Map.from(fleatherControllers)..remove(fromFieldId);
        fleaterEditorKeys = Map.from(fleaterEditorKeys)..remove(fromFieldId);
        if (selectedField?.id == fromFieldId) {
          selectedField = null;
        }
      });
    } else {
      _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
        fields: stateKnittingPattern.fields.map((f) => changedFields.containsKey(f.id) ? changedFields[f.id]! : f).toList()
      ), additionalState: () {
        for (PatternTextEditorField changedField in changedFields.values) {
          fleatherControllers[changedField.id]!.dispose();
          fleatherControllers[changedField.id] = FleatherController(document: ParchmentDocument.fromJson(jsonDecode(changedField.docContents)));
        }
        if (changedFields.keys.contains(selectedField?.id)) {
          selectedField = changedFields[selectedField?.id];
        }
      });
    }
  }

  void _duplicateSelectedField() {
    if (selectedField == null) return;

    String id = const UuidV4Gen().get();

    // move the new field 10 down and right
    double posX = selectedField!.positionX + 10;
    double posY = selectedField!.positionY + 10;

    // if that would tip it over the page edge, move in the other direction
    if (posX + selectedField!.width > stateKnittingPattern.pageLayout.pagewidth ||
      posY + selectedField!.height > stateKnittingPattern.pageLayout.pageheight) {
      posX = selectedField!.positionX - 10;
      posY = selectedField!.positionY - 10;
    }

    PatternField newField;
    switch (selectedField!.fieldType) {
      case PatternFieldType.drawing:
        newField = (selectedField as PatternDrawingField).copyWith(
          id: id,
          positionX: posX,
          positionY: posY,
        );
        break;
      case PatternFieldType.image:
        newField = (selectedField as PatternImageField).copyWith(
          id: id,
          positionX: posX,
          positionY: posY,
        );
        break;
      case PatternFieldType.knittingchart:
        newField = (selectedField as PatternChartField).copyWith(
          id: id,
          positionX: posX,
          positionY: posY,
        );
        break;
      case PatternFieldType.panel:
        newField = (selectedField as PatternPanelField).copyWith(
          id: id,
          positionX: posX,
          positionY: posY,
        );
        break;
      case PatternFieldType.texteditor:
        newField = (selectedField as PatternTextEditorField).copyWith(
          id: id,
          positionX: posX,
          positionY: posY,
        );
        break;
    }

    _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
      fields: [...stateKnittingPattern.fields, newField]
    ), additionalState: () {
      if (newField.fieldType == PatternFieldType.texteditor) {
        ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode((newField as PatternTextEditorField).docContents));
        FleatherController controller = FleatherController(document: document);
        fleatherControllers = Map.from(fleatherControllers)..addAll({id: controller});
        final GlobalKey<EditorState> editorKey = GlobalKey();
        fleaterEditorKeys = Map.from(fleaterEditorKeys)..addAll({id: editorKey});
      }
      selectedField = newField;
    });
  }

  void _undo() {
    if (widget.undoRedoManager.canUndo()) {
      KnittingPattern newPattern = widget.undoRedoManager.undo();

      Map<String, FleatherController> newControllers = {};
      Map<String, GlobalKey> newEditorKeys = {};
      
      // A textEditorField got deleted
      for (PatternTextEditorField field in stateKnittingPattern.textEditorFields.
        where((f) => !newPattern.fields.any((oldf) => oldf.id == f.id))) {
        FleatherController? ctrller = fleatherControllers[field.id];
        ctrller?.dispose();
      }
      for (PatternTextEditorField field in newPattern.textEditorFields) {
        if (!stateKnittingPattern.fields.any((oldf) => oldf.id == field.id)) {
          // A textEditorField got added
          ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode(field.docContents));
          newControllers[field.id] = FleatherController(document: document);
          final GlobalKey<EditorState> editorKey = GlobalKey();
          newEditorKeys[field.id] = editorKey;
        } else {
          // A textEditorField remained
          fleatherControllers[field.id]!.dispose();
          ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode(field.docContents));
          newControllers[field.id] = FleatherController(document: document);
          newEditorKeys[field.id] = fleaterEditorKeys[field.id]!;
        }
      }

      _storeAndSetKnittingPattern(newPattern, storeForUndo: false, additionalState: () {
        fleatherControllers = newControllers;
        fleaterEditorKeys = newEditorKeys;
        if (selectedField != null) {
          if (!newPattern.fields.any((f) => f.id == selectedField!.id)) {
            selectedField = null;    
          } else {
            selectedField = newPattern.fields.firstWhere((f) => f.id == selectedField!.id);
          }
        }
      });
    }
  }

  void _redo() {
    if (widget.undoRedoManager.canRedo()) {
      KnittingPattern newPattern = widget.undoRedoManager.redo()!;

      Map<String, FleatherController> newControllers = {};
      Map<String, GlobalKey> newEditorKeys = {};
      
      // A textEditorField got deleted
      for (PatternTextEditorField field in stateKnittingPattern.textEditorFields.
        where((f) => !newPattern.fields.any((oldf) => oldf.id == f.id))) {
        FleatherController? ctrller = fleatherControllers[field.id];
        ctrller?.dispose();
      }
      for (PatternTextEditorField field in newPattern.textEditorFields) {
        if (!stateKnittingPattern.fields.any((oldf) => oldf.id == field.id)) {
          // A textEditorField got added
          ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode(field.docContents));
          newControllers[field.id] = FleatherController(document: document);
          final GlobalKey<EditorState> editorKey = GlobalKey();
          newEditorKeys[field.id] = editorKey;
        } else {
          // A textEditorField remained
          fleatherControllers[field.id]!.dispose();
          ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode(field.docContents));
          newControllers[field.id] = FleatherController(document: document);
          newEditorKeys[field.id] = fleaterEditorKeys[field.id]!;
        }
      }

      _storeAndSetKnittingPattern(newPattern, storeForUndo: false, additionalState: () {
        fleatherControllers = newControllers;
        fleaterEditorKeys = newEditorKeys;
        if (selectedField != null) {
          if (!newPattern.fields.any((f) => f.id == selectedField!.id)) {
            selectedField = null;    
          } else {
            selectedField = newPattern.fields.firstWhere((f) => f.id == selectedField!.id);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).autofocus(_keyboardFocusNode);

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (value) {
        if (value is KeyDownEvent && value.logicalKey == LogicalKeyboardKey.keyZ && 
          (HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed)) {
          if (HardwareKeyboard.instance.isShiftPressed) {
            _redo();
          } else {
            _undo();
          }
        }

        // left arrow key
        if (selectedField != null && selectedField!.fieldType != PatternFieldType.texteditor && 
          selectedField!.positionX > 0 && (value is KeyDownEvent || value is KeyRepeatEvent) && 
          value.logicalKey == LogicalKeyboardKey.arrowLeft) {
          PatternField newField = selectedField!.abstractCopyWith(
            positionX: max(selectedField!.positionX - (HardwareKeyboard.instance.isShiftPressed ? 10 : 1), 0)
          );
          _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
            fields: stateKnittingPattern.fields.map((f) => f.id != selectedField!.id ? f : newField).toList()
          ), additionalState: () => selectedField = newField,);
        }

        // up arrow key
        if (selectedField != null  && selectedField!.fieldType != PatternFieldType.texteditor && 
          selectedField!.positionY > 0 && (value is KeyDownEvent || value is KeyRepeatEvent) && 
          value.logicalKey == LogicalKeyboardKey.arrowUp) {
          PatternField newField = selectedField!.abstractCopyWith(
            positionY: max(selectedField!.positionY - (HardwareKeyboard.instance.isShiftPressed ? 10 : 1), 0)
          );
          _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
            fields: stateKnittingPattern.fields.map((f) => f.id != selectedField!.id ? f : newField).toList()
          ), additionalState: () => selectedField = newField,);
        }

        // right arrow key
        if (selectedField != null  && selectedField!.fieldType != PatternFieldType.texteditor && 
          (selectedField!.positionX + selectedField!.width) < stateKnittingPattern.pageLayout.pagewidth && 
          (value is KeyDownEvent || value is KeyRepeatEvent) && value.logicalKey == LogicalKeyboardKey.arrowRight) {
          PatternField newField = selectedField!.abstractCopyWith(
            positionX: min(selectedField!.positionX + (HardwareKeyboard.instance.isShiftPressed ? 10 : 1), stateKnittingPattern.pageLayout.pagewidth - selectedField!.width)
          );
          _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
            fields: stateKnittingPattern.fields.map((f) => f.id != selectedField!.id ? f : newField).toList()
          ), additionalState: () => selectedField = newField,);
        }

        // Down arrow key
        if (selectedField != null  && selectedField!.fieldType != PatternFieldType.texteditor && 
          (selectedField!.positionY + selectedField!.height) < (stateKnittingPattern.pageLayout.pageheight * stateKnittingPattern.pageLayout.numberOfPages) && 
          (value is KeyDownEvent || value is KeyRepeatEvent) && value.logicalKey == LogicalKeyboardKey.arrowDown) {
          PatternField newField = selectedField!.abstractCopyWith(
            positionY: min(
              selectedField!.positionY + (HardwareKeyboard.instance.isShiftPressed ? 10 : 1), 
              (stateKnittingPattern.pageLayout.pageheight * stateKnittingPattern.pageLayout.numberOfPages) - selectedField!.height
            )
          );
          _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
            fields: stateKnittingPattern.fields.map((f) => f.id != selectedField!.id ? f : newField).toList()
          ), additionalState: () => selectedField = newField,);
        }

        final bool shiftDown = HardwareKeyboard.instance.isShiftPressed;
        final bool setShift = (shiftDown != keyboardShiftDown);
        final bool controlDown = HardwareKeyboard.instance.isControlPressed;
        final bool setControl = controlDown != keyboardControlDown;
        
        if (setShift || setControl) {
          setState(() {
            keyboardShiftDown = shiftDown;
            keyboardControlDown = controlDown;
          });
        }
      },
      child: Shortcuts(
        shortcuts: {
          // TODO: these activators won't work properly on webbrowser on windows
          SingleActivator(LogicalKeyboardKey.keyC, control: AppPlatformExt.isWindows, meta: AppPlatformExt.isMacOS || AppPlatformExt.isWeb,): const CopyIntent(),
          SingleActivator(LogicalKeyboardKey.keyV, control: AppPlatformExt.isWindows, meta: AppPlatformExt.isMacOS || AppPlatformExt.isWeb,): const PasteIntent(),
          SingleActivator(LogicalKeyboardKey.keyX, control: AppPlatformExt.isWindows, meta: AppPlatformExt.isMacOS || AppPlatformExt.isWeb,): const CutIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            CopyIntent: CallbackAction<CopyIntent>(
              onInvoke: (intent) async {
                if (selectedField?.fieldType != PatternFieldType.texteditor) return;

                FleatherController controller = fleatherControllers[selectedField!.id]!;
                TextEditingValue textEditingValue = controller.plainTextEditingValue;
                TextSelection selection = controller.selection;
                if (selection.isCollapsed) {
                  setState(() => clipboardData = null);
                } else {
                  // Put the plain text on the system keyboard
                  await Clipboard.setData(ClipboardData(text: selection.textInside(textEditingValue.text)));

                  setState(() => clipboardData = FleatherClipboardData(
                    plainText: selection.textInside(textEditingValue.text),
                    delta: controller.document.toDelta().slice(
                        min(selection.baseOffset, selection.extentOffset),
                        max(selection.baseOffset, selection.extentOffset)),
                  ));
                }
                return null;
              },
            ),
            PasteIntent: CallbackAction<PasteIntent>(
              onInvoke: (intent) async {
                if (selectedField?.fieldType != PatternFieldType.texteditor) return;

                FleatherController controller = fleatherControllers[selectedField!.id]!;
                TextSelection selection = controller.selection;

                if (!selection.isValid) return;

                if (clipboardData == null || clipboardData!.isEmpty) {
                  // Check if there is text on the system clipboard
                  if (await Clipboard.hasStrings()) {
                    ClipboardData? data = await Clipboard.getData('text/plain');
                    if (data != null && data.text != null && data.text!.isNotEmpty) {
                      Delta pasteDelta = Delta();
                      pasteDelta.retain(selection.baseOffset);
                      pasteDelta.delete(selection.extentOffset - selection.baseOffset);
                      pasteDelta.insert(data.text!);
                      controller.compose(pasteDelta,
                          source: ChangeSource.local, forceUpdateSelection: true);
                    }
                  }
                  return null;
                }

                Delta pasteDelta = Delta();
                pasteDelta.retain(selection.baseOffset);
                pasteDelta.delete(selection.extentOffset - selection.baseOffset);

                if (clipboardData!.hasDelta) {
                  pasteDelta = pasteDelta.concat(clipboardData!.delta!);
                } else {
                  pasteDelta.insert(clipboardData!.plainText!);
                }

                controller.compose(pasteDelta,
                    source: ChangeSource.local, forceUpdateSelection: true);
              
                return null;
              },
            ),
            CutIntent: CallbackAction<CutIntent>(
              onInvoke: (intent) async {
                if (selectedField?.fieldType != PatternFieldType.texteditor) return;

                FleatherController controller = fleatherControllers[selectedField!.id]!;
                TextEditingValue textEditingValue = controller.plainTextEditingValue;
                TextSelection selection = controller.selection;

                // Put the plain text on the system keyboard
                await Clipboard.setData(ClipboardData(text: selection.textInside(textEditingValue.text)));

                setState(() => clipboardData = FleatherClipboardData(
                  plainText: selection.textInside(textEditingValue.text),
                  delta: controller.document.toDelta().slice(
                      min(selection.baseOffset, selection.extentOffset),
                      max(selection.baseOffset, selection.extentOffset)),
                ));

                controller.replaceText(
                  min(selection.baseOffset, selection.extentOffset), 
                  (selection.extentOffset - selection.baseOffset).abs(), 
                  ''
                );
                controller.updateSelection(TextSelection.collapsed(offset: min(selection.baseOffset, selection.extentOffset)));

                return null;
              },
            ),
          },
          child: Column(
            children: [
              PatternToolbar(
                selectedField: selectedField, 
                keyboardShiftDown: keyboardShiftDown, 
                keyboardControlDown: keyboardControlDown, 
                fieldIsAtBottom: stateKnittingPattern.fields.isNotEmpty && selectedField == stateKnittingPattern.fields.first,
                fieldIsAtTop: stateKnittingPattern.fields.isNotEmpty && selectedField == stateKnittingPattern.fields.last,
                showContentControls: showContentControls,
                patternHasMultipleFields: stateKnittingPattern.fields.length > 1, 
                onToggleShowContentControls: () => setState(() => showContentControls = !showContentControls),
                onAddField: (type) => _addNewField(type), 
                onCycleSelectedField: _cycleSelectedField, 
                onChanged: (newField, {storeForUndo}) => _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                  fields: stateKnittingPattern.fields.map((f) => f.id == newField.id ? newField : f).toList()
                ), storeForUndo: storeForUndo, additionalState: () {
                  if (selectedField?.id == newField.id) {
                    selectedField = newField;
                  }
                },), 
                onMoveBack: (allTheWay) => _moveSelectedFieldBackward(allTheWay), 
                onMoveForward: (allTheWay) => _moveSelectedFieldForward(allTheWay), 
                onDuplicateSelectedField: _duplicateSelectedField,
                fieldToolbar:
                  selectedField?.fieldType == PatternFieldType.drawing ?
                    PatternDrawingFieldToolbar(
                      pattern: stateKnittingPattern,
                      field: selectedField as PatternDrawingField, 
                      onChanged: (newField) => _storeAndSetKnittingPattern(
                        stateKnittingPattern.copyWith(
                          fields: stateKnittingPattern.fields.map((f) => f.id != newField.id ? f : newField).toList()
                        ), additionalState: () => selectedField = newField,
                      )
                    ) :
                  selectedField?.fieldType == PatternFieldType.image ?
                    PatternImageFieldToolbar(
                      field: selectedField as PatternImageField, 
                      onChanged: (newField) => _storeAndSetKnittingPattern(
                        stateKnittingPattern.copyWith(
                          fields: stateKnittingPattern.fields.map((f) => f.id != newField.id ? f : newField).toList()
                        ), additionalState: () => selectedField = newField,
                      )
                    ) :
                  selectedField?.fieldType == PatternFieldType.knittingchart ?
                    PatternChartFieldToolbar(
                      field: selectedField as PatternChartField, 
                      onChanged: (newField) => _storeAndSetKnittingPattern(
                        stateKnittingPattern.copyWith(
                          fields: stateKnittingPattern.fields.map((f) => f.id != newField.id ? f : newField).toList()
                        ), additionalState: () => selectedField = newField,
                      )
                    ) :
                  selectedField?.fieldType == PatternFieldType.panel ?
                    PatternPanelFieldToolbar(
                      pattern: stateKnittingPattern,
                      field: selectedField as PatternPanelField, 
                      onChanged: (newField) => _storeAndSetKnittingPattern(
                        stateKnittingPattern.copyWith(
                          fields: stateKnittingPattern.fields.map((f) => f.id != newField.id ? f : newField).toList()
                        ), additionalState: () => selectedField = newField,
                      )
                    ) :
                  selectedField?.fieldType == PatternFieldType.texteditor ?
                    PatternTextEditorFieldToolbar(
                      fleatherController: fleatherControllers[selectedField!.id]!,
                      pattern: stateKnittingPattern,
                      editorKey: fleaterEditorKeys[selectedField!.id]!,
                      onTextStyleSettingsButtonClicked: () async {
                        TextEditorFieldSettings? newSettings = await showDialog(
                          context: context, 
                          barrierDismissible: false,
                          builder: (context) => TextEditorFieldSettingsDialog(settings: (selectedField as PatternTextEditorField).settings)
                        );
                        if (newSettings != null) {
                          PatternTextEditorField newField = (selectedField as PatternTextEditorField).copyWith(
                            settings: newSettings
                          );
                          _storeAndSetKnittingPattern(
                            stateKnittingPattern.copyWith(
                              fields: stateKnittingPattern.fields.map((f) => f.id != selectedField!.id ? f : newField).toList()
                            ), additionalState: () => selectedField = newField
                          );
                        }
                      },
                    ) :
                  null,

              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: _verticalScrollController,
                          child: Container(
                            color: Colors.grey,
                            child: Center(
                              child: SizedBox(
                                width: stateKnittingPattern.pageLayout.pagewidth,
                                height: stateKnittingPattern.pageLayout.pageheight * stateKnittingPattern.pageLayout.numberOfPages,
                                child: Container(
                                  color: Colors.white,
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () => setState(() => selectedField = null),
                                        child: CustomPaint(
                                          size: Size(
                                            stateKnittingPattern.pageLayout.pagewidth, 
                                            stateKnittingPattern.pageLayout.pageheight * stateKnittingPattern.pageLayout.numberOfPages),
                                          painter: PageMarginPainter(
                                            pageLayout: stateKnittingPattern.pageLayout,
                                          ),
                                        ),
                                      ),
                                      for (PatternField field in stateKnittingPattern.fields)
                                        PatternFieldControl(
                                          knittingPattern: stateKnittingPattern, 
                                          field: field, 
                                          fieldChangeNotifier: fleatherControllers[field.id],
                                          editorKey: (field is PatternTextEditorField) ? fleaterEditorKeys[field.id] : null,
                                          selected: field.id == selectedField?.id, 
                                          onSelect: () => setState(() => selectedField = field),
                                          onDelete: _deleteField,
                                          onChanged: (newField) => _storeAndSetKnittingPattern(
                                            stateKnittingPattern.copyWith(
                                              fields: stateKnittingPattern.fields.map((f) => f.id == newField.id ? newField : f).toList()
                                            ), additionalState: () {
                                              if (selectedField?.id == newField.id) {
                                                selectedField = newField;
                                              }
                                            },
                                          ),
                                          onReflow: () => _reflowField(field.id),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ),
                    ),
                    if (showContentControls && selectedField != null && selectedField!.hasContent)
                      Positioned(
                        right: 15,
                        child: SizedBox(
                          width: 240,
                          height: 260,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              border: Border(
                                bottom: BorderSide(color: Colors.grey),
                                left: BorderSide(color: Colors.grey),
                                right:  BorderSide(color: Colors.grey),
                              ),
                              color: Color.fromARGB(255, 247, 249, 254)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const SmallLabel(label: 'Offset'),
                                      hspacing,
                                      NudgeControl(
                                        initialOffset: Offset(selectedField!.contentOffsetX, selectedField!.contentOffsetY), 
                                        size: 60,
                                        onNudged: (newOffset) {
                                          PatternField newField = selectedField!.abstractCopyWith(
                                            contentOffsetX: newOffset.dx,
                                            contentOffsetY: newOffset.dy
                                          );
                                          _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                                            fields: stateKnittingPattern.fields.map((f) => f.id == selectedField?.id ? newField : f).toList()
                                          ), additionalState: () => selectedField = newField,);
                                        } 
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const SmallLabel(label: 'Opacity'),
                                      hspacing,
                                      Column(
                                        children: [
                                          Text('${((selectedField!.opacity / 255) * 100).toInt()}%', style: const TextStyle(fontSize: 10),),
                                          Material(
                                            child: FittedScale(
                                              scale: .8,
                                              child: Slider(
                                                min: 0,
                                                max: 255,
                                                value: selectedField!.opacity as double, 
                                                onChanged: (value) {
                                                  PatternField newField = selectedField!.abstractCopyWith(opacity: value.toInt());
                                                  _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                                                    fields: stateKnittingPattern.fields.map((f) => f.id == selectedField?.id ? newField : f).toList()
                                                  ), additionalState: () => selectedField = newField, storeForUndo: false);
                                                },
                                                onChangeEnd: (value) {
                                                  PatternField newField = selectedField!.abstractCopyWith(opacity: value.toInt());
                                                  _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                                                    fields: stateKnittingPattern.fields.map((f) => f.id == selectedField?.id ? newField : f).toList()
                                                  ), additionalState: () => selectedField = newField);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  vspacing,
                                  Row(
                                    children: [
                                      const SmallLabel(label: 'Rotation',),
                                      hspacing,
                                      SizedBox(
                                        width: 150,
                                        child: SpinBox(
                                          value: selectedField!.rotation,
                                          min: -360,
                                          max: 360,
                                          decimals: 1,
                                          step: .1,
                                          onChanged: (value) {
                                            PatternField newField = selectedField!.abstractCopyWith(rotation: value);
                                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                                              fields: stateKnittingPattern.fields.map((f) => f.id == selectedField?.id ? newField : f).toList()
                                            ), additionalState: () => selectedField = newField);
                                          },
                                        )
                                      )
                                    ],
                                  ),
                                  vspacing,
                                  Row(
                                    children: [
                                      const SmallLabel(label: 'Flip'),
                                      hspacing,
                                      Container(
                                        decoration: BoxDecoration(
                                          color: selectedField!.flipX ? Colors.blue.withAlpha(60) : null,
                                          shape: BoxShape.circle
                                        ),
                                        child: IconButton(
                                          isSelected: selectedField!.flipX,
                                          onPressed: () {
                                            PatternField newField = selectedField!.abstractCopyWith(flipX: !selectedField!.flipX);
                                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                                              fields: stateKnittingPattern.fields.map((f) => f.id == selectedField?.id ? newField : f).toList()
                                            ), additionalState: () => selectedField = newField);
                                          }, 
                                          icon: const Icon(Icons.flip),
                                        ),
                                      ),
                                      hspacing,
                                      Container(
                                        decoration: BoxDecoration(
                                          color: selectedField!.flipY ? Colors.blue.withAlpha(60) : null,
                                          shape: BoxShape.circle
                                        ),
                                        child: Transform.rotate(
                                          angle: MathUtitilies.toRadians(90),
                                          child: IconButton(
                                            isSelected: selectedField!.flipY,
                                            onPressed: () {
                                              PatternField newField = selectedField!.abstractCopyWith(flipY: !selectedField!.flipY);
                                              _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                                                fields: stateKnittingPattern.fields.map((f) => f.id == selectedField?.id ? newField : f).toList()
                                              ), additionalState: () => selectedField = newField);
                                            }, 
                                            icon: const Icon(Icons.flip),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ),
                  ],
                )
              )
            ],
          )
        )
        
      )
    );
  }
}

class CopyIntent extends Intent {
  const CopyIntent();
}

class PasteIntent extends Intent {
  const PasteIntent();
}

class CutIntent extends Intent {
  const CutIntent();
}
