import 'package:isar/isar.dart';

part 'agent.g.dart';

@collection
class Agent {
  Id id = Isar.autoIncrement;

  late String name;

  String? description;

  late String systemPrompt;

  @Enumerated(EnumType.name)
  late AIProvider provider;

  late String modelId;

  AgentCapabilities? capabilities;

  String? avatarEmoji;

  late DateTime createdAt;

  bool isPredefined = false;
}

@embedded
class AgentCapabilities {
  bool canGenerateCode = false;
  bool canEditFiles = false;
  bool canSearchWeb = false;
  bool canAnalyzeImages = false;
  List<String> supportedLanguages = [];
}

enum AIProvider {
  openai,
  anthropic,
  google,
  xai,
}
