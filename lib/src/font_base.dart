import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
// TODO(andrewkolos): The flutter framework wishes to add a new class named
// `AssetManifest` to its API (see https://github.com/flutter/flutter/pull/119277).
// However, doing so would break integration tests that utilize google_fonts due
// to name collision with the `AssetManifest` class that this package already
// defines (see https://github.com/flutter/flutter/pull/119273).
// Once the AssetManifest API is added to flutter, update this package to use it
// instead of the AssetManifest class this package defines and remove this `hide`
// and the ignore annotation.
// ignore: undefined_hidden_name
import 'package:flutter/services.dart' hide AssetManifest;
import 'package:http/http.dart' as http;

import '../online_font.dart';
import 'asset_manifest.dart';
import 'file_io.dart' // Stubbed implementation by default.
    // Concrete implementation if File IO is available.
    if (dart.library.io) 'file_io_desktop_and_mobile.dart' as file_io;
import 'font_family_with_variant.dart';

@visibleForTesting
http.Client httpClient = http.Client();

@visibleForTesting
AssetManifest assetManifest = AssetManifest();

/// Loads a font into the [FontLoader] with [fontFamilyName] for the
/// matching [expectedFileHash].
///
/// If a font with the [fontName] has already been loaded into memory, then
/// this method does nothing as there is no need to load it a second time.
///
/// Otherwise, this method will first check to see if the font is available
/// as an asset, then on the device file system. If it isn't, it is fetched via
/// the [fontUrl] and stored on device. In all cases, the returned future
/// completes once the font is loaded into the [FontLoader].
Future<void> loadFontIfNecessary(
  FontFamilyWithVariant familyWithVariant,
  FontFile file,
) async {
  final fontName = familyWithVariant.toString();
  // If this font has already already loaded or is loading, then there is no
  // need to attempt to load it again, unless the attempted load results in an
  // error.
  if (OnlineFont.loadedFonts.contains(familyWithVariant)) {
    return;
  } else {
    OnlineFont.loadedFonts.add(familyWithVariant);
  }

  try {
    Future<ByteData?>? byteData;

    // Check if this font can be loaded by the pre-bundled assets.
    final assetManifestJson = await assetManifest.json();
    final assetPath = _findFamilyWithVariantAssetPath(
      familyWithVariant,
      assetManifestJson,
    );
    if (assetPath != null) {
      byteData = rootBundle.load(assetPath);
    }
    if (await byteData != null) {
      return loadFontByteData(fontName, byteData);
    }

    // Check if this font can be loaded from the device file system.
    byteData = file_io.loadFontFromDeviceFileSystem(
      name: fontName,
    );

    if (await byteData != null) {
      return loadFontByteData(fontName, byteData);
    }

    byteData = _httpFetchFontAndSaveToDevice(fontName, file);
    if (await byteData != null) {
      return loadFontByteData(fontName, byteData);
    }
  } catch (e) {
    OnlineFont.loadedFonts.remove(familyWithVariant);
    log('Error: google_fonts was unable to load font $fontName because the '
        'following exception occurred:\n$e');
    if (file_io.isTest) {
      log('\nThere is likely something wrong with your test. Please see '
          'https://github.com/material-foundation/flutter-packages/blob/main/packages/google_fonts/example/test '
          'for examples of how to test with google_fonts.');
    } else if (file_io.isMacOS || file_io.isAndroid) {
      log(
        '\nSee https://docs.flutter.dev/development/data-and-backend/networking#platform-notes.',
      );
    }
    log("If troubleshooting doesn't solve the problem, please file an issue "
        'at https://github.com/material-foundation/flutter-packages/issues/new/choose.\n');
    rethrow;
  }
}

/// Loads a font with [FontLoader], given its name and byte-representation.
@visibleForTesting
Future<void> loadFontByteData(
  String fontName,
  Future<ByteData?>? byteData,
) async {
  if (byteData == null) return;
  final fontData = await byteData;
  if (fontData == null) return;

  final fontLoader = FontLoader(fontName);
  fontLoader.addFont(Future.value(fontData));
  await fontLoader.load();
}

/// Fetches a font with [fontName] from the [fontUrl] and saves it locally if
/// it is the first time it is being loaded.
///
/// This function can return `null` if the font fails to load from the URL.
Future<ByteData> _httpFetchFontAndSaveToDevice(
  String fontName,
  FontFile file,
) async {
  final uri = Uri.tryParse(file.url);
  if (uri == null) {
    throw Exception('Invalid fontUrl: ${file.url}');
  }

  http.Response response;
  try {
    response = await httpClient.get(uri);
  } catch (e) {
    throw Exception('Failed to load font with url ${file.url}: $e');
  }
  if (response.statusCode == 200) {
    if (!_isFileSecure(file, response.bodyBytes)) {
      throw Exception(
        'File from ${file.url} did not match expected length and checksum.',
      );
    }

    _unawaited(
      file_io.saveFontToDeviceFileSystem(
        name: fontName,
        bytes: response.bodyBytes,
      ),
    );

    return ByteData.view(response.bodyBytes.buffer);
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load font with url: ${file.url}');
  }
}

/// Looks for a matching [familyWithVariant] font, provided the asset manifest.
/// Returns the path of the font asset if found, otherwise an empty string.
String? _findFamilyWithVariantAssetPath(
  FontFamilyWithVariant familyWithVariant,
  Map<String, List<String>>? manifestJson,
) {
  if (manifestJson == null) return null;

  final fontName = familyWithVariant.toString();

  for (final assetList in manifestJson.values) {
    for (final String asset in assetList) {
      for (final matchingSuffix in ['.ttf', '.otf'].where(asset.endsWith)) {
        final assetWithoutExtension =
            asset.substring(0, asset.length - matchingSuffix.length);
        if (assetWithoutExtension.endsWith(fontName)) {
          return asset;
        }
      }
    }
  }

  return null;
}

bool _isFileSecure(FontFile file, Uint8List bytes) {
  if (file.expectedLength != null) {
    final actualFileLength = bytes.length;
    if (file.expectedLength != actualFileLength) {
      return false;
    }
  }

  if (file.expectedFileHash != null) {
    final actualFileHash = sha256.convert(bytes).toString();
    if (file.expectedFileHash != actualFileHash) {
      return false;
    }
  }

  return true;
}

void _unawaited(Future<void> future) {}
