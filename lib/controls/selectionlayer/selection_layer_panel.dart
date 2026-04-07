
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/controls/selectionlayer/selection_control.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class SelectionLayerPanel extends StatelessWidget {
  final int rows;
  final int columns;

  const SelectionLayerPanel({
    required this.rows,
    required this.columns,  
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, AppState>(
      selector: (_, model) => model.appState,
      builder: (context, appState, _) {
        return SizedBox(
          width: (columns * stitchCellWidth) + (2 * stitchCellWidth),
          height: (rows * stitchCellHeight) + (2 * stitchCellHeight),
          child: appState.currentTool != Tool.select ? 
            const Placeholder(color: Colors.transparent,) :
            Stack(
              children: [
                // Select all
                Positioned(
                  child: IconButton(
                    onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).selectAll(), 
                    icon: const Icon(Icons.select_all)
                  )
                ),
                // Select none
                Positioned(
                  right: 0, bottom: 0,
                  child: IconButton(
                    onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).selectNone(), 
                    icon: const Icon(Icons.cancel_outlined)
                  )
                ),
                // Select columns top
                for (int col = 0; col < columns; col++)
                  Positioned(
                    top: 0, left: stitchCellWidth + (col * stitchCellWidth),
                    child: IconButton(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).selectColumn(col), 
                      icon: const Icon(Icons.circle_outlined, color: Colors.transparent,)
                    )
                  ),
                // Select columns bottom
                for (int col = 0; col < columns; col++)
                  Positioned(
                    bottom: 0, left: stitchCellWidth + (col * stitchCellWidth),
                    child: IconButton(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).selectColumn(col), 
                      icon: const Icon(Icons.circle_outlined, color: Colors.transparent,)
                    )
                  ),
                // Select rows left
                for (int row = 0; row < rows; row++)
                  Positioned(
                    left: 0, top: stitchCellHeight + (row * stitchCellHeight),
                    child: IconButton(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).selectRow(row), 
                      icon: const Icon(Icons.circle_outlined, color: Colors.transparent,)
                    )
                  ),
                // Select rows right
                for (int row = 0; row < rows; row++)
                  Positioned(
                    right: 0, top: stitchCellHeight + (row * stitchCellHeight),
                    child: IconButton(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).selectRow(row), 
                      icon: const Icon(Icons.circle_outlined, color: Colors.transparent,)
                    )
                  ),
                const SelectionControl(),
              ],
            ),
        );
      }
    );
  }
}