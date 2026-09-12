import 'package:isar/isar.dart';
import '../models/legal_reference.dart';
import 'package:dio/dio.dart';

/// Client-side cached legal search over qavanin.ir.
/// Search results are cached in Isar (TTL 7 days) for full offline reading.
class QavaninService {
  final Isar _isar;
  final Dio _dio;

  static const cacheTtl = Duration(days: 7);

  QavaninService({required Isar isar, required String baseUrl})
      : _isar = isar,
        _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<List<LegalReference>> search(String query, {bool forceOnline = false}) async {
    final now = DateTime.now();

    if (!forceOnline) {
      final cached = await _isar.legalReferences
          .filter()
          .titleContains(query, caseSensitive: false)
          .sortByFetchedAtDesc()
          .findAll();
      final fresh = cached.where((e) => now.difference(e.fetchedAt) < cacheTtl).toList();
      if (fresh.isNotEmpty) return fresh;
    }

    // Ask backend (it crawls & caches qavanin.ir)
    final res = await _dio.get('/api/legal/search', queryParameters: {'q': query});
    final items = (res.data['results'] as List).cast<Map<String, dynamic>>();

    final refs = items.map((j) {
      return LegalReference()
        ..title = j['title'] as String? ?? ''
        ..summary = j['summary'] as String?
        ..url = j['url'] as String?
        ..fetchedAt = DateTime.now();
    }).toList();

    await _isar.writeTxn(() async => _isar.legalReferences.putAll(refs));
    return refs;
  }

  /// Fetch full text of a law (backend scraper), cached offline.
  Future<String> getFullText(String url) async {
    final cached = await _isar.legalReferences.filter().urlEqualTo(url).findFirst();
    if (cached != null && cached.rawHtml != null) return cached.rawHtml!;

    final res = await _dio.get('/api/legal/detail', queryParameters: {'url': url});
    final text = res.data['text'] as String? ?? '';
    if (cached != null) {
      await _isar.writeTxn(() async {
        cached.rawHtml = text;
        await _isar.legalReferences.put(cached);
      });
    }
    return text;
  }
}
