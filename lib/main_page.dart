import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/chart_chooser/chart_chooser_view.dart';
import 'package:knitty_griddy/drawings/drawing_chooser_view.dart';
import 'package:knitty_griddy/patterns/pattern_chooser_view.dart';

enum Page {
  patterns(label: 'Patterns'),
  charts(label: 'Charts'),
  drawings(label: 'Drawings');

  final String label;

  const Page({required this.label});
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
                  Tab(text: p.label,)
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