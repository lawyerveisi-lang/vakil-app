import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Offline-first audio service:
/// 1) On-device speech-to-text via `speech_to_text` (works without internet).
/// 2) If on-device recognition is unavailable, sends the recorded file to the
///    FastAPI backend which relays it to Google Cloud Speech (fa-IR).
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final stt.SpeechToText _stt = stt.SpeechToText();
  final Dio _dio;

  String? _currentPath;
  bool get isRecording => _currentPath != null;

  final _transcriptCtrl = StreamController<String>.broadcast();
  Stream<String> get transcriptStream => _transcriptCtrl.stream;

  AudioService({required String baseUrl})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl, sendTimeout: const Duration(minutes: 5), receiveTimeout: const Duration(minutes: 5)));

  Future<bool> initOfflineStt({String localeId = 'fa_IR'}) async {
    try {
      return await _stt.initialize(onStatus: (s) {}, onError: (e) {});
    } catch (_) {
      return false;
    }
  }

  /// Start recording + live on-device transcription if available.
  Future<String> startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    if (!await _recorder.hasPermission()) {
      throw Exception('Microphone permission denied');
    }
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 96000, sampleRate: 44100),
      path: path,
    );
    _currentPath = path;

    final offlineReady = await initOfflineStt();
    if (offlineReady) {
      _stt.listen(
        localeId: 'fa_IR',
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
        ),
        onResult: (r) => _transcriptCtrl.add(r.recognizedWords),
      );
    }
    return path;
  }

  Future<String> stopRecording() async {
    final path = await _recorder.stop();
    _currentPath = null;
    if (_stt.isListening) await _stt.stop();
    return path ?? '';
  }

  /// Fallback: upload the audio file to backend -> Google Cloud Speech (fa-IR).
  Future<String> transcribeViaBackend(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: 'audio.m4a'),
      'language': 'fa-IR',
    });
    final res = await _dio.post('/api/speech/transcribe', data: form);
    return res.data['transcript'] as String? ?? '';
  }

  void dispose() {
    _recorder.dispose();
    _transcriptCtrl.close();
    if (Platform.isAndroid || Platform.isIOS) {
      // nothing else needed
    }
  }
}
