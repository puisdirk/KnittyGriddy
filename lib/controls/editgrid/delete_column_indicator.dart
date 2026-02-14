
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class DeleteColumnIndicator extends StatefulWidget {
  final int column;
  final double height;

  const DeleteColumnIndicator({
    required this.column,
    required this.height,
    super.key
  });

  @override
  State<DeleteColumnIndicator> createState() => _DeleteColumnIndicatorState();
}

class _DeleteColumnIndicatorState extends State<DeleteColumnIndicator> {
  bool visible = false;

  void _deleteColumn(BuildContext context) {
    Provider.of<KnittyGriddyModel>(context, listen: false).deleteColumn(widget.column + 1);
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
                  onPressed: () => _deleteColumn(context), 
                  icon: const Icon(Icons.remove, color: Colors.red,)
                ) : null,
              ),
            ),
          ),
          SizedBox(
            height: widget.height - (2 * stitchCellHeight), 
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: (stitchCellWidth / 2) - 2),
              child: IgnorePointer(child: Container(color: visible ? Colors.red.shade700 : Colors.transparent)),
            )),
          MouseRegion(
            onHover: (_) { if (!visible) {setState(() => visible = true);} },
            onExit: (_) => setState(() => visible = false),
            child: SizedBox(
              height: stitchCellHeight, 
              child: Container(
                child: visible ? IconButton.outlined(
                  onPressed: () => _deleteColumn(context), 
                  icon: const Icon(Icons.remove, color: Colors.red,)
                ) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}