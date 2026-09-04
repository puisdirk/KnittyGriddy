import 'package:directed_graph/directed_graph.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/mainview/link_mode/link_control.dart';
import 'package:knitty_griddy/patterns/mainview/link_mode/text_editor_field_outline.dart';
import 'package:knitty_griddy/patterns/mainview/page_margin_painter.dart';
import 'package:knitty_griddy/patterns/mainview/pattern_page.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/text_field_link.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class LinksModeView extends StatefulWidget {
  final KnittingPattern pattern;
  final void Function(KnittingPattern newPattern) onChanged;

  const LinksModeView({
    required this.pattern,
    required this.onChanged,
    super.key
  });

  @override
  State<LinksModeView> createState() => _LinksModeViewState();
}

class _LinksModeViewState extends State<LinksModeView> {
  late KnittingPattern stateKnittingPattern;
  List<String> acceptableDragSources = [];
  List<String> acceptableDropTargets = [];
  String draggedLinkId = '';

  @override
  void initState() {
    stateKnittingPattern = widget.pattern;
    acceptableDragSources = widget.pattern.freeTextEditorLinks;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LinksModeView oldWidget) {
    stateKnittingPattern = widget.pattern;
    acceptableDragSources = widget.pattern.freeTextEditorLinks;
    super.didUpdateWidget(oldWidget);
  }

  void _startDragging(String fieldId, bool fromOutput) {
    // find acceptable targets and set them in the state
    setState(() {
      draggedLinkId = '$fieldId:${fromOutput ? 'output' : 'input'}';
      acceptableDropTargets = stateKnittingPattern.acceptableLinkTargetsFor(fieldId, fromOutput);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
                    CustomPaint(
                      size: Size(
                        stateKnittingPattern.pageLayout.pagewidth,
                        stateKnittingPattern.pageLayout.pageheight * stateKnittingPattern.pageLayout.numberOfPages,
                      ),
                      painter: PageMarginPainter(
                        pageLayout: stateKnittingPattern.pageLayout, patternPageMode: PatternPageMode.links
                      ),
                    ),
                    for (PatternTextEditorField field in stateKnittingPattern.textEditorFields)
                      Positioned(
                        left: field.positionX,
                        top: field.positionY,
                        child: TextEditorFieldOutline(field: field)
                      ),
                    for (PatternTextEditorField field in stateKnittingPattern.textEditorFields)
                      Positioned(
                        left: field.positionX + 10,
                        top: field.positionY + 10,
                        child: acceptableDragSources.isEmpty || stateKnittingPattern.textFieldLinks.hasIncomingLink(field.id) ?
                          Opacity(opacity: .2, child: Icon(stateKnittingPattern.textFieldLinks.hasIncomingLink(field.id) ? Symbols.line_end_circle : Symbols.line_end_diamond))
                        : Draggable<String>(
                          data: '${field.id}:input',
                          feedback: const Icon(Symbols.line_end_diamond),
                          onDragStarted: () => _startDragging(field.id, false),
                          onDragEnd: (details) {
                            setState(() => draggedLinkId = '');
                          },
                          child: DragTarget<String>(
                            onWillAcceptWithDetails: (details) => acceptableDropTargets.contains('${field.id}:input'),
                            onAcceptWithDetails: (details) {
                              widget.onChanged(stateKnittingPattern.addTextFieldLink(draggedLinkId.split(':').first, field.id));
                              setState(() => draggedLinkId = '');                              
                            },
                            builder: (context, candidateData, rejectedData) {
                              if (draggedLinkId.isEmpty || acceptableDropTargets.contains('${field.id}:input')) {
                                return const MouseRegion(
                                  cursor: SystemMouseCursors.grab,
                                  child: Icon(Symbols.line_end_diamond)
                                );
                              } else {
                                return const Opacity(opacity: 0.2, child: Icon(Symbols.line_end_diamond),);
                              }
                            },
                          ),
                        )
                      ),
                    for (PatternTextEditorField field in stateKnittingPattern.textEditorFields)
                      Positioned(
                        left: field.positionX + field.width - kConnectorSize.width - 10,
                        top: field.positionY + field.height - kConnectorSize.height - 10,
                        child: acceptableDragSources.isEmpty || stateKnittingPattern.textFieldLinks.hasOutgoingLink(field.id) ?
                          Opacity(opacity: .2, child: Icon(stateKnittingPattern.textFieldLinks.hasOutgoingLink(field.id) ? Symbols.line_start_circle : Symbols.line_start_diamond))
                        : Draggable<String>(
                          data: '${field.id}:output',
                          feedback: const Icon(Symbols.line_start_diamond),
                          onDragStarted: () => _startDragging(field.id, true),
                          onDragEnd: (details) {
                            setState(() => draggedLinkId = '');
                          },
                          child: DragTarget<String>(
                            onWillAcceptWithDetails: (details) => acceptableDropTargets.contains('${field.id}:output'),
                            onAcceptWithDetails: (details) {
                              widget.onChanged(stateKnittingPattern.addTextFieldLink(field.id, draggedLinkId.split(':').first));
                              setState(() => draggedLinkId = '');                              
                            },
                            builder: (context, candidateData, rejectedData) {
                              if (draggedLinkId.isEmpty || acceptableDropTargets.contains('${field.id}:output')) {
                                return const MouseRegion(
                                  cursor: SystemMouseCursors.grab,
                                  child: Icon(Symbols.line_start_diamond)
                                );
                              } else {
                                return const Opacity(opacity: 0.2, child: Icon(Symbols.line_start_diamond),);
                              }
                            }
                          ),
                        )
                      ),
                    for (TextFieldLink link in stateKnittingPattern.textFieldLinks.links)
                      LinkControl(
                        pattern: stateKnittingPattern,
                        link: link,
                        dragging: draggedLinkId.isNotEmpty,
                        onDeleteLink: () => widget.onChanged(stateKnittingPattern.removeTextFieldLink(link))
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}