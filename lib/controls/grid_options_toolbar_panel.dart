
import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class GridOptionsToolbarPanel extends StatelessWidget {
  const GridOptionsToolbarPanel({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, AppState>(
      selector: (_, model) => model.appState,
      builder: (context, appState, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Card(
                color: appState.mouseOption == MouseOption.singleclick ? Colors.blue.withAlpha(60) : null,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () => Provider.of<KnittyGriddyModel>(context, listen: false).setMouseOption(MouseOption.singleclick),
                  child: const Center(
                    child: Row(
                      children: [
                        SizedBox(width: 14, height: 40,),
                        Icon(Icons.touch_app),
                        SizedBox(width: 14,),
                        Text('Single click'),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                color: appState.mouseOption == MouseOption.painting ? Colors.blue.withAlpha(60) : null,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () => Provider.of<KnittyGriddyModel>(context, listen: false).setMouseOption(MouseOption.painting),
                  child: const Row(
                    children: [
                      SizedBox(width: 14, height: 40,),
                      Icon(Icons.brush),
                      SizedBox(width: 14,),
                      Text('Paint'),
                    ],
                  ),
                ),
              ),
              Card(
                color: appState.mouseOption == MouseOption.selecting ? Colors.blue.withAlpha(60) : null,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () => Provider.of<KnittyGriddyModel>(context, listen: false).setMouseOption(MouseOption.selecting),
                  child: const Row(
                    children: [
                      SizedBox(width: 14, height: 40,),
                      Icon(Icons.select_all),
                      SizedBox(width: 14,),
                      Text('Select'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}