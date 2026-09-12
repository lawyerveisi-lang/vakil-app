import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/ocr_service.dart';

const kBackendUrl = 'http://10.0.2.2:8000';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});
  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final _ocr = OcrService(baseUrl: kBackendUrl);
  String _text = '';
  bool _busy = false;

  @override
  void dispose() { _ocr.dispose(); super.dispose(); }

  Future<void> _pick() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (img == null) return;
    setState(() { _busy = true; _text = ''; });
    try {
      final text = await _ocr.extractText(img.path);
      setState(() => _text = text);
    } catch (e) {
      setState(() => _text = 'خطا در OCR: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اسکنر و OCR')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _pick,
        icon: const Icon(Icons.document_scanner),
        label: const Text('عکس سند'),
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Expanded(
                  child: _text.isEmpty
                      ? const Center(child: Text('عکس سند را بگیرید تا متن استخراج شود'))
                      : SingleChildScrollView(child: SelectableText(_text)),
                ),
                if (_text.isNotEmpty)
                  FilledButton.tonal(
                    onPressed: () async {
                      final dir = await getApplicationDocumentsDirectory();
                      final f = File('${dir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.txt');
                      await f.writeAsString(_text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ذخیره شد: ${f.path}')));
                      }
                    },
                    child: const Text('ذخیره متن استخراج‌شده'),
                  ),
              ]),
            ),
    );
  }
}
