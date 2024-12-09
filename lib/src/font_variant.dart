import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Represents a font variant in Flutter-specific types.
@immutable
class FontVariant {
  const FontVariant({
    required this.fontWeight,
    required this.fontStyle,
  });

  /// Creates a [FontVariant] from a filename part.
  ///
  /// A filename part is the part of the filename that does not include the
  /// font family. For example, for the filename "Lato-Regular.ttf", the
  /// filename part is "Regular".
  ///
  /// The following table shows how these filename parts convert:
  /// 'Regular' -> weight: 400, style: normal
  /// 'Italic' -> weight: 400, style: italic
  /// 'Bold' -> weight: 700, style: normal
  /// 'BoldItalic' -> weight: 700, style: italic
  ///
  /// See [FontVariant.toString] for the inverse function.
  FontVariant.fromString(String filenamePart)
      : fontWeight = _extractFontWeightFromApiFilenamePart(filenamePart),
        fontStyle = _extractFontStyleFromApiFilenamePart(filenamePart);

  static const thin =
      FontVariant(fontWeight: FontWeight.w100, fontStyle: FontStyle.normal);
  static const extraLight =
      FontVariant(fontWeight: FontWeight.w200, fontStyle: FontStyle.normal);
  static const light =
      FontVariant(fontWeight: FontWeight.w300, fontStyle: FontStyle.normal);
  static const regular =
      FontVariant(fontWeight: FontWeight.w400, fontStyle: FontStyle.normal);
  static const medium =
      FontVariant(fontWeight: FontWeight.w500, fontStyle: FontStyle.normal);
  static const semiBold =
      FontVariant(fontWeight: FontWeight.w600, fontStyle: FontStyle.normal);
  static const bold =
      FontVariant(fontWeight: FontWeight.w700, fontStyle: FontStyle.normal);
  static const extraBold =
      FontVariant(fontWeight: FontWeight.w800, fontStyle: FontStyle.normal);
  static const black =
      FontVariant(fontWeight: FontWeight.w900, fontStyle: FontStyle.normal);
  static const thinItalic =
      FontVariant(fontWeight: FontWeight.w100, fontStyle: FontStyle.italic);
  static const extraLightItalic =
      FontVariant(fontWeight: FontWeight.w200, fontStyle: FontStyle.italic);
  static const lightItalic =
      FontVariant(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic);
  static const italic =
      FontVariant(fontWeight: FontWeight.w400, fontStyle: FontStyle.italic);
  static const mediumItalic =
      FontVariant(fontWeight: FontWeight.w500, fontStyle: FontStyle.italic);
  static const semiBoldItalic =
      FontVariant(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic);
  static const boldItalic =
      FontVariant(fontWeight: FontWeight.w700, fontStyle: FontStyle.italic);
  static const extraBoldItalic =
      FontVariant(fontWeight: FontWeight.w800, fontStyle: FontStyle.italic);
  static const blackItalic =
      FontVariant(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic);

  final FontWeight fontWeight;
  final FontStyle fontStyle;

  static FontWeight _extractFontWeightFromApiFilenamePart(String filenamePart) {
    if (filenamePart.contains('Thin')) return FontWeight.w100;

    // ExtraLight must be checked before Light because of the substring match.
    if (filenamePart.contains('ExtraLight')) return FontWeight.w200;
    if (filenamePart.contains('Light')) return FontWeight.w300;

    if (filenamePart.contains('Medium')) return FontWeight.w500;

    // SemiBold and ExtraBold must be checked before Bold because of the
    // substring match.
    if (filenamePart.contains('SemiBold')) return FontWeight.w600;
    if (filenamePart.contains('ExtraBold')) return FontWeight.w800;
    if (filenamePart.contains('Bold')) return FontWeight.w700;

    if (filenamePart.contains('Black')) return FontWeight.w900;
    return FontWeight.w400;
  }

  static FontStyle _extractFontStyleFromApiFilenamePart(String filenamePart) {
    if (filenamePart.contains('Italic')) return FontStyle.italic;
    return FontStyle.normal;
  }

  /// Converts this [FontVariant] to a filename part.
  ///
  /// A Filename part is the part of the filename that does not include the
  /// font family. For example: for the filename "Lato-Regular.ttf", the
  /// filename part is "Regular".
  ///
  /// The following table shows how these [FontVariant]s convert:
  /// weight: 400, style: normal -> 'Regular'
  /// weight: 400, style: italic -> 'Italic'
  /// weight: 700, style: normal -> 'Bold'
  /// weight: 700, style: italic -> 'BoldItalic'
  ///
  /// See [FontVariant.fromString] for the inverse function.
  @override
  String toString() {
    final weightPrefix = _fontWeightToFilenameWeightParts[fontWeight] ??
        _fontWeightToFilenameWeightParts[FontWeight.w400]!;
    final italicSuffix = fontStyle == FontStyle.italic ? 'Italic' : '';
    if (weightPrefix == 'Regular') {
      return italicSuffix == '' ? weightPrefix : italicSuffix;
    }
    return '$weightPrefix$italicSuffix';
  }

  @override
  int get hashCode => Object.hash(fontWeight, fontStyle);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is FontVariant &&
        other.fontWeight == fontWeight &&
        other.fontStyle == fontStyle;
  }
}

/// Mapping from font weight types to the 'weight' part of the Google Fonts API
/// specific filename.
const _fontWeightToFilenameWeightParts = {
  FontWeight.w100: 'Thin',
  FontWeight.w200: 'ExtraLight',
  FontWeight.w300: 'Light',
  FontWeight.w400: 'Regular',
  FontWeight.w500: 'Medium',
  FontWeight.w600: 'SemiBold',
  FontWeight.w700: 'Bold',
  FontWeight.w800: 'ExtraBold',
  FontWeight.w900: 'Black',
};
