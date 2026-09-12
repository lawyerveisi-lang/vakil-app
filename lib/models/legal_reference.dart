import 'package:isar/isar.dart';

part 'legal_reference.g.dart';

@collection
class LegalReference {
  Id id = Isar.autoIncrement;
  late String title;
  String? summary;
  String? url;
  late DateTime fetchedAt;
  String? rawHtml;
}
