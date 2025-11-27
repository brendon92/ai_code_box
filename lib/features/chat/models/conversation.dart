import 'package:isar/isar.dart';

part 'conversation.g.dart';

@collection
class Conversation {
  Id id = Isar.autoIncrement;

  @Index()
  late int spaceId;

  @Index()
  late int agentId;

  late String title;

  late DateTime createdAt;

  late DateTime lastMessageAt;
}
