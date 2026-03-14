
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

class FontService {
  static Future<void> parseFont() async {

    FilePickerResult? res = await FilePicker.platform.pickFiles(
      dialogTitle: 'Please select the input svg files',
      type: FileType.custom,
      allowedExtensions: ['svg']
    );

    if (res == null || res.files.isEmpty) {
      return;
    }

    Map<String, String> paths = {};
    for (PlatformFile file in res.files) {
      String c = utf8.decode(file.bytes!);
      final XmlDocument doc = XmlDocument.parse(c);
      for (XmlNode node in doc.xpath('//path[@data-px-label]')) {
        String? pathString = node.getAttribute('d');
        String? characterId = node.getAttribute('data-px-label');
        if (pathString != null && characterId != null) {
          if (paths.containsKey(characterId)) {
            print('warning: duplicate characted id found: \'$characterId\'');
          }
          paths[characterId] = pathString;
        }
      }
    }

    List<ArchiveFile> outputFiles = [];
    for (MapEntry<String, String> path in paths.entries) {
      String outputSvg = '''<svg width="48" height="48" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
        <path d="${path.value}"/>
      </svg>''';
      Uint8List bytes = utf8.encode(outputSvg);
      outputFiles.add(ArchiveFile('${path.key}.svg', bytes.length, bytes));
    }

    final Archive archive = Archive();
    outputFiles.forEach(archive.add);
    final ZipEncoder encoder = ZipEncoder();
    List<int> zipfile = encoder.encode(archive);

    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Where do you want to store the output?',
      fileName: 'knittingfont.zip',
      bytes: Uint8List.fromList(zipfile),
    );
    if (outputPath == null) {
      return;
    }

  }
}