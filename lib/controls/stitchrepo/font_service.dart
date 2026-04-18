
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

    String icons = '';
    String iconNames = '';
    String symbolPaths = '';
    for (MapEntry<String, String> path in paths.entries) {
      icons += '\t\tstatic const KnittingSymbol ${path.key} = KnittingSymbol(name: \'${path.key}\', paths: [KnittingSymbolPaths.${path.key},]);\n';
      symbolPaths += '\t\tstatic const KnittingSymbolPath ${path.key} = KnittingSymbolPath(name: \'${path.key}\', path: \'${path.value}\');\n';
      iconNames += '${path.key},';
    }

    String knittingSymbolsOuput = '''
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_paths.dart';

class KnittingSymbols {
  
$icons

  static final List<KnittingSymbol> _icons = [
    $iconNames
  ];

  final KnittingSymbol _kBlank = const KnittingSymbol(name: 'blank', paths: []);

  KnittingSymbol getSymbol(String name) => _icons.firstWhere((i) => i.name == name, orElse: () => _kBlank);
}
    ''';

    String knittingSymbolPathsOutput = '''
import 'package:knitty_griddy/model/knitting_symbol_path.dart';

class KnittingSymbolPaths {

$symbolPaths

  static final List<KnittingSymbolPath> _paths = [
    $iconNames
  ];

  final KnittingSymbolPath _kBlankPath = const KnittingSymbolPath(name: 'blank', path: '');

  KnittingSymbolPath getSymbolPath(String name) => _paths.firstWhere((p) => p.name == name, orElse: () => _kBlankPath);
}
    ''';

  print('***********************************************************************************************');
  print(knittingSymbolPathsOutput);
  print('***********************************************************************************************');
  print(knittingSymbolsOuput);
  print('***********************************************************************************************');

/*
    List<ArchiveFile> outputFiles = [];
    for (MapEntry<String, String> path in paths.entries) {
      String outputSvg = '''<svg width="48" height="48" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
        <path d="${path.value}"/>
      </svg>''';
      Uint8List bytes = utf8.encode(outputSvg);
      outputFiles.add(ArchiveFile('${path.key}.svg', bytes.length, bytes));
    }

    String extensionContents = '';
    for (String characterId in paths.keys) {
      if (extensionContents.isNotEmpty) {
        extensionContents += ',';
      }
      extensionContents += 'Knitting.$characterId';
    }
    String extension = '''
import 'package:flutter/material.dart';
import 'package:knitty_griddy/knitting_icons.dart';

extension KnittingIconsExt on Knitting {
  static List<IconData> get icons => [
    $extensionContents
  ]; 
}
''';

    final Archive archive = Archive();
    outputFiles.forEach(archive.add);
    Uint8List extBytes = utf8.encode(extension);
    archive.add(ArchiveFile('knitting_icons_ext.dart', extBytes.length, extBytes));
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
*/
  }
}