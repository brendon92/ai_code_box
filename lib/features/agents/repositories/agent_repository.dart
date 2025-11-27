import 'package:isar/isar.dart';
import 'package:ai_code_box/core/database/isar_service.dart';
import 'package:ai_code_box/features/agents/models/agent.dart';

class AgentRepository {
  final IsarService _isarService;

  AgentRepository(this._isarService);

  Future<Isar> get _db => _isarService.db;

  /// Gets all agents
  Future<List<Agent>> getAllAgents() async {
    final db = await _db;
    return await db.agents.where().findAll();
  }

  /// Gets an agent by ID
  Future<Agent?> getAgentById(int id) async {
    final db = await _db;
    return await db.agents.get(id);
  }

  /// Gets agents by space (if agents are associated with spaces)
  /// Note: This assumes agents can be used across spaces. 
  /// If you need space-specific agents, add a spaceId field to Agent model.
  Future<List<Agent>> getAgentsForSpace(int spaceId) async {
    // For now, return all agents. Can be extended later.
    return await getAllAgents();
  }

  /// Creates a new agent
  Future<Agent> createAgent({
    required String name,
    String? description,
    required String systemPrompt,
    required AIProvider provider,
    required String modelId,
    AgentCapabilities? capabilities,
    String? avatarEmoji,
    bool isPredefined = false,
  }) async {
    final db = await _db;
    final agent = Agent()
      ..name = name
      ..description = description
      ..systemPrompt = systemPrompt
      ..provider = provider
      ..modelId = modelId
      ..capabilities = capabilities ?? AgentCapabilities()
      ..avatarEmoji = avatarEmoji
      ..isPredefined = isPredefined
      ..createdAt = DateTime.now();

    await db.writeTxn(() async {
      await db.agents.put(agent);
    });

    return agent;
  }

  /// Updates an agent
  Future<void> updateAgent(Agent agent) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.agents.put(agent);
    });
  }

  /// Deletes an agent
  Future<void> deleteAgent(int id) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.agents.delete(id);
    });
  }
}

