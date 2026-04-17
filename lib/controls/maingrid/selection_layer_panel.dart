
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/maingrid/selection_control.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
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
          width: (columns * stitchCellWidth) + (3 * stitchCellWidth),
          height: (rows * stitchCellHeight) + (3 * stitchCellHeight),
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
                  right: stitchCellWidth, bottom: stitchCellHeight,
                  child: IconButton(
                    onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).selectNone(), 
                    icon: const Icon(Icons.deselect)
                  )
                ),
                // Invert selection
                Positioned(
                  right: stitchCellWidth,
                  child: IconButton(
                    onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).invertSelection(), 
                    icon: const Icon(Icons.flaky)
                  ),
                ),
                // Set marked cells
                Positioned(
                  bottom: stitchCellHeight,
                  child: Transform.rotate(
                    angle: MathUtitilies.toRadians(45),
                    child: IconButton(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).setOutline(), 
                      icon: const Icon(Icons.api)
                    ),
                  ),
                ),
                // Select columns top
                for (int col = 0; col < columns; col++)
                  Positioned(
                    top: 0, left: stitchCellWidth + (col * stitchCellWidth),
                    child: IconButton(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).toggleColumn(col), 
                      icon: const Icon(Icons.circle_outlined, color: Colors.transparent,)
                    )
                  ),
                // Select columns bottom
                for (int col = 0; col < columns; col++)
                  Positioned(
                    bottom: stitchCellHeight, left: stitchCellWidth + (col * stitchCellWidth),
                    child: IconButton(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).toggleColumn(col), 
                      icon: const Icon(Icons.circle_outlined, color: Colors.transparent,)
                    )
                  ),
                // Select rows left
                for (int row = 0; row < rows; row++)
                  Positioned(
                    left: 0, top: stitchCellHeight + (row * stitchCellHeight),
                    child: IconButton(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).toggleRow(row), 
                      icon: const Icon(Icons.circle_outlined, color: Colors.transparent,)
                    )
                  ),
                // Select rows right
                for (int row = 0; row < rows; row++)
                  Positioned(
                    right: stitchCellWidth, top: stitchCellHeight + (row * stitchCellHeight),
                    child: IconButton(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).toggleRow(row), 
                      icon: const Icon(Icons.circle_outlined, color: Colors.transparent,)
                    )
                  ),
                // Even columns
                if (columns > 4)
                  Positioned(
                    bottom: 0,
                    left: ((columns * stitchCellWidth) / 2) - stitchCellWidth,
                    child: IconButton.outlined(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).toggleEvenColumns(), 
                      icon: const Text('2-4-6'),
                    ),
                  ),
                // Odd columns
                if (columns > 4)
                  Positioned(
                    bottom: 0,
                    left: ((columns * stitchCellWidth) / 2) + stitchCellWidth,
                    child: IconButton.outlined(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).toggleOddColumns(), 
                      icon: const Text('1-3-5'),
                    ),
                  ),
                // Even rows
                if (rows > 4)
                  Positioned(
                    top: ((rows * stitchCellHeight) / 2) - stitchCellHeight,
                    right: 0,
                    child: Transform.rotate(
                      angle: MathUtitilies.toRadians(90),
                      child: IconButton.outlined(
                        onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).toggleEvenRows(), 
                        icon: const Text('2-4-6'),
                      ),
                    ),
                  ),
                // Odd rows
                if (rows > 4)
                  Positioned(
                    top: ((rows * stitchCellHeight) / 2) + stitchCellHeight,
                    right: 0,
                    child: Transform.rotate(
                      angle: MathUtitilies.toRadians(90),
                      child: IconButton.outlined(
                        onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).toggleOddRows(), 
                        icon: const Text('1-3-5',),
                      ),
                    ),
                  ),
                const SelectionControl(),
              ],
            ),
        );
      }
    );
  }
}