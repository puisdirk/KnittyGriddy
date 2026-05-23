
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/maingrid/chart_page.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:provider/provider.dart';

class ChartCard extends StatelessWidget {
  final ChartInfo chartInfo;

  const ChartCard({
    required this.chartInfo,
    super.key
  });

  _confirmToDelete(BuildContext context) {
    AlertDialog dlg = AlertDialog(
      title: const Text('Are you sure'),
      content: Text('Are you sure you want to delete chart ${chartInfo.name}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Provider.of<ChartsModel>(context, listen: false).deleteChart(chartInfo.id);
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
          await Provider.of<ChartsModel>(context, listen: false).loadChart(chartInfo.id);
          if (context.mounted) {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => const ChartPage(),
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
                title: Text(chartInfo.name),
                subtitle: Text(
                  chartInfo.description,
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