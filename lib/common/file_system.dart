import 'dart:typed_data';

//import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:knitty_griddy/utils/app_platform_ext.dart';

class FileSystem {

  static Future<void> saveFile({String prompt = '', String filename = '', required Uint8List bytes}) async {
    final FileSaveLocation? result = await getSaveLocation(
      suggestedName: filename,
    );
    if (result == null) {
      // Operation was canceled by the user.
      return;
    }

    const String mimeType = 'text/plain';
    final XFile xFile = XFile.fromData(
      bytes,
      mimeType: mimeType,
      name: filename,
    );
    await xFile.saveTo(result.path);

/*
    await FilePicker.platform.saveFile(
      dialogTitle: prompt,
      fileName: filename,
      bytes: bytes
    );
*/
  }

  static Future<PickFileResult> pickFile({String prompt = '', List<String>? extensions}) async {

     XTypeGroup typeGroup = XTypeGroup(
      label: prompt,
      extensions: extensions,
//      uniformTypeIdentifiers: <String>['public.jpeg', 'public.png'],
    );
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );

    if (file == null) {
      return const PickFileResult(
        data: null, 
        filename: '', 
        resultType: PickFileResultType.abandonded);
    }

    // Difference with FilePicker: can't check the extension here?

    Uint8List data = await file.readAsBytes();

    return PickFileResult(
      data: data, 
      filename: file.name, 
      resultType: PickFileResultType.success);

/*
    FilePickerResult? result;
    if (AppPlatformExt.isWeb) {
      result = await FilePicker.platform.pickFiles(
        dialogTitle: prompt,
        allowMultiple: false,
        withData: true,
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        dialogTitle: prompt,
        allowMultiple: false,
        allowedExtensions: extensions,
        withData: true,
      );
    }

    if (result == null || result.files.isEmpty) {
      return const PickFileResult(
        data: null, 
        filename: '', 
        resultType: PickFileResultType.abandonded);
    }

    if (extensions != null && !extensions.contains(result.files.first.extension)) {
      return PickFileResult(
        data: null,
        filename: result.files.first.name,
        resultType: PickFileResultType.incorrectExtension);
    }

    return PickFileResult(
      data: result.files.first.bytes, 
      filename: result.files.first.name, 
      resultType: PickFileResultType.success);
*/
  }
}

enum PickFileResultType {
  success,
  incorrectExtension,
  abandonded,
}

class PickFileResult {
  final Uint8List? data;
  final String filename;
//  final String? extension;
  final PickFileResultType resultType;

  const PickFileResult({
    required this.data, 
    required this.filename,
//    required this.extension,
    required this.resultType,
  });
}