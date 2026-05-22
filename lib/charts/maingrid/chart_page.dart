
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/charts/editgrid/grid_settings_control.dart';
import 'package:knitty_griddy/charts/toolbar/knitting_toolbar.dart';
import 'package:knitty_griddy/charts/maingrid/chart_control.dart';
import 'package:knitty_griddy/charts/export/export_page.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
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
    String chartname = Provider.of<KnittyGriddyModel>(context, listen: false).knittingChart.name;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Provider.of<KnittyGriddyModel>(context, listen: false).saveCurrentChart();
            Navigator.maybePop(context);
          },
        ),
        title: Text('Chart - $chartname'),
        backgroundColor: Colors.grey.shade300,
        bottom: const PreferredSize(
          preferredSize: Size(20000, 200), 
          child: KnittingToolbar(),
        ),
        actions: [
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
              Provider.of<KnittyGriddyModel>(context, listen: false).redo();
            } else {
              Provider.of<KnittyGriddyModel>(context, listen: false).undo();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridSettingsControl(),
                    SizedBox(height: 10,),
                    ChartControl(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

