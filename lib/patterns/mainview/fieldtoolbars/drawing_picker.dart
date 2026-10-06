import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class DrawingPicker extends StatefulWidget {
  const DrawingPicker({super.key});

  @override
  State<DrawingPicker> createState() => _DrawingPickerState();
}

class _DrawingPickerState extends State<DrawingPicker> {
  late DrawingInfo? selectedDrawingInfo;

  String _filterText = '';
  late TextEditingController _filterController;

  void _filterChanged() {
    setState(() => _filterText = _filterController.text);
  }

  @override
  void initState() {
    _filterController = TextEditingController(text: _filterText);
    _filterController.addListener(_filterChanged);

    selectedDrawingInfo = DrawingInfo.emptyDrawingInfo;

    super.initState();
  }

  @override
  void dispose() {
    _filterController.removeListener(_filterChanged);
    _filterController.dispose();

    super.dispose();
  }

  Widget _drawingInfoCard(DrawingInfo drawingInfo) {
    return SizedBox(
      width: 300,
      height: 100,
      child: Card(
        color: drawingInfo == selectedDrawingInfo ? Colors.blue.withAlpha(60) : null,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          splashColor: Colors.blue.withAlpha(30),
          onTap: () => setState(() => selectedDrawingInfo = drawingInfo),
          onDoubleTap: () => Navigator.of(context).pop(drawingInfo),
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (drawingInfo.hasPreview)
                  SizedBox(
                    width: DrawingInfo.previewImageWidth,
                    height: DrawingInfo.previewImageHeight,
                    child: Image(
                      width: DrawingInfo.previewImageWidth, 
                      height: DrawingInfo.previewImageHeight, 
                      image: MemoryImage(drawingInfo.previewImage!)
                    )
                  ),
                if (drawingInfo.hasPreview)
                  hspacing,
                Column(
                  children: [
                    Text(drawingInfo.name, textAlign: TextAlign.center,),
                    Text(
                      style: smallStyle,
                      drawingInfo.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (value) {
        if (value.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop(null);
        } else if (value.logicalKey == LogicalKeyboardKey.enter) {
          if (selectedDrawingInfo == null || selectedDrawingInfo == DrawingInfo.emptyDrawingInfo) {
            Navigator.of(context).pop(null);
          } else {
            Navigator.of(context).pop(selectedDrawingInfo);
          }
        }
      },
      child: AlertDialog(
        title: const Text('Select drawing'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Filter'),
                  hspacing,
                  SizedBox(
                    width: 500,
                    child: TextField(controller: _filterController, autofocus: true,),
                  )
                ],
              ),
              vspacing,
              Expanded(
                child: Selector<DrawingsModel, List<DrawingInfo>>(
                  selector: (_, model) => model.filteredDrawingInfos(_filterText),
                  builder: (context, drawingInfos, _) {
                    return Wrap(
                      children: [
                        for (DrawingInfo drawingInfo in drawingInfos)
                          _drawingInfoCard(drawingInfo),
                      ],
                    );
                  }
                )
              )
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(null), 
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: selectedDrawingInfo == null || selectedDrawingInfo == DrawingInfo.emptyDrawingInfo ? null : 
              () => Navigator.of(context).pop(selectedDrawingInfo), 
            child: const Text('Choose'),
          )
        ],
      ),
    );
  }
}