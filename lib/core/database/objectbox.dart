import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'objectbox.g.dart'; // Created by `flutter pub run build_runner build`

@Entity()
class DocumentEntity {
  @Id()
  int id = 0;

  String content;
  String metadata; // JSON encoded

  @HnswIndex(dimensions: 1536)
  @Property(type: PropertyType.floatVector)
  List<double> embedding;

  DocumentEntity({
    this.id = 0,
    required this.content,
    required this.metadata,
    required this.embedding,
  });
}

class ObjectBox {
  late final Store store;
  late final Box<DocumentEntity> documentBox;

  ObjectBox._create(this.store) {
    documentBox = store.box<DocumentEntity>();
  }

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "ai_code_box_db"));
    return ObjectBox._create(store);
  }
}
