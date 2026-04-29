import 'package:flutter/material.dart';
import 'package:knitty_griddy/export/export_settings.dart';

class ExportToolbar extends StatelessWidget {
  final double height;
  final ExportSettings exportSetting;
  final Function(ExportSettings newSettings) settingsChanged;

  final Function() exportToPNG;
  final Function() exportToSVG;

  const ExportToolbar({
    required this.height,
    required this.exportSetting,
    required this.settingsChanged,
    required this.exportToPNG,
    required this.exportToSVG,
    super.key}
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 20,),
          const Text('Legend'),
          Row(
            children: [
              const SizedBox(
                width: 120,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Stitches'),
                ),
              ),
              const SizedBox(width: 10,),
              Checkbox(
                value: exportSetting.showStitches, 
                onChanged: (bool? value) => settingsChanged(exportSetting.copyWith(showStitches: value == true))
              )
            ],
          ),
          const SizedBox(width: 20,),
          if (exportSetting.showStitches)
          Row(
            children: [
              const SizedBox(
                width: 120,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Descriptions'),
                ),
              ),
              const SizedBox(width: 10,),
              Checkbox(
                value: exportSetting.showStitchDescriptions, 
                onChanged: (bool? value) => settingsChanged(exportSetting.copyWith(showStitchDescriptions: value == true))
              )
            ],
          ),
          const SizedBox(width: 20,),
          Row(
            children: [
              const SizedBox(
                width: 120,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Colours'),
                ),
              ),
              const SizedBox(width: 10,),
              Checkbox(
                value: exportSetting.showColours, 
                onChanged: (bool? value) => settingsChanged(exportSetting.copyWith(showColours: value == true))
              )
            ],
          ),
          const SizedBox(width: 20,),
          if (exportSetting.showLegend)
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Position'),
                ),
              ),
              const SizedBox(width: 10,),
              DropdownButton<LegendPosition>(
                autofocus: false, 
                focusColor: Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                underline: Container(),
                padding: const EdgeInsets.only(left: 10, right: 5),
                items: const [
                  DropdownMenuItem(value: LegendPosition.left, child: Text('Left')),
                  DropdownMenuItem(value: LegendPosition.right, child: Text('Right')),
                  DropdownMenuItem(value: LegendPosition.top, child: Text('Top')),
                  DropdownMenuItem(value: LegendPosition.bottom, child: Text('Bottom')),
                ], 
                value: exportSetting.legendPosition,
                onChanged: (LegendPosition? position) { 
                  if (position != null) { 
                    settingsChanged(exportSetting.copyWith(legendPosition: position));
                  } 
                },
              )
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Export'),
                ),
              ),
              const SizedBox(width: 10,),
              OutlinedButton(
                onPressed: exportToPNG, 
                child: const Text('PNG'),
              ),
              const SizedBox(width: 10,),
              OutlinedButton(
                onPressed: exportToSVG, 
                child: const Text('SVG'),
              ),
            ],
          ),
          const SizedBox(width: 20,),
        ],
      ),
    );
  }
}