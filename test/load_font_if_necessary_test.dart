import 'dart:async';
import 'dart:io';

// ignore: undefined_hidden_name
import 'package:flutter/services.dart' hide AssetManifest;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:online_font/online_font.dart';
import 'package:online_font/src/asset_manifest.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHttpClient extends Mock implements http.Client {
  Future<http.Response> gets(dynamic uri, {dynamic headers}) {
    super.noSuchMethod(Invocation.method(#get, [uri], {#headers: headers}));
    return Future.value(http.Response('', 200));
  }
}

class MockAssetManifest extends Mock implements AssetManifest {}

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
// The number of bytes in _fakeResponse.
const _fakeResponseLengthInBytes = 28;
// Computed by converting _fakeResponse to bytes and getting sha 256 hash.
const _fakeResponseHash =
    '1194f6ffe4d2f05258573616a77932c38041f3102763096c19437c3db1818a04';
const expectedCachedFile = 'Foo-Regular-$_fakeResponseHash';
// ignore: unused_element
const _fakeResponseDifferent = 'different response';
// The number of bytes in _fakeResponseDifferent.
const _fakeResponseDifferentLengthInBytes = 18;
// Computed by converting _fakeResponseDifferent to bytes and getting sha 256 hash.
const _fakeResponseDifferentHash =
    '2a989d235f2408511069bc7d8460c62aec1a75ac399bd7f2a2ae740c4326dadf';
const expectedDifferentCachedFile = 'Foo-Regular-$_fakeResponseDifferentHash';

const _fakeResponseFile = FontFile(
  url: '',
  expectedFileHash: _fakeResponseHash,
  expectedLength: _fakeResponseLengthInBytes,
);
const _fakeResponseDifferentFile = FontFile(
  url: '',
  expectedFileHash: _fakeResponseDifferentHash,
  expectedLength: _fakeResponseDifferentLengthInBytes,
);

const fakeFontFamilyWithVariant = FontFamilyWithVariant(
  family: 'Foo',
  fontVariant: FontVariant.regular,
);

var printLog = <String>[];

void overridePrint(Future<void> Function() testFn) => () {
      final spec = ZoneSpecification(
        print: (_, __, ___, msg) {
          // Add to log instead of printing to stdout
          printLog.add(msg);
        },
      );
      return Zone.current.fork(specification: spec).run(testFn);
    };

void main() {
  late Directory directory;
  late MockHttpClient mockHttpClient;

  setUp(() async {
    mockHttpClient = MockHttpClient();
    httpClient = mockHttpClient;
    assetManifest = MockAssetManifest();
    when(mockHttpClient.gets(any)).thenAnswer((_) async {
      return http.Response(_fakeResponse, 200);
    });

    directory = await Directory.systemTemp.createTemp();
    PathProviderPlatform.instance = FakePathProviderPlatform(directory.path);
  });

  tearDown(() {
    printLog.clear();
    OnlineFont.clearCache();
  });

  test('loadFontIfNecessary method calls http get', () async {
    await loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile);

    verify(mockHttpClient.gets(anything)).called(1);
  });

  test('loadFontIfNecessary method throws if font cannot be loaded', () async {
    // Mock a bad response.
    when(mockHttpClient.gets(any)).thenAnswer((_) async {
      return http.Response('fake response body - failure', 300);
    });

    const fakeFontFamilyWithVariant = FontFamilyWithVariant(
      family: 'Foo',
      fontVariant: FontVariant.blackItalic,
    );

    // Call loadFontIfNecessary and verify that it prints an error.
    overridePrint(() async {
      await loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile);
      expect(printLog.length, 1);
      expect(
        printLog[0],
        startsWith('online_font was unable to load font Foo-BlackItalic'),
      );
    });
  });

  test(
      'loadFontIfNecessary method does not make http get request on '
      'subsequent calls', () async {
    const fakeFontFamilyWithVariant = FontFamilyWithVariant(
      family: 'Foo',
      fontVariant: FontVariant.regular,
    );

    // 1st call.
    await loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile);
    verify(mockHttpClient.gets(anything)).called(1);

    // 2nd call.
    await loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile);
    verifyNever(mockHttpClient.gets(anything));

    // 3rd call.
    await loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile);
    verifyNever(mockHttpClient.gets(anything));
  });

  test(
      'loadFontIfNecessary does not make more than 1 http get request on '
      'parallel calls', () async {
    const fakeFontFamilyWithVariant = FontFamilyWithVariant(
      family: 'Foo',
      fontVariant: FontVariant.regular,
    );

    await Future.wait([
      loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile),
      loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile),
      loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile),
    ]);
    verify(mockHttpClient.gets(anything)).called(1);
  });

  test('loadFontIfNecessary makes second attempt if the first attempt failed ',
      () async {
    const fakeFontFamilyWithVariant = FontFamilyWithVariant(
      family: 'Foo',
      fontVariant: FontVariant.regular,
    );

    // Have the first call throw an error.
    when(mockHttpClient.gets(any)).thenThrow('some error');
    await expectLater(
      loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile),
      throwsA(const TypeMatcher<Exception>()),
    );

    // The second call will retry the http fetch.
    when(mockHttpClient.gets(any)).thenAnswer((_) async {
      return http.Response(_fakeResponse, 200);
    });
    await loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile);
    verify(mockHttpClient.gets(any)).called(2);
  });

  test('loadFontIfNecessary method correctly stores in cache', () async {
    var directoryContents = await getApplicationSupportDirectory();
    expect(directoryContents.listSync().isEmpty, isTrue);

    await loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile);
    // Give enough time for the file to be saved
    await Future.delayed(const Duration(seconds: 1), () {});
    directoryContents = await getApplicationSupportDirectory();

    expect(directoryContents.listSync().isNotEmpty, isTrue);

    expect(
      directoryContents.listSync().single.toString(),
      contains(expectedCachedFile),
    );
  });

  test('loadFontIfNecessary method correctly uses cache', () async {
    final directoryContents = await getApplicationSupportDirectory();
    expect(directoryContents.listSync().isEmpty, isTrue);

    final cachedFile = File(
      '${directoryContents.path}/$expectedCachedFile',
    );
    cachedFile.createSync();
    cachedFile.writeAsStringSync('file contents');

    // Should use cache from now on.
    await loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile);
    await loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile);
    await loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile);
    verifyNever(mockHttpClient.gets(anything));
  });

  test('loadFontIfNecessary method re-caches when font file changes', () async {
    when(mockHttpClient.gets(any)).thenAnswer((_) async {
      return http.Response(_fakeResponseDifferent, 200);
    });

    final directoryContents = await getApplicationSupportDirectory();
    expect(directoryContents.listSync().isEmpty, isTrue);

    final cachedFile = File(
      '${directoryContents.path}/$expectedCachedFile',
    );
    cachedFile.createSync();
    cachedFile.writeAsStringSync('file contents');

    // What if the file is different (e.g. the font has been improved)?
    await loadFontIfNecessary(
      fakeFontFamilyWithVariant,
      _fakeResponseDifferentFile,
    );
    verify(mockHttpClient.gets(any)).called(1);

    // Give enough time for the file to be saved
    await Future.delayed(const Duration(seconds: 1), () {});
    expect(directoryContents.listSync().length == 2, isTrue);
    expect(
      directoryContents.listSync().toString(),
      contains(expectedDifferentCachedFile),
    );

    // Should use cache from now on.
    await loadFontIfNecessary(
      fakeFontFamilyWithVariant,
      _fakeResponseDifferentFile,
    );
    await loadFontIfNecessary(
      fakeFontFamilyWithVariant,
      _fakeResponseDifferentFile,
    );
    await loadFontIfNecessary(
      fakeFontFamilyWithVariant,
      _fakeResponseDifferentFile,
    );
    verifyNever(mockHttpClient.gets(anything));
  });

  test(
      'loadFontIfNecessary does not save anything to disk if the file does not '
      'match the expected hash', () async {
    when(mockHttpClient.gets(any)).thenAnswer((_) async {
      return http.Response('malicious intercepted response', 200);
    });
    const fakeFontFamilyWithVariant = FontFamilyWithVariant(
      family: 'Foo',
      fontVariant: FontVariant.regular,
    );

    var directoryContents = await getApplicationSupportDirectory();
    expect(directoryContents.listSync().isEmpty, isTrue);

    overridePrint(() async {
      await loadFontIfNecessary(fakeFontFamilyWithVariant, _fakeResponseFile);
      expect(printLog.length, 1);
      expect(
        printLog[0],
        startsWith('online_font was unable to load font Foo-BlackItalic'),
      );
      directoryContents = await getApplicationSupportDirectory();
      expect(directoryContents.listSync().isEmpty, isTrue);
    });
  });

  test("loadFontByteData doesn't fail", () {
    expect(
      () async => loadFontByteData('fontFamily', Future.value(ByteData(0))),
      returnsNormally,
    );
    expect(
      () async => loadFontByteData('fontFamily', Future.value()),
      returnsNormally,
    );
    expect(
      () async => loadFontByteData('fontFamily', null),
      returnsNormally,
    );

    expect(
      () async => loadFontByteData(
        'fontFamily',
        Future.delayed(const Duration(milliseconds: 100), () => null),
      ),
      returnsNormally,
    );
  });
}
