
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class AddRowIndicator extends StatefulWidget {
  final int row;
  final double width;

  const AddRowIndicator({
    required this.row,
    required this.width,
    super.key
  });

  @override
  State<AddRowIndicator> createState() => _AddRowIndicatorState();
}

class _AddRowIndicatorState extends State<AddRowIndicator> {
  bool visible = false;

  void _insertRow(BuildContext context) {
    Provider.of<KnittyGriddyModel>(context, listen: false).insertRow(widget.row + 1);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: stitchCellHeight,
      child: Row(
        children: [
          MouseRegion(
            onHover: (_) { if (!visible) {setState(() => visible = true);} },
            onExit: (_) => setState(() => visible = false),
            child: SizedBox(
              width: stitchCellWidth, 
              child: Container(
                child: visible ? IconButton.outlined(
                  onPressed: () => _insertRow(context), 
                  icon: const Icon(Icons.add, color: Colors.green,)
                ) : null,
              ),
            ),
          ),
          SizedBox(
            width: widget.width - (2 * stitchCellWidth), 
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: (stitchCellHeight / 2) - 2),
              child: Container(color: visible ? Colors.green.shade700 : Colors.transparent),
            )),
          MouseRegion(
            onHover: (_) { if (!visible) {setState(() => visible = true);} },
            onExit: (_) => setState(() => visible = false),
            child: SizedBox(
              width: stitchCellWidth, 
              child: Container(
                child: visible ? IconButton.outlined(
                  onPressed: () => _insertRow(context), 
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