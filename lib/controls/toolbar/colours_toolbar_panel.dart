
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/named_colour.dart';
import 'package:knitty_griddy/controls/toolbar/add_new_colour_dialog.dart';
import 'package:knitty_griddy/controls/toolbar/edit_colour_dialog.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/selection.dart';
import 'package:provider/provider.dart';

class ColoursToolbarPanel extends StatelessWidget {

  const ColoursToolbarPanel({
    super.key
  });

  String _truncateName(String name, int maxLength) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Selector<KnittyGriddyModel, List<NamedColour>>(
        selector: (_, model) => model.usedColours,
        builder: (context, usedColours, _) {
          double spacerWidth = 8;
          double colourWellWidth = 40;
          double minWidth = 0;
          double iconWidth = 16;
          for (NamedColour colour in usedColours) {
            double width = colourWellWidth + (iconWidth * 3) + (spacerWidth * 4) + (_truncateName(colour.name, 25).length * 16);
            if (width > minWidth) {
              minWidth = width;
            }
          }
          return Column(
            children: [
              Selector<KnittyGriddyModel, AppState>(
                selector: (_, model) => model.appState,
                builder: (context, appState, _) {
                  return Selector<KnittyGriddyModel, Selection>(
                    selector: (_, model) => model.selection,
                    builder: (context, selection, _) {
                      return Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          for (NamedColour colour in usedColours)
                            SizedBox(
                              width: minWidth, height: 50,
                              child: Card(
                                color: appState.currentTool != Tool.select ? appState.selectedColour == colour ? Colors.blue.withAlpha(60) : null : null,
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  splashColor: Colors.blue.withAlpha(30),
                                  onTap: (appState.currentTool == Tool.select && selection.isEmpty) ?
                                  null :
                                  () {
                                    switch (appState.currentTool) {
                                      case Tool.stitch:
                                      case Tool.colour:
                                        Provider.of<KnittyGriddyModel>(context, listen: false).appUseColour(colour);
                                        break;
                                      case Tool.select:
                                        Provider.of<KnittyGriddyModel>(context, listen: false).fillSelectionWithColor(colour);
                                        break;
                                      default:
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: spacerWidth,),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(5)), 
                                          color: colour.color
                                        ), 
                                        width: colourWellWidth, 
                                        height: 30,),
                                      SizedBox(width: spacerWidth,),
                                      Text(_truncateName(colour.name, 25),
                                        style: (appState.currentTool == Tool.select && selection.isEmpty) ?
                                          Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade400) :
                                          Theme.of(context).textTheme.bodyMedium!,
                                      ),
                                      SizedBox(width: spacerWidth,),
                                      IconButton(
                                        icon: const Icon(Icons.edit), 
                                        iconSize: iconWidth, 
                                        onPressed: () => 
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return EditColourDialog(colour: colour, usedColours: usedColours);
                                            }
                                          ),
                                      ),
                                      SizedBox(width: spacerWidth,),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }
                  );
                }
              ),
              const SizedBox(height: 20,),
              Align(
                alignment: Alignment.bottomCenter, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.outlined(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) {
                          return AddNewColourDialog(usedColours: usedColours);
                        }
                      ),
                      icon: const Icon(Icons.add)
                    ),
                    const SizedBox(width: 20,),
                    IconButton.outlined(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).pruneUnusedColours(), 
                      icon: const Icon(Icons.content_cut)
                    )
                  ],
                )
              ),
            ],
          );
        },
      ),
    );
  }
}