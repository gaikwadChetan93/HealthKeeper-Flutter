import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Thin wrapper around ML Kit's on-device text recognizer — kept in one
/// place so the rest of the scanner flow doesn't touch the plugin
/// directly, and so the recognizer's native resources get closed
/// reliably after each scan.
class OcrService {
  /// Recognises text on each page in turn and returns the joined result,
  /// one page's text per block, in page order. Runs entirely on-device;
  /// nothing here touches the network.
  static Future<String> recognizePages(List<String> imagePaths) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final texts = <String>[];
      for (final path in imagePaths) {
        final inputImage = InputImage.fromFilePath(path);
        final result = await recognizer.processImage(inputImage);
        if (result.text.trim().isNotEmpty) texts.add(result.text.trim());
      }
      return texts.join('\n\n');
    } finally {
      await recognizer.close();
    }
  }
}
