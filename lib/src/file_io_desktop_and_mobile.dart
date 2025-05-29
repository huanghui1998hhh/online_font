import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../online_font.dart';

bool get isMacOS => Platform.isMacOS;
bool get isAndroid => Platform.isAndroid;
bool get isTest => Platform.environment.containsKey('FLUTTER_TEST');

Future<void> saveFontToDeviceFileSystem({
  required String name,
  required List<int> bytes,
  required FontFile? fontFile,
}) async {
  final file = await _localFile(name, fontFile);
  await file.writeAsBytes(bytes);
}

Future<ByteData?> loadFontFromDeviceFileSystem({
  required String name,
  required FontFile? fontFile,
}) async {
  try {
    final file = await _localFile(name, fontFile);
    final fileExists = file.existsSync();
    if (fileExists) {
      final List<int> contents = await file.readAsBytes();
      if (contents.isNotEmpty) {
        return ByteData.view(Uint8List.fromList(contents).buffer);
      }
    }
  } catch (e) {
    return null;
  }
  return null;
}

Future<bool> checkFontFileExists({
  required String name,
  required FontFile? fontFile,
}) async {
  final file = await _localFile(name, fontFile);
  return file.existsSync();
}

Future<String> get _localPath async {
  final directory = await getApplicationSupportDirectory();
  return directory.path;
}

Future<File> _localFile(String name, FontFile? fontFile) async {
  final path = await _localPath;
  final fileHash = fontFile?.expectedFileHash;
  final String modifiedFileHash = fileHash == null ? '' : '-$fileHash';
  final extensionName = fontFile?.extensionName;
  final String modifiedExtensionName =
      extensionName == null ? '' : '.$extensionName';
  return File('$path/$name$modifiedFileHash$modifiedExtensionName');
}
