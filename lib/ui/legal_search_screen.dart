import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../services/qavanin_service.dart';
import 'package:dio/dio.dart';

const kBackendUrl = 'http://10.0.2.2:8000';

class LegalSearchScreen extends ConsumerStatefulWidget {
  const LegalSearchScreen({super.key});
  @override
  ConsumerState<LegalSearchScreen> createState() => _LegalSearchScreenState();
}

class _LegalSearchScreenState extends ConsumerState<LegalSearchScreen> {
  late final QavaninService _qavanin =
      QavaninService(isar: isar, baseUrl: kBackendUrl);
  List results = [];
  bool _busy = false;
  final _ctrl = TextEditingController();

  Future<void> _search({bool online = false}) async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final r = await _qavanin.search(_ctrl.text.trim(), forceOnline: online);
      setState(() => results = r);
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطای شبکه (آفلاین: کش محلی): ${e.message}')));
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جستجوی قوانین')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              decoration: const InputDecoration(labelText: 'جستجو در قوانین (مثلاً «مهلت اعتراض»)'),
              onSubmitted: (_) => _search(),
            )),
            IconButton(icon: const Icon(Icons.search), onPressed: () => _search()),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            OutlinedButton(onPressed: () => _search(online: true), child: const Text('جستجوی آنلاین (qavanin.ir)')),
          ]),
        ),
        Expanded(
          child: _busy
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final r = results[i] as dynamic;
                    return ListTile(
                      title: Text(r.title ?? ''),
                      subtitle: Text(r.summary ?? r.url ?? ''),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
