import 'package:isar/isar.dart';

part 'resource.g.dart';

@collection
class Resource {
  Id id = Isar.autoIncrement;

  @Index()
  late int spaceId;

  @Enumerated(EnumType.name)
  late ResourceType type;

  late String name;

  String? path;

  String? url;

  String? content;

  late DateTime createdAt;

  late DateTime updatedAt;

  List<String> tags = [];

  bool isPrivate = false;
}

enum ResourceType {
  textFile,
  markdown,
  pdf,
  html,
  code,
  image,
  url,
}
