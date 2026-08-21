import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/pattern_page_layout.dart';
import 'package:knitty_griddy/utils/constants.dart';

class PatternSettingsDialog extends StatefulWidget {
  final KnittingPattern pattern;

  const PatternSettingsDialog({
    required this.pattern,
    super.key
  });

  @override
  State<PatternSettingsDialog> createState() => _PatternSettingsDialogState();
}

class _PatternSettingsDialogState extends State<PatternSettingsDialog> {
  late KnittingPattern newPattern;
  late TextEditingController nameController;
  late TextEditingController descriptonController;

  void _nameChanged() {
    setState(() => newPattern = newPattern.copyWith(name: nameController.text));
  }

  void _descriptionChanged() {
    setState(() => newPattern = newPattern.copyWith(description: descriptonController.text));
  }

  @override
  void initState() {
    newPattern = widget.pattern;

    nameController = TextEditingController(text: widget.pattern.name);
    nameController.addListener(_nameChanged);

    descriptonController = TextEditingController(text: widget.pattern.description);
    descriptonController.addListener(_descriptionChanged);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PatternSettingsDialog oldWidget) {
    newPattern = widget.pattern;

    nameController.text = widget.pattern.name;
    descriptonController.text = widget.pattern.description;

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    nameController.removeListener(_nameChanged);
    nameController.dispose();

    descriptonController.removeListener(_descriptionChanged);
    descriptonController.dispose();

    super.dispose();
  }

  static const double _kLabelWidth = 80;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pattern settings'),
      content: SizedBox(
        width: 400,
        height: 490,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, child: Text('Name', textAlign: TextAlign.right,)),
                hspacing,
                SizedBox(width: 200,
                  child: TextField(
                    controller: nameController,
                  ),
                )
              ],
            ),
            vspacing,
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, child: Text('Description', textAlign: TextAlign.right,)),
                hspacing,
                SizedBox(width: 200,
                  child: TextField(
                    controller: descriptonController,
                    maxLines: 3,
                  ),
                )
              ],
            ),
            vspacing,
            vspacing,
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, child: Text('Page format', textAlign: TextAlign.right,)),
                hspacing,
                DropdownButton<PageSize>(
                  autofocus: false, 
                  focusColor: Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  underline: Container(),
                  padding: const EdgeInsets.only(left: 10, right: 5),
                  items: [
                    for (PageSize size in PageSize.values)
                      DropdownMenuItem(value: size, child: Text(size.label)),
                  ], 
                  value: newPattern.pageLayout.pageSize,
                  onChanged: (PageSize? newSize) { 
                    if (newSize != null && newSize != newPattern.pageLayout.pageSize) { 
                      setState(() => newPattern = newPattern.copyWith(pageLayout: newPattern.pageLayout.copyWith(pageSize: newSize)));
                    } 
                  },
                ),
              ],
            ),
            vspacing,
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, child: Text('Orientation', textAlign: TextAlign.right,)),
                hspacing,
                Column(
                  children: [
                    for (PageOrientation orientation in PageOrientation.values)
                      SizedBox(
                        width: 200,
                        child: RadioListTile(
                          value: orientation, 
                          groupValue: newPattern.pageLayout.pageOrientation, 
                          onChanged: (value) {
                            if (value != null && value != newPattern.pageLayout.pageOrientation) {
                              setState(() => newPattern = newPattern.copyWith(pageLayout: newPattern.pageLayout.copyWith(pageOrientation: value)));
                            }
                          },
                          title: Row(children: [Icon(orientation.iconData), Text(orientation.label),],),
                        ),
                      ),
                  ],
                )
              ],
            ),
            vspacing,
            vspacing,
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, child: Text('Pages', textAlign: TextAlign.right,)),
                hspacing,
                SizedBox(
                  width: 140,
                  child: SpinBox(
                    onChanged: (value) {
                      if (value != newPattern.pageLayout.numberOfPages) {
                        setState(() => newPattern = newPattern.copyWith(pageLayout: newPattern.pageLayout.copyWith(numberOfPages: value.toInt())));
                      }
                    },
                    min: 1,
                    max: 10,
                    value: newPattern.pageLayout.numberOfPages.toDouble(),
                  ),
                )
              ],
            ),
            vspacing,
            SizedBox(
              width: 250,
              child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: newPattern.pageLayout.showPageNumber, 
                onChanged: (value) => setState(() => newPattern = newPattern.copyWith(pageLayout: newPattern.pageLayout.copyWith(showPageNumber: value == true))),
                title: const Text('Show page numbers'),
              ),
            ),
            SizedBox(
              width: 250,
              child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: newPattern.pageLayout.showGrid, 
                onChanged: (value) => setState(() => newPattern = newPattern.copyWith(pageLayout: newPattern.pageLayout.copyWith(showGrid: value == true))),
                title: const Text('Show grid'),
              ),
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          }, 
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: () {
            if (newPattern != widget.pattern) {
              Navigator.of(context).pop(newPattern);
            } else {
              Navigator.of(context).pop(null);
            }
          }, 
          child: const Text('Ok')
        )
      ],
    );
  }
}