import 'package:isar/isar.dart';

part 'calendar_event.g.dart';

@collection
class CalendarEvent {
  Id id = Isar.autoIncrement;
  int? caseId;
  late String title;
  String? kind; // hearing / deadline / meeting
  late DateTime date;
  bool notified = false;
}
