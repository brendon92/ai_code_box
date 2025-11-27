import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../agents/models/agent.dart';
import '../../agents/providers/agent_provider.dart';
import '../../agents/repositories/agent_repository.dart';

class SpaceAgentsList extends ConsumerStatefulWidget {
  final int spaceId;

  const SpaceAgentsList({super.key, required this.spaceId});

  @override
  ConsumerState<SpaceAgentsList> createState() => _SpaceAgentsListState();
}

class _SpaceAgentsListState extends ConsumerState<SpaceAgentsList> {
  @override
  Widget build(BuildContext context) {
    final agentsAsync = ref.watch(spaceAgentsProvider(widget.spaceId));

    return agentsAsync.when(
      data: (agents) {
        if (agents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.smart_toy_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Brak agentów',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddAgentDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj agenta'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: agents.length,
          itemBuilder: (context, index) {
            final agent = agents[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: agent.avatarEmoji != null
                    ? Text(
                        agent.avatarEmoji!,
                        style: const TextStyle(fontSize: 32),
                      )
                    : const Icon(Icons.smart_toy),
                title: Text(agent.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (agent.description != null) Text(agent.description!),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            agent.provider.name.toUpperCase(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Chip(
                          label: Text(
                            agent.modelId,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: agent.isPredefined
                    ? const Chip(
                        label: Text('Predefiniowany'),
                        labelStyle: TextStyle(fontSize: 10),
                      )
                    : null,
                onTap: () {
                  // TODO: Show agent details/edit dialog
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Błąd: $error'),
          ],
        ),
      ),
    );
  }

  void _showAddAgentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final promptController = TextEditingController();
    final modelController = TextEditingController(text: 'gpt-4');
    AIProvider? selectedProvider = AIProvider.openai;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nowy agent'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nazwa',
                    hintText: 'Nazwa agenta',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Opis (opcjonalnie)',
                    hintText: 'Krótki opis agenta',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AIProvider>(
                  decoration: const InputDecoration(
                    labelText: 'Dostawca AI',
                  ),
                  value: selectedProvider,
                  items: AIProvider.values.map((provider) {
                    return DropdownMenuItem<AIProvider>(
                      value: provider,
                      child: Text(provider.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProvider = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    hintText: 'gpt-4, gpt-3.5-turbo, etc.',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: promptController,
                  decoration: const InputDecoration(
                    labelText: 'System Prompt',
                    hintText: 'Instrukcje dla agenta...',
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty &&
                    promptController.text.trim().isNotEmpty &&
                    modelController.text.trim().isNotEmpty &&
                    selectedProvider != null) {
                  final repository = ref.read(agentRepositoryProvider);
                  await repository.createAgent(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    systemPrompt: promptController.text.trim(),
                    provider: selectedProvider!,
                    modelId: modelController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.invalidate(spaceAgentsProvider(widget.spaceId));
                  }
                }
              },
              child: const Text('Utwórz'),
            ),
          ],
        ),
      ),
    );
  }
}

