/// Describes a font file as it is _expected_ to be received from the server.
///
/// If a file is retrieved and its hash does not match [expectedFileHash], or it
/// is not of [expectedLength] bytes length, the font will not be loaded, and
/// the file will not be stored on the device. Of course, this is optional if
/// you don't want to check the file length and hash.
class FontFile {
  const FontFile({
    required this.url,
    this.expectedFileHash,
    this.expectedLength,
    this.extensionName,
  });

  /// The url of the font file.
  final String url;

  /// The expected file hash.
  final String? expectedFileHash;

  /// The expected file length.
  final int? expectedLength;

  /// For the cache of `online_font`, [extensionName] is meaningless, but we
  /// still provide it :).
  final String? extensionName;
}
