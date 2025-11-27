import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_code_box/features/agents/models/agent.dart';
import 'package:ai_code_box/features/agents/repositories/agent_repository.dart';
import 'package:ai_code_box/features/spaces/providers/space_provider.dart';

final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return AgentRepository(isarService);
});

final agentsProvider = FutureProvider<List<Agent>>((ref) async {
  final repository = ref.watch(agentRepositoryProvider);
  return await repository.getAllAgents();
});

final agentProvider = FutureProvider.family<Agent?, int>((ref, agentId) async {
  final repository = ref.watch(agentRepositoryProvider);
  return await repository.getAgentById(agentId);
});

final spaceAgentsProvider = FutureProvider.family<List<Agent>, int>((ref, spaceId) async {
  final repository = ref.watch(agentRepositoryProvider);
  return await repository.getAgentsForSpace(spaceId);
});

