

import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/mainview/pattern_page.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern_info.dart';
import 'package:knitty_griddy/patterns/model/pattern_operation_exception.dart';
import 'package:knitty_griddy/patterns/model/patterns_model.dart';
import 'package:provider/provider.dart';

class PatternCard extends StatelessWidget {
  final KnittingPatternInfo patternInfo;

  const PatternCard({
    required this.patternInfo,
    super.key
  });

  _confirmToDelete(BuildContext context) {
    AlertDialog dlg = AlertDialog(
      title: const Text('Are you sure'),
      content: Text('Are you sure you want to delete pattern ${patternInfo.name}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Provider.of<PatternsModel>(context, listen: false).deletePattern(patternInfo.id);
          }, 
          child: const Text('Yes')
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => dlg);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () async {
          try {
            await Provider.of<PatternsModel>(context, listen: false).loadPattern(patternInfo.id);
            if (context.mounted) {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => PatternPage(knittingPattern: Provider.of<PatternsModel>(context, listen: false).pattern,),
                )
              );
            }
          } on PatternOperationException catch(e) {
            if (context.mounted) {
              showDialog(context: context, builder: (context) => 
                AlertDialog(
                  content: SizedBox(width: 400, height: 50, child: Text(e.message)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: const Text('Close'),
                    ),
                  ],
                )  
              );
            }
          }
        },
        child: SizedBox(
          width: 300,
          height: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                mouseCursor: SystemMouseCursors.click,
                trailing: IconButton(
                  onPressed: () => _confirmToDelete(context), 
                  icon: const Icon(Icons.delete)
                ),
                title: Text(patternInfo.name),
                subtitle: Text(
                  patternInfo.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}