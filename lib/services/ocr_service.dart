import 'dart:io';
import 'package:dio/dio.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Offline OCR via Google ML Kit (on-device).
/// Fallback: POST the image to backend /api/ocr/extract (Tesseract).
class OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.script); // Persian-friendly script recognizer
  final Dio _dio;

  OcrService({required String baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 3),
        ));

  /// Try offline ML Kit first; if result is empty, relay to backend.
  Future<String> extractText(String imagePath, {bool preferBackend = false}) async {
    if (!preferBackend) {
      try {
        final text = await _extractOffline(imagePath);
        if (text.trim().isNotEmpty) return text;
      } catch (_) {
        // fall through to backend
      }
    }
    return _extractViaBackend(imagePath);
  }

  Future<String> _extractOffline(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);
    return result.text;
  }

  Future<String> _extractViaBackend(String imagePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath),
    });
    final res = await _dio.post('/api/ocr/extract', data: form);
    return res.data['text'] as String? ?? '';
  }

  void dispose() => _recognizer.close();
}
