/// Describes a font file as it is _expected_ to be received from the server.
///
/// If a file is retrieved and its hash does not match [expectedFileHash], or it
/// is not of [expectedLength] bytes length, the font will not be loaded, and
/// the file will not be stored on the device.
class FontFile {
  const FontFile({
    required this.url,
    this.expectedFileHash,
    this.expectedLength,
  });

  final String url;
  final String? expectedFileHash;
  final int? expectedLength;
}
