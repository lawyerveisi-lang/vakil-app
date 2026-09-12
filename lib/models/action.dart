import 'package:isar/isar.dart';

part 'action.g.dart';

@collection
class Action {
  Id id = Isar.autoIncrement;
  late int caseId;
  late String title;
  String? description;
  DateTime? dueDate;
  DateTime createdAt = DateTime.now();
}
