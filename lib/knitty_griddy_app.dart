
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/storage/drawings_model_repository.dart';
import 'package:knitty_griddy/main_page.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/charts/storage/charts_model_repository.dart';
import 'package:knitty_griddy/patterns/storage/patterns_model_repository.dart';
import 'package:provider/provider.dart';

class KnittyGriddyApp extends StatelessWidget {

  final ChartsModelRepository chartsRepository;
  final DrawingsModelRepository drawingsRepository;
  final PatternsModelRepository patternsRepository;


  const KnittyGriddyApp({
    required this.chartsRepository,  
    required this.drawingsRepository,
    required this.patternsRepository,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChartsModel>(
          create: (_) => ChartsModel(repository: chartsRepository)..loadOnStartup(),
        ),
        ChangeNotifierProvider<DrawingsModel>(
          create: (_) => DrawingsModel(repository: drawingsRepository)..loadOnStartup(), 
        ),
//        ChangeNotifierProvider<PatternsModel>(
//          create: (_) => PatternsModel(repository: patternsRepository)..loadOnStartup(),
//        ),
      ], 
      builder: (context, child) {
        Timer.periodic(const Duration(seconds: 20), 
          (timer) async {
            if (context.mounted) {
              await Provider.of<ChartsModel>(context, listen: false).autoSave();
            }
            if (context.mounted) {
              await Provider.of<DrawingsModel>(context, listen: false).autoSave();
            }
          }
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Knitty-Griddy',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade200),
            useMaterial3: true
          ),
          home: const MainPage(),
        );
      },
    );
  }
}