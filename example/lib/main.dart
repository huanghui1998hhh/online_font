import 'package:flutter/material.dart';
import 'package:online_font/online_font.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: MyHomePage());
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PreloadExample()),
          ),
          child: Text(
            'Push to preload example',
            style: const YujiMai().textStyle(
              fontSize: 20,
              color: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}

class PreloadExample extends StatefulWidget {
  const PreloadExample({super.key});

  @override
  State<PreloadExample> createState() => _PreloadExampleState();
}

class _PreloadExampleState extends State<PreloadExample> {
  @override
  void initState() {
    super.initState();
    // call this, it will return a future, you can use it to show
    // a loading indicator or something else

    // you don't need to call something like `setState`, text will
    // auto refresh by `FontLoader`
    yujiMai.loadAll();
    // or
    // const YujiMai().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Pop back',
            style: TextStyle(fontFamily: 'YujiMai-Regular'),
            // style: TextStyle(
            //   fontFamily: const FontFamilyWithVariant(
            //     family: 'YujiMai',
            //     fontVariant: FontVariant(
            //       fontWeight: FontWeight.w400,
            //       fontStyle: FontStyle.normal,
            //     ),
            //   ).toString(),
            // ),
            // style: yujiMai.textStyle(),
            // style: const YujiMai().textStyle(),
          ),
        ),
      ),
    );
  }
}

final _fonts = {
  FontVariant.regular: const FontFile(
    url:
        'https://fonts.gstatic.com/s/a/d6741e6df72abe0287210735f84bb297fb8704e9e44ae1bd53e9366f75215ce8.ttf',
    expectedFileHash:
        'd6741e6df72abe0287210735f84bb297fb8704e9e44ae1bd53e9366f75215ce8',
    expectedLength: 7830152,
    extensionName: 'ttf',
  ),
};

// first way
class YujiMai extends OnlineFont {
  const YujiMai();

  @override
  String get fontFamily => 'YujiMai';

  @override
  Map<FontVariant, FontFile> get fonts => _fonts;
}

// second way
final yujiMai = RawOnlineFont(
  fontFamily: 'YujiMai',
  fonts: _fonts,
);
