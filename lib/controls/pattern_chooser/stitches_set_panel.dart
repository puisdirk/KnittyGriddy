import 'package:flutter/material.dart';
import 'package:grouped_scroll_view/grouped_scroll_view.dart';
import 'package:knitty_griddy/controls/stitch_icon.dart';
import 'package:knitty_griddy/controls/stitcheditor/edit_stitch_page.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitches_set.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class StitchesSetPanel extends StatefulWidget {
  final StitchesSet stitchSet;
  
  const StitchesSetPanel({
    required this.stitchSet,
    super.key
  });

  @override
  State<StitchesSetPanel> createState() => _StitchesSetPanelState();
}

class _StitchesSetPanelState extends State<StitchesSetPanel> {

  List<StitchDefinition> selectedStitches = [];

  void toggleStitchSelection(StitchDefinition def) {
    setState(() {
      if (selectedStitches.contains(def)) {
        selectedStitches.remove(def);
      } else {
        selectedStitches.add(def);
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
                  await Provider.of<KnittyGriddyModel>(context, listen: false).exportStitchesSet(widget.stitchSet);
                }, 
                icon: const Icon(Symbols.upload, weight: 700,),
                label: const Text('Export'),
              ),
              const Spacer(),
              if (widget.stitchSet.definitions.isEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    StitchDefinition sd = Provider.of<KnittyGriddyModel>(context, listen: false).addStitch(category: 'General', stitchSetId: widget.stitchSet.id);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => EditStitchPage(stitchDefinition: sd)),
                    );
                  }, 
                  label: const Text('New Stitch'),
                ),
              const SizedBox(width: 10,),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context, 
                    builder: (context) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content: SizedBox(
                        height: 50,
                        child: Text('Are you sure you want to delete set "${widget.stitchSet.name}"? All its stitches will be deleted.'),
                      ),
                      actions: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context), 
                          child: const Text('Cancel')
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Provider.of<KnittyGriddyModel>(context, listen: false).deleteStitchSet(widget.stitchSet.id);
                            Navigator.pop(context);
                          },
                          child: const Text('OK')
                        ),                                              ],
                    ),
                  );
                }, 
                icon: const Icon(Icons.delete),
                label: const Text('Delete Set'),
              ),
              const SizedBox(width: 10,),
            ],
          ),
        ),
        Expanded(
          child: GroupedScrollView.list(
            groupedOptions: GroupedScrollViewOptions(
              itemGrouper: (StitchDefinition def) => def.category,
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
                          StitchDefinition sd = Provider.of<KnittyGriddyModel>(context, listen: false).addStitch(category: category, stitchSetId: widget.stitchSet.id);
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => EditStitchPage(stitchDefinition: sd)),
                            );
                          }, 
                          icon: const Icon(Icons.add)
                        )
                     ],
                  ),
                );
              }, 
            ),
            data: widget.stitchSet.definitions, 
            itemBuilder: (context, def) {
              return GestureDetector(
                onTap: null, //() => toggleStitchSelection(def),
                child: Container(
                  decoration: BoxDecoration(
                    border: BoxBorder.fromLTRB(bottom: BorderSide(color: Colors.grey.shade300)),
                    color: selectedStitches.contains(def) ? Colors.blue.withAlpha(60) : null,
                  ),
                  constraints: const BoxConstraints.tightFor(height: 50),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10,),
                      StitchIcon(stitchDefinition: def, iconSize: 20,),
                      const SizedBox(width: 20,),
                      Text(def.name),
                      const SizedBox(width: 20,),
                      if (def.description.isNotEmpty)
                        Text(def.description.replaceAll('\n', ' '), overflow: TextOverflow.ellipsis,),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => EditStitchPage(stitchDefinition: def)),
                          );
                        }, 
                        icon: const Icon(Icons.edit)
                      ),
//                      if (StitchRepository.instance.sets.length > 1)
                        // TODO: I want a dropdown here to move to another set
                      // TODO: add a duplicate button
                      IconButton(
                        onPressed: () {
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete stitch'),
                              content: const Text('Are you sure you want to delete the stitch? This action cannot be undone'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context), 
                                  child: const Text('Cancel')
                                ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Provider.of<KnittyGriddyModel>(context, listen: false).deleteStitch(def);
                                    },
                                    child: const Text('Yes')
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Provider.of<KnittyGriddyModel>(context, listen: false).deleteStitch(def);
                                    }, 
                                    child: const Text('Delete Permanently')
                                  )
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
              );
            },
          ),
        ),
      ],
    );
  }
}