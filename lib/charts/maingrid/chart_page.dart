
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/charts/maingrid/chart_settings_dialog.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/toolbar/knitting_toolbar.dart';
import 'package:knitty_griddy/charts/maingrid/chart_control.dart';
import 'package:knitty_griddy/charts/export/export_page.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class ChartPage extends StatefulWidget {

  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late FocusNode _focusNode;
  bool isGridSettingsMenuOpen = false;

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).autofocus(_focusNode);
    String chartname = Provider.of<ChartsModel>(context, listen: false).knittingChart.name;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Provider.of<ChartsModel>(context, listen: false).saveCurrentChart();
            Provider.of<ChartsModel>(context, listen: false).clearUndoRedo();
            Navigator.maybePop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Icon(Icons.grid_on), hspacing, Text('Chart - $chartname')]
        ),
        backgroundColor: Colors.grey.shade300,
        bottom: const PreferredSize(
          preferredSize: Size(20000, 200), 
          child: KnittingToolbar(),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              KnittingChart? newKnittingChart = await showDialog(
                context: context, 
                builder: (context) => ChartSettingsDialog(knittingChart: Provider.of<ChartsModel>(context, listen: false).knittingChart),
              );

              if (newKnittingChart != null) {
                if (context.mounted) {
                  Provider.of<ChartsModel>(context, listen: false).updateChart(newKnittingChart);
                }
              }
            }, 
            icon: const Icon(Icons.settings)
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ExportPage())
            ),
          )
        ],
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (value) {
          if (value is KeyDownEvent && value.logicalKey == LogicalKeyboardKey.keyZ && 
            (HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed)) {
            if (HardwareKeyboard.instance.isShiftPressed) {
              Provider.of<ChartsModel>(context, listen: false).redo();
            } else {
              Provider.of<ChartsModel>(context, listen: false).undo();
            }
          }
        },
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ChartControl(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

