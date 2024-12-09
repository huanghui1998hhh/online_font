# online_font

[![pub package](https://img.shields.io/pub/v/online_font.svg)](https://pub.dev/packages/online_font)

A package to allow you to use online fonts in your flutter app.

Inspired by [google_fonts](https://pub.dev/packages/google_fonts).

## Usage

Declare your font family like this:

```dart
class YujiMai extends OnlineFont {
  const YujiMai();

  @override
  String get fontFamily => 'YujiMai';

  @override
  Map<FontVariant, FontFile> get fonts => {
    FontVariant.regular: const FontFile(
      url: 'https://fonts.gstatic.com/s/a/d6741e6df72abe0287210735f84bb297fb8704e9e44ae1bd53e9366f75215ce8.ttf',
      // ---------------optional---------------
      expectedFileHash: 'd6741e6df72abe0287210735f84bb297fb8704e9e44ae1bd53e9366f75215ce8',
      expectedLength: 7830152,
      extensionName: 'ttf',
      // ---------------optional---------------
    ),
  };
}
```

or like this:

```dart
final yujiMai = RawOnlineFont(fontFamily: 'YujiMai', fonts: ...);
```

Use it like this:

```dart
Text('Hello, world', style: yujiMai.textStyle());
Text('Hello, world', style: const YujiMai().textStyle());
```

And you can preload it like this:

```dart
await yujiMai.loadAll();

// then use it like this
const Text('Hello, world', style: TextStyle(fontFamily: 'YujiMai-Regular'));
// If you don't matter the `const`, you can use the above written way
Text('Hello, world', style: yujiMai.textStyle());
Text('Hello, world', style: const YujiMai().textStyle());
```

Or you just want to preload one variant:

```dart
await yujiMai.loadVariant(FontVariant.regular);
```
