
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/toolbar/colours_toolbar_panel.dart';
import 'package:knitty_griddy/charts/toolbar/grid_options_toolbar_panel.dart';
import 'package:knitty_griddy/charts/toolbar/stitches_toolbar_panel.dart';
import 'package:knitty_griddy/charts/model/app_state.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:provider/provider.dart';

class KnittingToolbar extends StatelessWidget {

  const KnittingToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(5.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double areawidth = (constraints.maxWidth - 40.0);
          return IntrinsicHeight(
            child: Row(
              children: [
                SizedBox(height: 200, width: areawidth * 0.20, 
                  child: const GridOptionsToolbarPanel(),
                ),
                const VerticalDivider(indent: 10, endIndent: 10,),
                SizedBox(
                  height: 200, width: areawidth * 0.60, 
                  child: Selector<ChartsModel, AppState>(
                    selector: (_, model) => model.appState,
                    builder: (context, appState, _) {
                      if (appState.mouseOption == MouseOption.settings) {
                        return const SizedBox.expand();
                      }
                      return const StitchesToolbarPanel();
                    }
                  ),
                ),
                const VerticalDivider(indent: 10, endIndent: 10,),
                SizedBox(height: 200, width: areawidth * 0.20, 
                  child: Selector<ChartsModel, AppState>(
                    selector: (_, model) => model.appState,
                    builder: (context, appState, _) {
                      if (appState.mouseOption == MouseOption.settings) {
                        return const SizedBox.expand();
                      }
                      return const ColoursToolbarPanel();
                    }
                  )
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
