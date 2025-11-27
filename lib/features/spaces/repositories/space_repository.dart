import 'package:isar/isar.dart';
import 'package:ai_code_box/core/database/isar_service.dart';
import 'package:ai_code_box/features/spaces/models/space.dart';
import 'package:ai_code_box/features/spaces/models/resource.dart';

class SpaceRepository {
  final IsarService _isarService;

  SpaceRepository(this._isarService);

  Future<Isar> get _db => _isarService.db;

  /// Gets all spaces
  Future<List<Space>> getAllSpaces() async {
    final db = await _db;
    return await db.spaces.where().findAll();
  }

  /// Gets child spaces (sub-spaces) of a given space
  Future<List<Space>> getChildSpaces(int parentSpaceId) async {
    final db = await _db;
    return await db.spaces.filter().parentIdEqualTo(parentSpaceId).findAll();
  }

  /// Gets a space by ID
  Future<Space?> getSpaceById(int id) async {
    final db = await _db;
    return await db.spaces.get(id);
  }

  /// Gets the default space, or creates one if it doesn't exist
  Future<Space> getOrCreateDefaultSpace() async {
    final db = await _db;
    final defaultSpace = await db.spaces.filter().isDefaultEqualTo(true).findFirst();
    
    if (defaultSpace != null) {
      return defaultSpace;
    }

    // Create default space
    final newSpace = Space()
      ..name = 'Główna'
      ..description = 'Domyślna przestrzeń robocza'
      ..isDefault = true
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..tags = [];

    await db.writeTxn(() async {
      await db.spaces.put(newSpace);
    });

    return newSpace;
  }

  /// Creates a new space
  Future<Space> createSpace({
    required String name,
    String? description,
    String? iconEmoji,
    List<String>? tags,
    int? parentId,
  }) async {
    final db = await _db;
    final space = Space()
      ..name = name
      ..description = description
      ..iconEmoji = iconEmoji
      ..tags = tags ?? []
      ..isDefault = false
      ..parentId = parentId
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await db.writeTxn(() async {
      await db.spaces.put(space);
    });

    return space;
  }

  /// Updates a space
  Future<void> updateSpace(Space space) async {
    final db = await _db;
    space.updatedAt = DateTime.now();
    await db.writeTxn(() async {
      await db.spaces.put(space);
    });
  }

  /// Deletes a space
  Future<void> deleteSpace(int id) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.spaces.delete(id);
      // Also delete all resources in this space
      await db.resources.filter().spaceIdEqualTo(id).deleteAll();
    });
  }

  /// Gets all resources in a space
  Future<List<Resource>> getSpaceResources(int spaceId) async {
    final db = await _db;
    return await db.resources.filter().spaceIdEqualTo(spaceId).findAll();
  }

  /// Adds a resource to a space
  Future<Resource> addResource({
    required int spaceId,
    required ResourceType type,
    required String name,
    String? path,
    String? url,
    String? content,
    List<String>? tags,
    bool isPrivate = false,
  }) async {
    final db = await _db;
    final resource = Resource()
      ..spaceId = spaceId
      ..type = type
      ..name = name
      ..path = path
      ..url = url
      ..content = content
      ..tags = tags ?? []
      ..isPrivate = isPrivate
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await db.writeTxn(() async {
      await db.resources.put(resource);
    });

    return resource;
  }

  /// Deletes a resource
  Future<void> deleteResource(int resourceId) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.resources.delete(resourceId);
    });
  }
}

