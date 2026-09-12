import 'package:isar/isar.dart';

part 'document.g.dart';

@collection
class Document {
  Id id = Isar.autoIncrement;
  late int caseId;
  late String localPath;
  String? extractedText;
  String? driveFileId;
  bool synced = false;
  DateTime createdAt = DateTime.now();
}
