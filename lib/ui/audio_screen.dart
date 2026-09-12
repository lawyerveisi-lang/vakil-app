import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';

const kBackendUrl = 'http://10.0.2.2:8000';

class AudioScreen extends ConsumerStatefulWidget {
  const AudioScreen({super.key});
  @override
  ConsumerState<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends ConsumerState<AudioScreen> {
  late final AudioService _audio = AudioService(baseUrl: kBackendUrl);
  StreamSubscription<String>? _sub;
  bool _recording = false;
  String _path = '';
  final StringBuffer _transcript = StringBuffer();

  @override
  void initState() {
    super.initState();
    _sub = _audio.transcriptStream.listen((t) => setState(() => _transcript
      ..clear()
      ..write(t)));
  }

  @override
  void dispose() { _sub?.cancel(); _audio.dispose(); super.dispose(); }

  Future<void> _toggle() async {
    if (_recording) {
      final p = await _audio.stopRecording();
      setState(() { _recording = false; _path = p; });
    } else {
      final p = await _audio.startRecording();
      setState(() { _recording = true; _path = p; _transcript.clear(); });
    }
  }

  Future<void> _backendTranscribe() async {
    if (_path.isEmpty) return;
    setState(() => _transcript..clear());
    try {
      final t = await _audio.transcribeViaBackend(_path);
      setState(() => _transcript..clear()..write(t));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ضبط صوت با پیاده‌سازی زنده')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            FilledButton.icon(
              onPressed: _toggle,
              icon: Icon(_recording ? Icons.stop : Icons.mic),
              label: Text(_recording ? 'توقف' : 'شروع ضبط'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _recording ? null : _backendTranscribe,
              icon: const Icon(Icons.cloud),
              label: const Text('پیاده‌سازی سرور (Google Speech)'),
            ),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(child: SelectableText(
              _transcript.isEmpty ? 'متن پیاده‌سازی‌شده اینجا نمایش داده می‌شود' : _transcript.toString(),
              style: const TextStyle(fontSize: 16, height: 1.6),
            )),
          ),
        ),
      ]),
    );
  }
}
