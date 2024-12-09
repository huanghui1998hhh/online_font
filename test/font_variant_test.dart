// ignore_for_file: use_named_constants

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_font/online_font.dart';

void main() {
  testWidgets('toString() works for all normal combintaions', (tester) async {
    expect(FontVariant.thin.toString(), equals('Thin'));
    expect(FontVariant.extraLight.toString(), equals('ExtraLight'));
    expect(FontVariant.light.toString(), equals('Light'));
    expect(FontVariant.regular.toString(), equals('Regular'));
    expect(FontVariant.medium.toString(), equals('Medium'));
    expect(FontVariant.semiBold.toString(), equals('SemiBold'));
    expect(FontVariant.bold.toString(), equals('Bold'));
    expect(FontVariant.extraBold.toString(), equals('ExtraBold'));
    expect(FontVariant.black.toString(), equals('Black'));
  });

  testWidgets('toString() works for all italic combintaions', (tester) async {
    expect(FontVariant.thinItalic.toString(), equals('ThinItalic'));
    expect(FontVariant.extraLightItalic.toString(), equals('ExtraLightItalic'));
    expect(FontVariant.lightItalic.toString(), equals('LightItalic'));
    expect(FontVariant.italic.toString(), equals('Italic'));
    expect(FontVariant.mediumItalic.toString(), equals('MediumItalic'));
    expect(FontVariant.semiBoldItalic.toString(), equals('SemiBoldItalic'));
    expect(FontVariant.boldItalic.toString(), equals('BoldItalic'));
    expect(FontVariant.extraBoldItalic.toString(), equals('ExtraBoldItalic'));
    expect(FontVariant.blackItalic.toString(), equals('BlackItalic'));
  });

  testWidgets('fromString() works for all normal combintaions', (tester) async {
    expect(FontVariant.fromString('Thin'), equals(FontVariant.thin));
    expect(
      FontVariant.fromString('ExtraLight'),
      equals(FontVariant.extraLight),
    );
    expect(FontVariant.fromString('Light'), equals(FontVariant.light));
    expect(FontVariant.fromString('Regular'), equals(FontVariant.regular));
    expect(FontVariant.fromString('Medium'), equals(FontVariant.medium));
    expect(FontVariant.fromString('SemiBold'), equals(FontVariant.semiBold));
    expect(FontVariant.fromString('Bold'), equals(FontVariant.bold));
    expect(FontVariant.fromString('ExtraBold'), equals(FontVariant.extraBold));
    expect(FontVariant.fromString('Black'), equals(FontVariant.black));
  });

  testWidgets('fromString() works for all italic combintaions', (tester) async {
    expect(
      FontVariant.fromString('ThinItalic'),
      equals(FontVariant.thinItalic),
    );
    expect(
      FontVariant.fromString('ExtraLightItalic'),
      equals(FontVariant.extraLightItalic),
    );
    expect(
      FontVariant.fromString('LightItalic'),
      equals(FontVariant.lightItalic),
    );
    expect(FontVariant.fromString('Italic'), equals(FontVariant.italic));
    expect(
      FontVariant.fromString('MediumItalic'),
      equals(FontVariant.mediumItalic),
    );
    expect(
      FontVariant.fromString('SemiBoldItalic'),
      equals(FontVariant.semiBoldItalic),
    );
    expect(
      FontVariant.fromString('BoldItalic'),
      equals(FontVariant.boldItalic),
    );
    expect(
      FontVariant.fromString('ExtraBoldItalic'),
      equals(FontVariant.extraBoldItalic),
    );
    expect(
      FontVariant.fromString('BlackItalic'),
      equals(FontVariant.blackItalic),
    );
  });

  testWidgets('== works for for identical variants', (tester) async {
    const variant = FontVariant(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
    );
    const otherVariant = variant;

    expect(variant == otherVariant, isTrue);
  });

  testWidgets('== works for for clone variants', (tester) async {
    const variant = FontVariant(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
    );
    const otherVariant = FontVariant(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
    );
    expect(variant == otherVariant, isTrue);
  });

  testWidgets('== fails for different fontWeights', (tester) async {
    const variant = FontVariant(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
    );
    const otherVariant = FontVariant(
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
    );
    expect(variant == otherVariant, isFalse);
  });

  testWidgets('== fails for different fontStyles', (tester) async {
    const variant = FontVariant(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
    );
    const otherVariant = FontVariant(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
    );
    expect(variant == otherVariant, isFalse);
  });

  testWidgets('== fails for different fontWeights and different fontStyles',
      (tester) async {
    const variant = FontVariant(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
    );
    const otherVariant = FontVariant(
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.normal,
    );
    expect(variant == otherVariant, isFalse);
  });
}
