
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:provider/provider.dart';

class SettingsToolbarPanel extends StatefulWidget {

  final KnittingChart chart;

  const SettingsToolbarPanel({
    required this.chart,
    super.key
  });

  @override
  State<SettingsToolbarPanel> createState() => _SettingsToolbarPanelState();
}

class _SettingsToolbarPanelState extends State<SettingsToolbarPanel> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  void _nameChanged() {
    Provider.of<ChartsModel>(context, listen: false).setChartName(nameController.text);
  }

  void _descriptionChanged() {
    Provider.of<ChartsModel>(context, listen: false).setChartDescription(descriptionController.text);
  }

  @override
  void initState() {
    nameController = TextEditingController(text: widget.chart.name);
    nameController.addListener(_nameChanged);

    descriptionController = TextEditingController(text: widget.chart.description);
    descriptionController.addListener(_descriptionChanged);

    super.initState();
  }

  @override
  void dispose() {
    nameController.removeListener(_nameChanged);
    nameController.dispose();

    descriptionController.removeListener(_descriptionChanged);
    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 10,),
              const Text('Name'),
              const SizedBox(width: 10,),
              SizedBox(width: 200,
              child: TextField(controller: nameController,),
              ),
            ],
          ),
          const SizedBox(width: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 10,),
              const Text('Description'),
              const SizedBox(width: 10,),
              SizedBox(width: 600,
                child: TextField(
                  controller: descriptionController,
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}