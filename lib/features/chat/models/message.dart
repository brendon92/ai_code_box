import 'package:isar/isar.dart';

part 'message.g.dart';

@collection
class Message {
  Id id = Isar.autoIncrement;

  @Index()
  late int conversationId;

  @Enumerated(EnumType.name)
  late MessageRole role;

  late String content;

  late DateTime timestamp;
}

enum MessageRole {
  user,
  assistant,
  system,
}
