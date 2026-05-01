
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/pattern_chooser/pattern_chooser_page.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/storage/model_repository.dart';
import 'package:provider/provider.dart';

class KnittyGriddyApp extends StatelessWidget {

  final ModelRepository repository;

  const KnittyGriddyApp({
    required this.repository,  
    super.key
  });

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<KnittyGriddyModel>(
      create: (_) => KnittyGriddyModel(repository: repository)..loadOnStartup(),
      builder: (context, child) {
        final Timer _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), 
          (timer) async => await Provider.of<KnittyGriddyModel>(context, listen: false).autoSave()
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Knitty-Griddy',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade200),
            useMaterial3: true
          ),
          home: const PatternChooserPage(),
        );
      },
    );
  }
}