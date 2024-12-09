import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' hide AssetManifest;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:online_font/online_font.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHttpClient extends Mock implements http.Client {
  Future<http.Response> gets(dynamic uri, {dynamic headers}) {
    super.noSuchMethod(Invocation.method(#get, [uri], {#headers: headers}));
    return Future.value(http.Response('', 200));
  }
}

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  FakePathProviderPlatform(this._applicationSupportPath);

  final String _applicationSupportPath;

  @override
  Future<String?> getApplicationSupportPath() async {
    return _applicationSupportPath;
  }
}

const _fakeResponse = 'fake response body - success';
const _fakeResponseFile = FontFile(url: '');

// =============================== WARNING! ====================================
// Do not add tests to this test file. Because the set up mocks a system message
// handler (flutter/assets), that can not be undone, no other tests should be
// written in this file.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late MockHttpClient mockHttpClient;

  setUp(() async {
    mockHttpClient = MockHttpClient();
    httpClient = mockHttpClient;
    when(mockHttpClient.gets(any)).thenAnswer((_) async {
      return http.Response(_fakeResponse, 200);
    });

    // Add Foo-BlackItalic to mock asset bundle.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) {
      final Uint8List encoded =
          utf8.encoder.convert('{"google_fonts/Foo-BlackItalic.ttf":'
              '["google_fonts/Foo-BlackItalic.ttf"]}');
      return Future.value(encoded.buffer.asByteData());
    });

    directory = await Directory.systemTemp.createTemp();
    PathProviderPlatform.instance = FakePathProviderPlatform(directory.path);
  });

  tearDown(() {});

  test(
      'loadFontIfNecessary method does nothing if the font is in the '
      'Asset Manifest', () async {
    const familyWithVariantInAssets = FontFamilyWithVariant(
      family: 'Foo',
      fontVariant: FontVariant.blackItalic,
    );

    // Call loadFontIfNecessary and verify no http request happens because
    // Foo-BlackItalic is in the asset bundle.
    await loadFontIfNecessary(familyWithVariantInAssets, _fakeResponseFile);
    verifyNever(mockHttpClient.gets(anything));

    const familyWithVariantNotInAssets = FontFamilyWithVariant(
      family: 'Bar',
      fontVariant: FontVariant.boldItalic,
    );

    // Call loadFontIfNecessary and verify that an http request happens because
    // Bar-BoldItalic is not in the asset bundle.
    await loadFontIfNecessary(familyWithVariantNotInAssets, _fakeResponseFile);
    verify(mockHttpClient.gets(anything)).called(1);
  });
}
