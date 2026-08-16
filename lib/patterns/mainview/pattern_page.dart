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
import 'package:knitty_griddy/utils/app_platform_ext.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/dashed_painter.dart';
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

  late ScrollController _verticalScrollController;

  @override
  void initState() {
    _keyboardFocusNode = FocusNode();

    stateKnittingPattern = widget.knittingPattern;
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
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Pattern - ${stateKnittingPattern.name}')]),
        backgroundColor: Colors.grey.shade300,
/*        bottom: const PreferredSize(
          preferredSize: Size(20000, 200), 
          child: KnittingToolbar(),
        ),*/
        actions: [
          Visibility(
            visible: !viewMode,
            child: Tooltip(
              message: 'Pattern settings',
              child: IconButton(
                onPressed: () async {
                  KnittingPattern? newPattern = await showDialog(
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
                        PatternField newField = field.abstractCopyWith();
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
                        double posY = _verticalScrollController.offset;
                        double posX = PatternPageLayout.margin;
                        // If we didn't scroll, place the new field inside the margins
                        if (posY == 0) {
                          posY = PatternPageLayout.margin - kDraggerHeight;
                        }
                        String id = const UuidV4Gen().get();
                        switch (type) {
                          case PatternFieldType.texteditor:
                            PatternTextEditorField field = PatternTextEditorField(
                              id: id,
                              positionX: posX,
                              positionY: posY
                            );
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
                            PatternChartField field = PatternChartField(
                              id: id,
                              positionX: posX,
                              positionY: posY
                            );
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, field]
                            ), additionalState: () {
                              selectedField = field;
                            });
                          break;
                          case PatternFieldType.drawing:
                            PatternDrawingField field = PatternDrawingField(
                              id: id,
                              positionX: posX,
                              positionY: posY
                            );
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, field]
                            ), additionalState: () {
                              selectedField = field;
                            });
                          break;
                          case PatternFieldType.image:
                            PatternImageField field = PatternImageField(
                              id: id,
                              positionX: posX,
                              positionY: posY
                            );
                            _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                              fields: [...stateKnittingPattern.fields, field]
                            ), additionalState: () {
                              selectedField = field;
                            });
                          break;
                          case PatternFieldType.panel:
                            PatternPanelField field = PatternPanelField(
                              id: id,
                              positionX: posX,
                              positionY: posY
                            );
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
                              _storeAndSetKnittingPattern(stateKnittingPattern.copyWith(
                                fields: stateKnittingPattern.fields.map((f) => f.id != selectedField!.id ? f : (f as PatternTextEditorField).copyWith(
                                  settings: newSettings
                                )).toList()
                              ));
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
                                      painter: PageMarginPainter(pageLayout: stateKnittingPattern.pageLayout),
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

  const PageMarginPainter({
    required this.pageLayout,
  });

  @override
  void paint(Canvas canvas, Size size) {
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

    if (pageLayout.showGrid) {
      Paint gridPaint = Paint()..color = Colors.grey.withAlpha(150)..style = PaintingStyle.stroke;
      double oneCm = 10 * PatternPageLayout.pixelsPerMM;
      for (int page = 0; page < pageLayout.numberOfPages; page++) {
        // Vertical
        for (double xOffset = PatternPageLayout.margin + oneCm; xOffset < pageLayout.pagewidth - PatternPageLayout.margin; xOffset += oneCm) {
          Path gridLine = Path()..moveTo(xOffset, PatternPageLayout.margin)..lineTo(xOffset, pageLayout.pageheight - PatternPageLayout.margin);
          DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.dots.dashPattern).paint(canvas, gridLine, gridPaint);
        }
        // Horizontal
        for (double yOffset = PatternPageLayout.margin + oneCm; yOffset < pageLayout.pageheight - PatternPageLayout.margin; yOffset += oneCm) {
          Path gridLine = Path()..moveTo(PatternPageLayout.margin, yOffset)..lineTo(pageLayout.pagewidth - PatternPageLayout.margin, yOffset);
          DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.dots.dashPattern).paint(canvas, gridLine, gridPaint);
        }        
      }
    }
  }

  @override
  bool shouldRepaint(covariant PageMarginPainter oldDelegate) {
    return pageLayout != oldDelegate.pageLayout;
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