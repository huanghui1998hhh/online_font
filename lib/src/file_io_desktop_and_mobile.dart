import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

bool get isMacOS => Platform.isMacOS;
bool get isAndroid => Platform.isAndroid;
bool get isTest => Platform.environment.containsKey('FLUTTER_TEST');

Future<void> saveFontToDeviceFileSystem({
  required String name,
  required List<int> bytes,
}) async {
  final file = await _localFile(name);
  await file.writeAsBytes(bytes);
}

Future<ByteData?> loadFontFromDeviceFileSystem({
  required String name,
}) async {
  try {
    final file = await _localFile(name);
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

Future<String> get _localPath async {
  final directory = await getApplicationSupportDirectory();
  return directory.path;
}

/// [name] should be contains the extension of the file.
Future<File> _localFile(String name) async {
  final path = await _localPath;
  return File('$path/$name');
}
