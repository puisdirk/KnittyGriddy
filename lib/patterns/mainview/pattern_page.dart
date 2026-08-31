import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_field_control.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_chart_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_drawing_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_image_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_panel_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_text_editor_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fleather/text_editor_field_settings_dialog.dart';
import 'package:knitty_griddy/patterns/mainview/pattern_settings_dialog.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/fields/text_editor_field_settings.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/pattern_page_layout.dart';
import 'package:knitty_griddy/patterns/model/patterns_model.dart';
import 'package:knitty_griddy/common/undo_redo_toolbar.dart';
import 'package:knitty_griddy/utils/app_platform_ext.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/dashed_painter.dart';
import 'package:knitty_griddy/utils/undo_redo_manager.dart';
import 'package:provider/provider.dart';

class PatternPage extends StatefulWidget {
  final KnittingPattern knittingPattern;

  const PatternPage({
    required this.knittingPattern,
    super.key
  });

  @override
  State<PatternPage> createState() => _PatternPageState();
}

class _PatternPageState extends State<PatternPage> {
  late FocusNode _keyboardFocusNode;
  bool keyboardShiftDown = false;
  bool keyboardControlDown = false;
  PatternField? selectedField;
  late KnittingPattern stateKnittingPattern;
  late Map<String, FleatherController> fleatherControllers;
  late Map<String, GlobalKey> fleaterEditorKeys;
  late bool viewMode;
  late FleatherClipboardData? clipboardData;

  late ScrollController _verticalScrollController;

  final UndoRedoManager<KnittingPattern> _undoRedoManager = UndoRedoManager();

  @override
  void initState() {
    _keyboardFocusNode = FocusNode();

    stateKnittingPattern = widget.knittingPattern;
    _undoRedoManager.store(stateKnittingPattern);

    viewMode = widget.knittingPattern.fields.length > 2;

    _verticalScrollController = ScrollController();

    clipboardData = null;

    fleatherControllers = {};
    fleaterEditorKeys = {};
    for (PatternTextEditorField field in widget.knittingPattern.fields.whereType<PatternTextEditorField>()) {
      ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode(field.docContents));
      fleatherControllers[field.id] = FleatherController(document: document);
      final GlobalKey<EditorState> editorKey = GlobalKey();
      fleaterEditorKeys[field.id] = editorKey;
    }

    super.initState();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    for (FleatherController controller in fleatherControllers.values) {
      controller.dispose();
    }
    
    super.dispose();
  }

  void _undo() {
    if (_undoRedoManager.canUndo()) {
      KnittingPattern newPattern = _undoRedoManager.undo()!;

      Map<String, FleatherController> newControllers = {};
      Map<String, GlobalKey> newEditorKeys = {};
      
      // A textEditorField got deleted
      for (PatternTextEditorField field in stateKnittingPattern.fields.whereType<PatternTextEditorField>().
        where((f) => !newPattern.fields.any((oldf) => oldf.id == f.id))) {
        FleatherController? ctrller = fleatherControllers[field.id];
        ctrller?.dispose();
      }
      for (PatternTextEditorField field in newPattern.fields.whereType<PatternTextEditorField>()) {
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

      _setKnittingPattern(newPattern, additionalState: () {
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
    if (_undoRedoManager.canRedo()) {
      KnittingPattern newPattern = _undoRedoManager.redo()!;

      Map<String, FleatherController> newControllers = {};
      Map<String, GlobalKey> newEditorKeys = {};
      
      // A textEditorField got deleted
      for (PatternTextEditorField field in stateKnittingPattern.fields.whereType<PatternTextEditorField>().
        where((f) => !newPattern.fields.any((oldf) => oldf.id == f.id))) {
        FleatherController? ctrller = fleatherControllers[field.id];
        ctrller?.dispose();
      }
      for (PatternTextEditorField field in newPattern.fields.whereType<PatternTextEditorField>()) {
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

      _setKnittingPattern(newPattern, additionalState: () {
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

  void _storeAndSetKnittingPattern(KnittingPattern newPattern, {void Function()? additionalState, bool? storeForUndo}) {
    if (storeForUndo != false) {
      print('storeforundo');
      _undoRedoManager.store(newPattern);
    }
    _setKnittingPattern(newPattern, additionalState: additionalState);
  }

  void _setKnittingPattern(KnittingPattern newPattern, {void Function()? additionalState}) {
    Provider.of<PatternsModel>(context, listen: false).updateKnittingPattern(
      oldPattern: stateKnittingPattern, 
      newPattern: newPattern
    );
    setState(() {
      stateKnittingPattern = newPattern;
      if (additionalState != null) additionalState();
    });
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

  void _onCycleSelectedField(PatternFieldType type, bool reversed) {
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

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).autofocus(_keyboardFocusNode);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Provider.of<PatternsModel>(context, listen: false).saveCurrentPattern(clear: true);
            _undoRedoManager.clear();
            Navigator.maybePop(context);
          },
        ),
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.auto_awesome_mosaic_outlined), hspacing, Text('Pattern - ${stateKnittingPattern.name}')]),
        backgroundColor: Colors.grey.shade300,
        bottom: PreferredSize(
          preferredSize: const Size(2000, 40), 
          child: UndoRedoToolbar(
            canUndo: _undoRedoManager.canUndo(),
            canRedo: _undoRedoManager.canRedo(),
            undo: _undo,
            redo: _redo,
          ),
        ),
        actions: [
          Visibility(
            visible: !viewMode,
            child: Tooltip(
              message: 'Pattern settings',
              child: IconButton(
                onPressed: () async {
                  KnittingPattern? newPattern = await showDialog(
                    barrierDismissible: false,
                    context: context, 
                    builder: (context) => PatternSettingsDialog(pattern: stateKnittingPattern),
                  );
            
                  if (newPattern != null) {
                    List<PatternField> newFields = [];
                    if (newPattern.pageLayout == stateKnittingPattern.pageLayout) {
                      newFields.addAll(stateKnittingPattern.fields);
                    } else {
                      // Go through all the fields and move/resize them until they fit on the new size
                      Rect newPatternRect = Rect.fromLTWH(0, 0, newPattern.pageLayout.dimensions.width, newPattern.pageLayout.dimensions.height);
                      for (PatternField field in stateKnittingPattern.fields) {
                        PatternField newField = field;
                        if (newField.positionY + newField.height > newPatternRect.height) {
                          newField = newField.abstractCopyWith(positionY: newPatternRect.height - newField.height);
                          if (newField.positionY < 0) {
                            // The pattern dimensions are not high enough to accomodate the field, so we need to resize it
                            double newHeight = newPatternRect.height;
                            double newWidth = newField.width;
                            if (newField.fixedAspectRatio) {
                              newWidth *= newField.height / newField.width;
                            }
                            newField = newField.abstractCopyWith(positionY: 0, height: newHeight, width: newWidth);
                          }
                        }
            
                        if (newField.positionX + newField.width > newPatternRect.width) {
                          newField = newField.abstractCopyWith(positionX: newPatternRect.width - newField.width);
                          if (newField.positionX < 0) {
                            // The pattern dimensions are not wide enough to accomodate the field, so we need to resize it
                            double newHeight = newField.height;
                            double newWidth = newPatternRect.width;
                            if (newField.fixedAspectRatio) {
                              newHeight *= newField.height / newField.width;
                            }
                            newField = newField.abstractCopyWith(positionX: 0, height: newHeight, width: newWidth);
                          }
                        }
            
                        newFields.add(newField);
                      }
            
                    }
            
                    _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                      name: newPattern.name,
                      description: newPattern.description,
                      fields: newFields,
                      pageLayout: newPattern.pageLayout,
                    ));
                  }
                }, 
                icon: const Icon(Icons.settings),
              ),
            ),
          ),
          hspacing,
          Tooltip(
            message: viewMode? 'Switch to Edit mode' : 'Switch to View mode',
            child: IconButton(
              onPressed: () => setState(() => viewMode = !viewMode), 
              icon: Icon(viewMode? Icons.edit : Icons.visibility)
            ),
          ),
          hspacing,
          Tooltip(
            message: 'Export',
            child: IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () async => {
                await Provider.of<PatternsModel>(context, listen: false).exportPattern()
              }/* Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ExportPage())
              )*/,
            ),
          ),
          hspacing,
        ],
      ),
      body: KeyboardListener(
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
              positionX: math.max(selectedField!.positionX - (HardwareKeyboard.instance.isShiftPressed ? 10 : 1), 0)
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
              positionY: math.max(selectedField!.positionY - (HardwareKeyboard.instance.isShiftPressed ? 10 : 1), 0)
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
              positionX: math.min(selectedField!.positionX + (HardwareKeyboard.instance.isShiftPressed ? 10 : 1), stateKnittingPattern.pageLayout.pagewidth - selectedField!.width)
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
              positionY: math.min(
                selectedField!.positionY + (HardwareKeyboard.instance.isShiftPressed ? 10 : 1), 
                (stateKnittingPattern.pageLayout.pageheight * stateKnittingPattern.pageLayout.numberOfPages) - selectedField!.height)
            );
            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
              fields: stateKnittingPattern.fields.map((f) => f.id != selectedField!.id ? f : newField).toList()
            ), additionalState: () => selectedField = newField);
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
        child:
          Shortcuts(
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
                    if (selectedField is! PatternTextEditorField) return;

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
                            math.min(selection.baseOffset, selection.extentOffset),
                            math.max(selection.baseOffset, selection.extentOffset)),
                      ));
                    }
                    return null;
                  },
                ),
                PasteIntent: CallbackAction<PasteIntent>(
                  onInvoke: (intent) async {
                    if (selectedField is! PatternTextEditorField) return;

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
                    if (selectedField is! PatternTextEditorField) return;

                    FleatherController controller = fleatherControllers[selectedField!.id]!;
                    TextEditingValue textEditingValue = controller.plainTextEditingValue;
                    TextSelection selection = controller.selection;

                    // Put the plain text on the system keyboard
                    await Clipboard.setData(ClipboardData(text: selection.textInside(textEditingValue.text)));

                    setState(() => clipboardData = FleatherClipboardData(
                      plainText: selection.textInside(textEditingValue.text),
                      delta: controller.document.toDelta().slice(
                          math.min(selection.baseOffset, selection.extentOffset),
                          math.max(selection.baseOffset, selection.extentOffset)),
                    ));

                    controller.replaceText(
                      math.min(selection.baseOffset, selection.extentOffset), 
                      (selection.extentOffset - selection.baseOffset).abs(), 
                      ''
                    );
                    controller.updateSelection(TextSelection.collapsed(offset: math.min(selection.baseOffset, selection.extentOffset)));

                    return null;
                  },
                ),
              },
              child: Column(
                children: [
                  if (viewMode)
                    SizedBox(
                      height: 50,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey))
                        ),
                      ),
                    ),
                  Visibility(
                    visible: !viewMode,
                    child: PatternToolbar(
                      selectedField: selectedField,
                      fieldIsAtBottom: stateKnittingPattern.fields.isNotEmpty && selectedField == stateKnittingPattern.fields.first,
                      fieldIsAtTop: stateKnittingPattern.fields.isNotEmpty && selectedField == stateKnittingPattern.fields.last,
                      keyboardShiftDown: keyboardShiftDown,
                      keyboardControlDown: keyboardControlDown,
                      onCycleSelectedField: _onCycleSelectedField,
                      onDuplicateSelectedField: () {
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

                        PatternField newField = selectedField!.abstractCopyWith(
                          id: id,
                          positionX: posX,
                          positionY: posY,
                        );

                        switch (newField.fieldType) {
                          case PatternFieldType.texteditor:
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, newField]
                            ), additionalState: () {
                              ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode((newField as PatternTextEditorField).docContents));
                              FleatherController controller = FleatherController(document: document);
                              fleatherControllers = Map.from(fleatherControllers)..addAll({id: controller});
                              final GlobalKey<EditorState> editorKey = GlobalKey();
                              fleaterEditorKeys = Map.from(fleaterEditorKeys)..addAll({id: editorKey});
                              selectedField = newField;
                            });
                          break;
                          case PatternFieldType.knittingchart:
                          case PatternFieldType.drawing:
                          case PatternFieldType.image:
                          case PatternFieldType.panel:
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, newField]
                            ), additionalState: () {
                              selectedField = newField;
                            });
                          break;
                        }
                      },
                      patternHasMultipleFields: stateKnittingPattern.fields.length > 1,
                      //onChanged: (newField) {
                      onChanged: (newField, {storeForUndo}) {
                        _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                          fields: stateKnittingPattern.fields.map((f) => f.id == newField.id ? newField : f).toList()
                        ), additionalState: () => selectedField = newField, storeForUndo: storeForUndo);
                      },
                      onMoveBack: _moveSelectedFieldBackward,
                      onMoveForward: _moveSelectedFieldForward,
                      onAddField: (type) {
                        double posY = _verticalScrollController.offset;
                        double posX = PatternPageLayout.margin;
                        // If we didn't scroll, place the new field inside the margins
                        if (posY == 0) {
                          posY = PatternPageLayout.margin;
                        }
                        PatternField newField = _createNewField(type, posX, posY);
                        String id = newField.id;
                        switch (newField.fieldType) {
                          case PatternFieldType.texteditor:
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, newField]
                            ), additionalState: () {
                              ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode((newField as PatternTextEditorField).docContents));
                              FleatherController controller = FleatherController(document: document);
                              fleatherControllers = Map.from(fleatherControllers)..addAll({id: controller});
                              final GlobalKey<EditorState> editorKey = GlobalKey();
                              fleaterEditorKeys = Map.from(fleaterEditorKeys)..addAll({id: editorKey});
                              selectedField = newField;
                            });
                          break;
                          case PatternFieldType.knittingchart:
                          case PatternFieldType.drawing:
                          case PatternFieldType.image:
                          case PatternFieldType.panel:
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, newField]
                            ), additionalState: () {
                              selectedField = newField;
                            });
                          break;
                        }
                      },
                      fieldToolbar: 
                        selectedField?.fieldType == PatternFieldType.drawing ?
                          PatternDrawingFieldToolbar(
                            pattern: widget.knittingPattern,
                            field: selectedField as PatternDrawingField, 
                            onChanged: (newField) => _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: stateKnittingPattern.fields.map((f) => f.id != newField.id ? f : newField).toList()
                            ), additionalState: () => selectedField = newField,),
                          ) :
                        selectedField?.fieldType == PatternFieldType.image ?
                        PatternImageFieldToolbar(
                          field: selectedField as PatternImageField, 
                          onChanged: (newField) => _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                            fields: stateKnittingPattern.fields.map((f) => f.id != newField.id ? f : newField).toList()
                          ), additionalState: () => selectedField = newField,), 
                        ) :
                        selectedField?.fieldType == PatternFieldType.knittingchart ?
                        PatternChartFieldToolbar(
                          field: selectedField as PatternChartField, 
                          onChanged: (newField) => _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                            fields: stateKnittingPattern.fields.map((f) => f.id != newField.id ? f : newField).toList()
                          ), additionalState: () => selectedField = newField,)
                        ) :
                        selectedField?.fieldType == PatternFieldType.panel ?
                        PatternPanelFieldToolbar(
                          pattern: stateKnittingPattern,
                          field: selectedField as PatternPanelField, 
                          onChanged: (newField) => _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                            fields: stateKnittingPattern.fields.map((f) => f.id != newField.id ? f : newField).toList()
                          ), additionalState: () => selectedField = newField,), 
                        ) :
                        selectedField?.fieldType == PatternFieldType.texteditor ?
                        PatternTextEditorFieldToolbar(
                          fleatherController: fleatherControllers[selectedField!.id]!,
                          pattern: stateKnittingPattern,
                          editorKey: fleaterEditorKeys[selectedField!.id]!,
                          onTextStyleSettingsButtonClicked: () async {
                            TextEditorFieldSettings? newSettings = await showDialog(
                              context: context, 
                              builder: (context) => TextEditorFieldSettingsDialog(settings: (selectedField as PatternTextEditorField).settings)
                            );
                            if (newSettings != null) {
                              PatternTextEditorField newField = (selectedField as PatternTextEditorField).copyWith(
                                settings: newSettings
                              );
                              _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                                fields: stateKnittingPattern.fields.map((f) => f.id != selectedField!.id ? f : newField).toList()
                              ), additionalState: (() => selectedField = newField));
                            }
                          },
                        ) :
                        null,
                    ),
                  ),
                  Expanded(
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
                                        viewMode: viewMode
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
                                      viewMode: viewMode,
                                      onSelect: () => setState(() => selectedField = field), 
                                      onDelete: () {
                                        if (selectedField != null) {
                                          String fieldId = selectedField!.id;
                                          _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                                            fields: stateKnittingPattern.fields.where((f) => f.id != fieldId).toList()
                                          ), additionalState: () {
                                            if (selectedField is PatternTextEditorField) {
                                              FleatherController? ctrl = fleatherControllers[fieldId];
                                              if (ctrl != null) {
                                                ctrl.dispose();
                                                fleatherControllers = Map.from(fleatherControllers)..remove(fieldId);
                                              }
                                              fleaterEditorKeys = Map.from(fleaterEditorKeys)..remove(fieldId);
                                            }
                                            selectedField = null;
                                          });
                                        }
                                      }, 
                                      onChanged: (changedField) => _storeAndSetKnittingPattern(
                                        stateKnittingPattern.copyWith(
                                          fields: stateKnittingPattern.fields.map((f) => f.id != changedField.id ? f : changedField).toList()
                                        ), additionalState: () => selectedField = changedField
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}

class PageMarginPainter extends CustomPainter {
  final PatternPageLayout pageLayout;
  final bool viewMode;

  const PageMarginPainter({
    required this.pageLayout,
    required this.viewMode,
  });

  @override
  void paint(Canvas canvas, Size size) {

    if (!viewMode) {
      Paint marginPaint = Paint()..color = Colors.blue..style = PaintingStyle.stroke;

      Path leftMargin = Path()
        ..moveTo(PatternPageLayout.margin, 0)
        ..lineTo(PatternPageLayout.margin, pageLayout.pageheight * pageLayout.numberOfPages);
      Path rightMargin = Path()
        ..moveTo(pageLayout.pagewidth - PatternPageLayout.margin, 0)
        ..lineTo(pageLayout.pagewidth - PatternPageLayout.margin, pageLayout.pageheight * pageLayout.numberOfPages);
      
      DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, leftMargin, marginPaint);
      DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, rightMargin, marginPaint);

      for (int page = 0; page < pageLayout.numberOfPages; page++) {
        Path topPath = Path()
          ..moveTo(0, (page * pageLayout.pageheight) + PatternPageLayout.margin)
          ..lineTo(pageLayout.pagewidth, (page * pageLayout.pageheight) + PatternPageLayout.margin);
        Path bottomPath = Path()
          ..moveTo(0, ((page + 1) * pageLayout.pageheight) - PatternPageLayout.margin)
          ..lineTo(pageLayout.pagewidth, ((page + 1) * pageLayout.pageheight) - PatternPageLayout.margin);

        DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, topPath, marginPaint);
        DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, bottomPath, marginPaint);
      }
    }

    // Draw page bottom if needed
    if (pageLayout.numberOfPages > 1) {
      Paint pageBottomPaint = Paint()..color = Colors.grey.shade400..style = PaintingStyle.stroke;
      for (int page = 1; page <= pageLayout.numberOfPages; page++) {
        Path pageBottom = Path()
          ..moveTo(0, page * pageLayout.pageheight)
          ..lineTo(pageLayout.pagewidth, page * pageLayout.pageheight);
        DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.dots.dashPattern).paint(canvas, pageBottom, pageBottomPaint);
      }
    }

    // Draw page numbers
    if (pageLayout.showPageNumber) {
      for (int page = 1; page <= pageLayout.numberOfPages; page++) {
        TextStyle style = TextStyle(color: Colors.grey.shade600);
        final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
          ParagraphStyle(
            fontSize: 10,
            fontFamily: style.fontFamily,
            fontStyle: style.fontStyle,
            fontWeight: style.fontWeight,
            textAlign: TextAlign.justify,
          ),
        )
        ..pushStyle(style.getTextStyle())
        ..addText('$page');

        final Paragraph paragraph = paragraphBuilder.build()
        ..layout(ParagraphConstraints(width: size.width));

        canvas.drawParagraph(paragraph, 
          Offset(
            pageLayout.pagewidth - PatternPageLayout.margin + 10, 
            (page * pageLayout.pageheight) - PatternPageLayout.margin + 10
          )
        );
      }
    }

    if (pageLayout.showGrid && !viewMode) {
      Paint gridPaint = Paint()..color = Colors.grey.withAlpha(150)..style = PaintingStyle.stroke;
      double oneCm = 10 * PatternPageLayout.pixelsPerMM;
      for (int page = 0; page < pageLayout.numberOfPages; page++) {
        // Vertical
        for (double xOffset = PatternPageLayout.margin + oneCm; xOffset < pageLayout.pagewidth - PatternPageLayout.margin; xOffset += oneCm) {
          Path gridLine = Path()..moveTo(xOffset, (page * pageLayout.pageheight) + PatternPageLayout.margin)..lineTo(xOffset, (page * pageLayout.pageheight) + pageLayout.pageheight - PatternPageLayout.margin);
          DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.dots.dashPattern).paint(canvas, gridLine, gridPaint);
        }
        // Horizontal
        for (double yOffset = (page * pageLayout.pageheight) + PatternPageLayout.margin + oneCm; yOffset < (page * pageLayout.pageheight) + pageLayout.pageheight - PatternPageLayout.margin; yOffset += oneCm) {
          Path gridLine = Path()..moveTo(PatternPageLayout.margin, yOffset)..lineTo(pageLayout.pagewidth - PatternPageLayout.margin, yOffset);
          DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.dots.dashPattern).paint(canvas, gridLine, gridPaint);
        }        
      }
    }
  }

  @override
  bool shouldRepaint(covariant PageMarginPainter oldDelegate) {
    return pageLayout != oldDelegate.pageLayout || viewMode != oldDelegate.viewMode;
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