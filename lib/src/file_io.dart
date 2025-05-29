import 'dart:typed_data' show ByteData;

import '../online_font.dart';

bool get isMacOS => false;
bool get isAndroid => false;
bool get isTest => false;

/// By default, file IO is stubbed out.
///
/// If the path provider library is available (on mobile or desktop), then the
/// implementation in `file_io_desktop_and_mobile.dart` is used.

/// Stubbed out version of saveFontToDeviceFileSystem from
/// `file_io_desktop_and_mobile.dart`.
Future<void> saveFontToDeviceFileSystem({
  required String name,
  required List<int> bytes,
  required FontFile? fontFile,
}) {
  return Future.value();
}

/// Stubbed out version of loadFontFromDeviceFileSystem from
/// `file_io_desktop_and_mobile.dart`.
Future<ByteData?> loadFontFromDeviceFileSystem({
  required String name,
  required FontFile? fontFile,
}) {
  return Future.value();
}

Future<bool> checkFontFileExists({
  required String name,
  required FontFile? fontFile,
}) {
  return Future.value(false);
}
