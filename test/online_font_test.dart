// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:online_font/online_font.dart';
import 'package:online_font/src/asset_manifest.dart';

class MockHttpClient extends Mock implements http.Client {
  Future<http.Response> gets(dynamic uri, {dynamic headers}) {
    super.noSuchMethod(Invocation.method(#get, [uri], {#headers: headers}));
    return Future.value(http.Response('', 200));
  }
}

class MockAssetManifest extends Mock implements AssetManifest {}

const _fakeResponse = 'fake response body - success';
// The number of bytes in _fakeResponse.
const _fakeResponseLengthInBytes = 28;
// Computed by converting _fakeResponse to bytes and getting sha 256 hash.
const _fakeResponseHash =
    '1194f6ffe4d2f05258573616a77932c38041f3102763096c19437c3db1818a04';

const _fakeResponseFile = FontFile(
  url: '',
  expectedFileHash: _fakeResponseHash,
  expectedLength: _fakeResponseLengthInBytes,
);

final fakeFonts = <FontVariant, FontFile>{
  FontVariant.regular: _fakeResponseFile,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late MockHttpClient mockHttpClient;

  setUp(() async {
    mockHttpClient = MockHttpClient();
    httpClient = mockHttpClient;
    assetManifest = MockAssetManifest();
    when(mockHttpClient.gets(any)).thenAnswer((_) async {
      return http.Response(_fakeResponse, 200);
    });
  });

  tearDown(() {
    OnlineFont.clearCache();
  });

  test('pendingFonts waits for fonts to be loaded', () async {
    expect(await OnlineFont.allPendingFontFuture(), isEmpty);

    final textStyle1 = AB().textStyle();
    final textStyle2 = CD().textStyle();

    expect(await OnlineFont.allPendingFontFuture(), hasLength(2));
    expect(await OnlineFont.allPendingFontFuture(), hasLength(0));
  });
}

class AB extends OnlineFont {
  @override
  String get fontFamily => 'ab';

  @override
  Map<FontVariant, FontFile> get fonts => fakeFonts;
}

class CD extends OnlineFont {
  @override
  String get fontFamily => 'cd';

  @override
  Map<FontVariant, FontFile> get fonts => fakeFonts;
}
