import 'package:isar/isar.dart';

part 'case.g.dart';

@collection
class Case {
  Id id = Isar.autoIncrement;
  late int clientId;
  late String title;
  String? caseNumber;
  String? court;
  String? status; // open / closed / archived
  String? driveFolderId;
  DateTime createdAt = DateTime.now();
}
