import 'package:isar/isar.dart';

part 'client.g.dart';

@collection
class Client {
  Id id = Isar.autoIncrement;
  late String fullName;
  String? phone;
  String? nationalId;
  String? notes;
  String? driveFolderId;
  DateTime createdAt = DateTime.now();
}
