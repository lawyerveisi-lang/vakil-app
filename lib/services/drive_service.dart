import 'package:dio/dio.dart';

/// Google Drive backup service.
/// Primary flow: client-side Google Sign-In + Drive upload.
/// Relay flow: backend /api/drive endpoints (service-account or OAuth server flow).
class DriveService {
  final Dio _dio;
  DriveService({required String baseUrl})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  /// Ensure Drive folder exists (per client / per case) and return its ID.
  Future<String> ensureFolder({
    required String clientName,
    required String caseTitle,
  }) async {
    final res = await _dio.post('/api/drive/folder', data: {
      'client': clientName,
      'case': caseTitle,
    });
    return res.data['folderId'] as String;
  }

  /// Upload a local file into the given Drive folder.
  Future<String> uploadFile({
    required String filePath,
    required String folderId,
    String? mimeType,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'folder_id': folderId,
      'mime': mimeType ?? 'application/octet-stream',
    });
    final res = await _dio.post('/api/drive/upload', data: form);
    return res.data['fileId'] as String;
  }
}
