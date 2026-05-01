
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/maingrid/pattern_page.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/pattern_info.dart';
import 'package:provider/provider.dart';

class PatternCard extends StatelessWidget {
  final PatternInfo patternInfo;

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
            Provider.of<KnittyGriddyModel>(context, listen: false).deletePattern(patternInfo.id);
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
          await Provider.of<KnittyGriddyModel>(context, listen: false).loadPattern(patternInfo.id);
          if (context.mounted) {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => const PatternPage(),
              )
            );
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