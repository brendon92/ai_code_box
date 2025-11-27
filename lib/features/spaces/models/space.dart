import 'package:isar/isar.dart';

part 'space.g.dart';

@collection
class Space {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  String? description;

  late DateTime createdAt;

  late DateTime updatedAt;

  String? iconEmoji;

  List<String> tags = [];

  @Index()
  bool isDefault = false;

  int? parentId;
}
