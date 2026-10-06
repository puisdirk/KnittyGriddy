import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class ChartPicker extends StatefulWidget {
  const ChartPicker({super.key});

  @override
  State<ChartPicker> createState() => _ChartPickerState();
}

class _ChartPickerState extends State<ChartPicker> {
  late ChartInfo? selectedChartInfo;

  String _filterText = '';
  late TextEditingController _filterController;

  void _filterChanged() {
    setState(() => _filterText = _filterController.text);
  }

  @override
  void initState() {
    _filterController = TextEditingController(text: _filterText);
    _filterController.addListener(_filterChanged);

    selectedChartInfo = ChartInfo.emptyChartInfo;

    super.initState();
  }

  @override
  void dispose() {
    _filterController.removeListener(_filterChanged);
    _filterController.dispose();

    super.dispose();
  }

  Widget _chartInfoCard(ChartInfo chartInfo) {
    return SizedBox(
      width: 300,
      height: 110,
      child: Card(
        color: chartInfo == selectedChartInfo ? Colors.blue.withAlpha(60) : null,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          splashColor: Colors.blue.withAlpha(30),
          onTap: () => setState(() => selectedChartInfo = chartInfo),
          onDoubleTap: () => Navigator.of(context).pop(chartInfo),
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (chartInfo.hasPreview)
                  SizedBox(
                    width: ChartInfo.previewImageWidth,
                    height: ChartInfo.previewImageHeight,
                    child: Image(
                      width: ChartInfo.previewImageWidth, 
                      height: ChartInfo.previewImageHeight, 
                      image: MemoryImage(chartInfo.previewImage!)
                    )
                  ),
                if (chartInfo.hasPreview)
                  hspacing,
                Column(
                  children: [
                    Text(chartInfo.name, textAlign: TextAlign.center,),
                    Text(
                      style: smallStyle,
                      chartInfo.description,
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
          if (selectedChartInfo == null || selectedChartInfo == ChartInfo.emptyChartInfo) {
            Navigator.of(context).pop(null);
          } else {
            Navigator.of(context).pop(selectedChartInfo);
          }
        }
      },
      child: AlertDialog(
        title: const Text('Select chart'),
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
                child: Selector<ChartsModel, List<ChartInfo>>(
                  selector: (_, model) => model.filteredChartInfos(_filterText),
                  builder: (context, chartInfos, _) {
                    return Wrap(
                      children: [
                        for (ChartInfo chartInfo in chartInfos)
                          _chartInfoCard(chartInfo),
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
            onPressed: selectedChartInfo == null || selectedChartInfo == ChartInfo.emptyChartInfo ? null : 
              () => Navigator.of(context).pop(selectedChartInfo), 
            child: const Text('Choose'),
          )
        ],
      ),
    );
  }
}