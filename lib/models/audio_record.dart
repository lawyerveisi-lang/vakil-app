import 'package:isar/isar.dart';

part 'audio_record.g.dart';

@collection
class AudioRecord {
  Id id = Isar.autoIncrement;
  late int caseId;
  late String localPath;
  String? transcript;
  String? driveFileId;
  bool synced = false;
  DateTime createdAt = DateTime.now();
}
