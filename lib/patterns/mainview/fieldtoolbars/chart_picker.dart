import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
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
      height: 100,
      child: Card(
        color: chartInfo == selectedChartInfo ? Colors.blue.withAlpha(60) : null,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          splashColor: Colors.blue.withAlpha(30),
          onTap: () => setState(() => selectedChartInfo = chartInfo),
          onDoubleTap: () => Navigator.of(context).pop(chartInfo),
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            title: Text(chartInfo.name, overflow: TextOverflow.ellipsis,),
            subtitle: Text(
              chartInfo.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(null), 
          label: const Text('Cancel'),
          icon: const Icon(Icons.cancel_outlined),
        ),
        ElevatedButton.icon(
          onPressed: selectedChartInfo == null || selectedChartInfo == ChartInfo.emptyChartInfo ? null : 
            () => Navigator.of(context).pop(selectedChartInfo), 
          label: const Text('Choose'),
          icon: const Icon(Symbols.close_small, weight: 700,),
        )
      ],
    );
  }
}