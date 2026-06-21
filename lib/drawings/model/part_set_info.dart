
import 'package:knitty_griddy/drawings/model/part_info.dart';

class PartSetInfo {
  final List<PartInfo> partInfos;
  final String setName;

  const PartSetInfo({
    required this.setName,
    required this.partInfos,
  });

  bool passesFilter(String filter) {
    return setName.toLowerCase().contains(filter.toLowerCase()) || partInfos.any((pi) => pi.passesFilter(filter));
  }
}