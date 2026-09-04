import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Compresses a profile photo to JPEG under [maxBytes] (default 20 KB).
class ProfilePhotoCompressor {
  ProfilePhotoCompressor._();

  static const maxBytes = 20 * 1024;

  static Future<File> compress(File source) async {
    final raw = await source.readAsBytes();
    final decoded = img.decodeImage(raw);
    if (decoded == null) {
      throw StateError('Could not read image');
    }

    var working = img.bakeOrientation(decoded);
    var maxSide = 512;

    while (true) {
      final resized = _fitWithin(working, maxSide);
      final bytes = _encodeUnderLimit(resized);
      if (bytes != null) {
        return _writeTemp(bytes);
      }

      if (maxSide <= 128) {
        throw StateError('Could not compress profile photo under 20 KB');
      }

      maxSide = (maxSide * 0.75).round();
    }
  }

  static img.Image _fitWithin(img.Image image, int maxSide) {
    final longest = math.max(image.width, image.height);
    if (longest <= maxSide) {
      return image;
    }

    if (image.width >= image.height) {
      return img.copyResize(image, width: maxSide);
    }
    return img.copyResize(image, height: maxSide);
  }

  static Uint8List? _encodeUnderLimit(img.Image image) {
    for (var quality = 85; quality >= 20; quality -= 5) {
      final bytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      if (bytes.length <= maxBytes) {
        return bytes;
      }
    }
    return null;
  }

  static Future<File> _writeTemp(Uint8List bytes) async {
    final file = File(
      '${Directory.systemTemp.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
