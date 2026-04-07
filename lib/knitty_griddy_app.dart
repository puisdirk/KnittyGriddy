
import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/pages/pattern_page.dart';
import 'package:provider/provider.dart';

class KnittyGriddyApp extends StatelessWidget {
  // TODO: should get a repository as argument
  const KnittyGriddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<KnittyGriddyModel>(
      create: (_) => KnittyGriddyModel(),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Knitty-Griddy',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade200),
            useMaterial3: true
          ),
          home: const PatternPage(),
        );
      },
    );
  }
}