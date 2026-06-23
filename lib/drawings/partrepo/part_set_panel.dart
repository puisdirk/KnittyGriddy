
import 'package:flutter/material.dart';
import 'package:grouped_scroll_view/grouped_scroll_view.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/drawings/drawing_part_icon.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';
import 'package:knitty_griddy/drawings/partrepo/move_part_drawing_to_set_menu.dart';
import 'package:knitty_griddy/drawings/drawing_editor/edit_drawing_page.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/partrepo/part_repository.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class PartSetPanel extends StatefulWidget {
  final PartSet partSet;
  
  const PartSetPanel({
    required this.partSet,
    super.key
  });

  @override
  State<PartSetPanel> createState() => _PartSetPanelState();
}

class _PartSetPanelState extends State<PartSetPanel> {

  List<PartDrawing> selectedPartDrawings = [];

  void togglePartDrawingSelection(PartDrawing partDrawing) {
    setState(() {
      if (selectedPartDrawings.contains(partDrawing)) {
        selectedPartDrawings.remove(partDrawing);
      } else {
        selectedPartDrawings.add(partDrawing);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: Row(
            children: [
              const SizedBox(width: 10,),
              OutlinedButton.icon(
                onPressed: () async {
                  await Provider.of<DrawingsModel>(context, listen: false).exportPartSet(widget.partSet);
                }, 
                icon: const Icon(Symbols.upload, weight: 700,),
                label: const Text('Export Set'),
              ),
              hspacing,
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context, 
                    builder: (context) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content: SizedBox(
                        height: 50,
                        child: Text('Are you sure you want to delete set "${widget.partSet.name}"? All its parts will be deleted.'),
                      ),
                      actions: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context), 
                          child: const Text('Cancel')
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Provider.of<DrawingsModel>(context, listen: false).deletePartSet(widget.partSet.id);
                            Navigator.pop(context);
                          },
                          child: const Text('OK')
                        ),
                      ],
                    ),
                  );
                }, 
                icon: const Icon(Icons.delete),
                label: const Text('Delete Set'),
              ),
              const Spacer(),
              if (widget.partSet.partDrawings.isEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    PartDrawing pd = Provider.of<DrawingsModel>(context, listen: false).addPartDrawing(category: 'General', partSetId: widget.partSet.id);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => EditDrawingPage(drawing: pd)),
                    );
                  }, 
                  label: const Text('New Part'),
                  icon: const Icon(Icons.add),
                ),
              hspacing,
              OutlinedButton.icon(
                onPressed: () => Provider.of<DrawingsModel>(context, listen: false).importPartDrawing(widget.partSet.id), 
                label: const Text('Import Part'),
                icon: const Icon(Symbols.download, weight: 700,),
              )
            ],
          ),
        ),
        Expanded(
          child: GroupedScrollView.list(
            groupedOptions: GroupedScrollViewOptions(
              itemGrouper: (PartDrawing pd) => pd.category,
              stickyHeaderBuilder: (BuildContext context, String category, int itemIndex) {
                return Container(
                  color: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  constraints: const BoxConstraints.tightFor(height: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(category, style: const TextStyle(fontWeight: FontWeight.bold),),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          PartDrawing pd = Provider.of<DrawingsModel>(context, listen: false).addPartDrawing(category: category, partSetId: widget.partSet.id);
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => EditDrawingPage(drawing: pd)),
                            );
                          }, 
                          icon: const Icon(Icons.add)
                        )
                     ],
                  ),
                );
              }, 
            ),
            data: widget.partSet.partDrawings, 
            itemBuilder: (context, partDrawing) {
              PartInfo? partInfo = partDrawing.firstValidPartInfo;
              return Column(
                children: [
                  for (PartInfo partInfo in partDrawing.validPartInfos)
                  GestureDetector(
                    onTap: null, //() => toggleStitchSelection(def),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                        color: selectedPartDrawings.contains(partDrawing) ? Colors.blue.withAlpha(60) : null,
                      ),
                      constraints: const BoxConstraints.tightFor(height: 50),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10,),
                          if (partInfo != null)
                            DrawingPartIcon(partInfo: partInfo),
                          if (partInfo == null)
                            const Icon(Symbols.apparel),
                          const SizedBox(width: 20,),
                          Text('${partInfo.partLabel} (${partDrawing.name})'),
                          const SizedBox(width: 20,),
                          if (partDrawing.description.isNotEmpty)
                            Text(partDrawing.description.replaceAll('\n', ' '), overflow: TextOverflow.ellipsis,),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => EditDrawingPage(drawing: partDrawing)),
                              );
                            }, 
                            icon: const Icon(Icons.edit)
                          ),
                          if (PartRepository.instance.sets.length > 1)
                            MovePartDrawingToSetMenu(partDrawing: partDrawing, currentPartSet: widget.partSet),
                          IconButton(
                            onPressed: () {
                              PartDrawing newDrawing = partDrawing.copyWith(id: const UuidV4Gen().get());
                              Provider.of<DrawingsModel>(context, listen: false).addPartToSet(
                                targetPartSet: widget.partSet, 
                                part: newDrawing
                              );
                            }, 
                            icon: const Icon(Symbols.content_copy, weight: 700,)
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(context: context, builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete part'),
                                  content: const Text('Are you sure you want to delete the part? This action cannot be undone'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context), 
                                      child: const Text('Cancel')
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Provider.of<DrawingsModel>(context, listen: false).deletePartDrawing(partDrawing);
                                      },
                                      child: const Text('Delete')
                                    ),
                                  ],
                                );
                              });
                            }, 
                            icon: const Icon(Icons.delete),
                          ),
                          const SizedBox(width: 10,),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}