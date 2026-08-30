
import 'dart:async';

import 'package:fleather/l10n/fleather_localizations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/storage/drawings_model_repository.dart';
import 'package:knitty_griddy/main_page.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/charts/storage/charts_model_repository.dart';
import 'package:knitty_griddy/patterns/model/patterns_model.dart';
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
        ChangeNotifierProvider<PatternsModel>(
          create: (_) => PatternsModel(repository: patternsRepository)..loadOnStartup(),
        ),
      ], 
      builder: (context, child) {
        // Make sure the loadOnStartup of the chart model is called so the basic stitchset becomes available
        Provider.of<ChartsModel>(context, listen: false);

        Timer.periodic(const Duration(seconds: 20), 
          (timer) async {
            if (context.mounted) {
              await Provider.of<ChartsModel>(context, listen: false).autoSave();
            }
            if (context.mounted) {
              await Provider.of<DrawingsModel>(context, listen: false).autoSave();
            }
            if (context.mounted) {
              await Provider.of<PatternsModel>(context, listen: false).autoSave();
            }
          }
        );

        return Portal(
          child: MaterialApp(
            localizationsDelegates: const [
              FleatherLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            supportedLocales: FleatherLocalizations.supportedLocales,
            debugShowCheckedModeBanner: false,
            title: 'Knitty-Griddy',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade200),
              useMaterial3: true
            ),
            home: const MainPage(),
          ),
        );
      },
    );
  }
}