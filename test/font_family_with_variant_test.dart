import 'package:flutter_test/flutter_test.dart';
import 'package:online_font/online_font.dart';

void main() {
  testWidgets('toString() works for italic w100', (tester) async {
    const familyWithVariant = FontFamilyWithVariant(
      family: 'Foo',
      fontVariant: FontVariant.thinItalic,
    );

    expect(familyWithVariant.toString(), equals('Foo-ThinItalic'));
  });

  testWidgets('toString() works for regular', (tester) async {
    const familyWithVariant = FontFamilyWithVariant(
      family: 'Foo',
      fontVariant: FontVariant.regular,
    );

    expect(familyWithVariant.toString(), equals('Foo-Regular'));
  });
}
