import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/spaces/models/space.dart';
import '../../features/spaces/models/resource.dart';
import '../../features/agents/models/agent.dart';
import '../../features/chat/models/conversation.dart';
import '../../features/chat/models/message.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          SpaceSchema,
          ResourceSchema,
          AgentSchema,
          ConversationSchema,
          MessageSchema,
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
