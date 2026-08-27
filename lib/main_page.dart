import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/charts/chart_chooser/chart_chooser_view.dart';
import 'package:knitty_griddy/drawings/drawing_chooser/drawing_chooser_view.dart';
import 'package:knitty_griddy/patterns/pattern_chooser/pattern_chooser_view.dart';
import 'package:knitty_griddy/utils/constants.dart';

enum Page {
  patterns(label: 'Patterns', icon: Icons.auto_awesome_mosaic_outlined),
  charts(label: 'Charts', icon: Icons.grid_on),
  drawings(label: 'Drawings', icon: Icons.design_services);

  final String label;
  final IconData icon;

  const Page({required this.label, required this.icon});
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  void initState() {
    super.initState();

    if (kIsWeb) BrowserContextMenu.disableContextMenu();
  }

  @override
  void dispose() {
    super.dispose();

    if (kIsWeb) BrowserContextMenu.enableContextMenu();
  }

  Page page = Page.charts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knitty-Griddy'),
        backgroundColor: Colors.grey.shade300,
      ),
      body: DefaultTabController(
        length: Page.values.length, 
        child: Column(
          children: [
            TabBar(
              tabs: [
                for (Page p in Page.values)
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(p.icon,), hspacing, Text(p.label)],
                    ),
                  )
              ]
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  PatternChooserView(),
                  ChartChooserView(),
                  DrawingChooserView(),    
                ]
              )
            )
          ],
        )
      ),
    );
  }
}