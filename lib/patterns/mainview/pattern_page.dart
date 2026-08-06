import 'dart:convert';
import 'dart:math' as math;

import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/pattern_field_control.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_chart_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_drawing_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_image_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_panel_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_text_editor_field_toolbar.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/pattern_toolbar.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/patterns_model.dart';
import 'package:knitty_griddy/utils/app_platform_ext.dart';
import 'package:knitty_griddy/utils/constants.dart';
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
  PatternField? selectedField;
  late KnittingPattern stateKnittingPattern;
  late Map<String, FleatherController> fleatherControllers;
  late Map<String, GlobalKey> fleaterEditorKeys;
  late bool viewMode;
  late FleatherClipboardData? clipboardData;

  @override
  void initState() {
    _keyboardFocusNode = FocusNode();

    stateKnittingPattern = widget.knittingPattern;
    viewMode = widget.knittingPattern.fields.length > 2;

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

  void _storeAndSetKnittingPattern(KnittingPattern newPattern, {void Function()? additionalState}) {
    // undo/redo
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

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).autofocus(_keyboardFocusNode);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Provider.of<PatternsModel>(context, listen: false).saveCurrentPattern();
            Provider.of<PatternsModel>(context, listen: false).clearUndoRedo();
            Navigator.maybePop(context);
          },
        ),
        title: Text('Pattern - ${stateKnittingPattern.name}'),
        backgroundColor: Colors.grey.shade300,
/*        bottom: const PreferredSize(
          preferredSize: Size(20000, 200), 
          child: KnittingToolbar(),
        ),*/
        actions: [
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
/*        onKeyEvent: (value) {
          if (value is KeyDownEvent && value.logicalKey == LogicalKeyboardKey.keyC && 
            (HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed)) {
              print('Gotcha');
          }

          if (value is KeyDownEvent && value.logicalKey == LogicalKeyboardKey.keyZ && 
            (HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed)) {
            if (HardwareKeyboard.instance.isShiftPressed) {
              Provider.of<PatternsModel>(context, listen: false).redo();
            } else {
              Provider.of<PatternsModel>(context, listen: false).undo();
            }
          }

        },*/
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
                  onInvoke: (intent) {
                    if (selectedField is! PatternTextEditorField) return;

                    FleatherController controller = fleatherControllers[selectedField!.id]!;
                    TextEditingValue textEditingValue = controller.plainTextEditingValue;
                    TextSelection selection = controller.selection;
                    if (selection.isCollapsed) {
                      setState(() => clipboardData = null);
                    } else {
                      setState(() => clipboardData = FleatherClipboardData(
                        plainText: selection.textInside(textEditingValue.text),
                        delta: controller.document.toDelta().slice(
                            math.min(selection.baseOffset, selection.extentOffset),
                            math.max(selection.baseOffset, selection.extentOffset)),
                      ));
                    }
                  },
                ),
                PasteIntent: CallbackAction<PasteIntent>(
                  onInvoke: (intent) {
                    if (selectedField is! PatternTextEditorField) return;

                    FleatherController controller = fleatherControllers[selectedField!.id]!;
                    TextSelection selection = controller.selection;

                    if (!selection.isValid) return;

                    if (clipboardData == null || clipboardData!.isEmpty) {
                      return;
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
                  },
                ),
                CutIntent: CallbackAction<CutIntent>(
                  onInvoke: (intent) {
                    if (selectedField is! PatternTextEditorField) return;
                    if (clipboardData == null) return;

                    FleatherController controller = fleatherControllers[selectedField!.id]!;
                    TextEditingValue textEditingValue = controller.plainTextEditingValue;
                    TextSelection selection = controller.selection;
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
                      patternHasMultipleFields: stateKnittingPattern.fields.length > 1,
                      onChanged: (newField) {
                        _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                          fields: stateKnittingPattern.fields.map((f) => f.id == newField.id ? newField : f).toList()
                        ), additionalState: () => selectedField = newField,);
                      },
                      onMoveBack: () {
                        List<PatternField> newFields = List.from(stateKnittingPattern.fields);
                        int idx = newFields.indexWhere((f) => f.id == selectedField!.id);
                        if (idx > 0) {
                          PatternField temp = newFields.removeAt(idx);
                          newFields.insert(idx - 1, temp);
                          _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                            fields: newFields,
                          ));
                        }
                      },
                      onMoveForward: () {
                        List<PatternField> newFields = List.from(stateKnittingPattern.fields);
                        int idx = newFields.indexWhere((f) => f.id == selectedField!.id);
                        if (idx < newFields.length - 1) {
                          PatternField temp = newFields.removeAt(idx);
                          newFields.insert(idx + 1, temp);
                          _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                            fields: newFields,
                          ));
                        }
                      },
                      onAddField: (type) {
                        String id = const UuidV4Gen().get();
                        switch (type) {
                          case PatternFieldType.texteditor:
                            PatternTextEditorField field = PatternTextEditorField(id: id);
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, field]
                            ), additionalState: () {
                              ParchmentDocument document = ParchmentDocument.fromJson(jsonDecode(field.docContents));
                              FleatherController controller = FleatherController(document: document);
                              fleatherControllers = Map.from(fleatherControllers)..addAll({id: controller});
                              final GlobalKey<EditorState> editorKey = GlobalKey();
                              fleaterEditorKeys = Map.from(fleaterEditorKeys)..addAll({id: editorKey});
                              selectedField = field;
                            });
                          break;
                          case PatternFieldType.knittingchart:
                            PatternChartField field = PatternChartField(id: id);
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, field]
                            ), additionalState: () {
                              selectedField = field;
                            });
                          break;
                          case PatternFieldType.drawing:
                            PatternDrawingField field = PatternDrawingField(id: id);
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, field]
                            ), additionalState: () {
                              selectedField = field;
                            });
                          break;
                          case PatternFieldType.image:
                            PatternImageField field = PatternImageField(id: id);
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, field]
                            ), additionalState: () {
                              selectedField = field;
                            });
                          break;
                          case PatternFieldType.panel:
                            PatternPanelField field = PatternPanelField(id: id);
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, field]
                            ), additionalState: () {
                              selectedField = field;
                            });
                          break;
                        }
                      },
                      fieldToolbar: 
                        selectedField?.fieldType == PatternFieldType.drawing ?
                          PatternDrawingFieldToolbar(
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
                          field: selectedField as PatternPanelField, 
                          onChanged: (newField) => _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                            fields: stateKnittingPattern.fields.map((f) => f.id != newField.id ? f : newField).toList()
                          ), additionalState: () => selectedField = newField,), 
                        ) :
                        selectedField?.fieldType == PatternFieldType.texteditor ?
                        PatternTextEditorFieldToolbar(
                          fleatherController: fleatherControllers[selectedField!.id]!,
                          editorKey: fleaterEditorKeys[selectedField!.id]!,
                        ) :
                        null,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
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
                ],
              ),
            ),
          )
      ),
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