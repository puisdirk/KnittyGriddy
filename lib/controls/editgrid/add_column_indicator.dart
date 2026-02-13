
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class AddColumnIndicator extends StatefulWidget {
  final int column;
  final double height;

  const AddColumnIndicator({
    required this.column,
    required this.height,
    super.key
  });

  @override
  State<AddColumnIndicator> createState() => _AddColumnIndicatorState();
}

class _AddColumnIndicatorState extends State<AddColumnIndicator> {
  bool visible = false;

  void _insertColumn(BuildContext context) {
    Provider.of<KnittyGriddyModel>(context, listen: false).insertColumn(widget.column + 1);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: stitchCellWidth,
      height: widget.height,
      child: Column(
        children: [
          MouseRegion(
            onHover: (_) { if (!visible) {setState(() => visible = true);} },
            onExit: (_) => setState(() => visible = false),
            child: SizedBox(
              height: stitchCellHeight, 
              child: Container(
                child: visible ? IconButton.outlined(
                  onPressed: () => _insertColumn(context), 
                  icon: const Icon(Icons.add, color: Colors.green,)
                ) : null,
              ),
            ),
          ),
          SizedBox(
            height: widget.height - (2 * stitchCellHeight), 
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: (stitchCellWidth / 2) - 2),
              child: Container(color: visible ? Colors.green.shade700 : Colors.transparent),
            )),
          MouseRegion(
            onHover: (_) { if (!visible) {setState(() => visible = true);} },
            onExit: (_) => setState(() => visible = false),
            child: SizedBox(
              height: stitchCellHeight, 
              child: Container(
                child: visible ? IconButton.outlined(
                  onPressed: () => _insertColumn(context), 
                  icon: const Icon(Icons.add, color: Colors.green,)
                ) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}