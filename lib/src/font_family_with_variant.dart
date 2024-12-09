import 'package:flutter/widgets.dart';

import 'font_variant.dart';

/// Represents a Google Fonts API variant in Flutter-specific types.
@immutable
class FontFamilyWithVariant {
  const FontFamilyWithVariant({
    required this.family,
    required this.fontVariant,
  });

  final String family;
  final FontVariant fontVariant;

  /// Returns a font family name that is modified with additional [fontWeight]
  /// and [fontStyle] descriptions.
  ///
  /// This string is used as a key to the loaded or stored fonts that come
  /// from the Google Fonts API.
  @override
  String toString() => '$family-$fontVariant';

  @override
  bool operator ==(Object other) =>
      other is FontFamilyWithVariant &&
      other.family == family &&
      other.fontVariant == fontVariant;

  @override
  int get hashCode => Object.hash(family, fontVariant);
}
