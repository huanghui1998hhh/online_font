/// A package to allow you to use online fonts in your flutter app.
///
/// @docImport 'package:flutter/services.dart';
library online_font;

import 'dart:developer';

import 'package:flutter/widgets.dart';

import 'src/font_base.dart' as font_base;
import 'src/font_family_with_variant.dart';
import 'src/font_file.dart';
import 'src/font_variant.dart';

export 'src/font_base.dart';
export 'src/font_family_with_variant.dart';
export 'src/font_file.dart';
export 'src/font_variant.dart';

abstract class OnlineFont {
  const OnlineFont();

  /// Set of fonts that are loading or loaded.
  ///
  /// Used to determine whether to load a font or not.
  static final Set<FontFamilyWithVariant> _loadedFonts = {};
  static Set<FontFamilyWithVariant> get loadedFonts => _loadedFonts;

  static void clearCache() => _loadedFonts.clear();

  /// Set of [Future]s corresponding to fonts that are loading.
  ///
  /// When a font is loading, a future is added to this set. When it is loaded in
  /// the [FontLoader], that future is removed from this set.
  static final Map<FontFamilyWithVariant, Future<void>> pendingFontFutures = {};
  static Future<List<void>> allPendingFontFuture() =>
      Future.wait(pendingFontFutures.values);

  String get fontFamily;
  Map<FontVariant, FontFile> get fonts;

  /// Creates a [TextStyle] that either uses the [fontFamily] for the requested
  /// GoogleFont, or falls back to the pre-bundled [fontFamily].
  ///
  /// This function has a side effect of loading the font into the [FontLoader],
  /// either by network or from the device file system.
  TextStyle textStyle({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    if (textStyle?.fontFamily != null) {
      log('[online_font] Warning: ${textStyle?.fontFamily} will be ignored and '
          'the $fontFamily from the $runtimeType will be used instead.');
    }

    textStyle ??= const TextStyle();
    textStyle = textStyle.copyWith(
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );

    final variant = FontVariant(
      fontWeight: textStyle.fontWeight ?? FontWeight.w400,
      fontStyle: textStyle.fontStyle ?? FontStyle.normal,
    );
    final matchedVariant = _closestMatch(variant, fonts.keys);
    final familyWithVariant = FontFamilyWithVariant(
      family: fontFamily,
      fontVariant: matchedVariant,
    );

    final fontFile = fonts[matchedVariant];

    assert(
      fontFile != null,
      'Please provide a FontFile for Variant $matchedVariant of $fontFamily',
    );

    final loadingFuture =
        font_base.loadFontIfNecessary(familyWithVariant, fontFile!);
    pendingFontFutures[familyWithVariant] = loadingFuture;
    loadingFuture.then((_) => pendingFontFutures.remove(familyWithVariant));

    return textStyle.copyWith(
      fontFamily: familyWithVariant.toString(),
      fontFamilyFallback: [fontFamily],
    );
  }

  Future<void> loadVariant(
    FontVariant fontVariant,
  ) async {
    final familyWithVariant = FontFamilyWithVariant(
      family: fontFamily,
      fontVariant: fontVariant,
    );
    if (loadedFonts.contains(familyWithVariant)) return;
    final pendingFuture = pendingFontFutures[familyWithVariant];
    if (pendingFuture != null) return pendingFuture;
    final fontFile = fonts[fontVariant];
    assert(
      fontFile != null,
      'Please provide a FontFile for Variant $fontVariant of $fontFamily',
    );
    return font_base.loadFontIfNecessary(familyWithVariant, fontFile!);
  }

  Future<void> loadAll() => Future.wait(fonts.keys.map(loadVariant));

  Future<bool> checkFontFileExists(FontVariant fontVariant) {
    final familyWithVariant = FontFamilyWithVariant(
      family: fontFamily,
      fontVariant: fontVariant,
    );

    final fontFile = fonts[fontVariant];
    assert(
      fontFile != null,
      'Please provide a FontFile for Variant $fontVariant of $fontFamily',
    );

    return font_base.checkFontFileExists(familyWithVariant, fontFile!);
  }
}

class RawOnlineFont extends OnlineFont {
  const RawOnlineFont({
    required this.fontFamily,
    required this.fonts,
  });

  @override
  final String fontFamily;
  @override
  final Map<FontVariant, FontFile> fonts;
}

/// Returns [FontVariant] from [variantsToCompare] that most closely
/// matches [sourceVariant] according to the [_computeMatch] scoring function.
///
/// This logic is derived from the following section of the minikin library,
/// which is ultimately how flutter handles matching fonts.
/// https://github.com/flutter/engine/blob/master/third_party/txt/src/minikin/FontFamily.cpp#L149
FontVariant _closestMatch(
  FontVariant sourceVariant,
  Iterable<FontVariant> variantsToCompare,
) {
  int? bestScore;
  late FontVariant bestMatch;
  for (final variantToCompare in variantsToCompare) {
    final score = _computeMatch(sourceVariant, variantToCompare);
    if (bestScore == null || score < bestScore) {
      bestScore = score;
      bestMatch = variantToCompare;
    }
  }
  return bestMatch;
}

// This logic is taken from the following section of the minikin library, which
// is ultimately how flutter handles matching fonts.
// * https://github.com/flutter/engine/blob/master/third_party/txt/src/minikin/FontFamily.cpp#L128
int _computeMatch(FontVariant a, FontVariant b) {
  if (a == b) {
    return 0;
  }
  int score = (a.fontWeight.index - b.fontWeight.index).abs();
  if (a.fontStyle != b.fontStyle) {
    score += 2;
  }
  return score;
}
