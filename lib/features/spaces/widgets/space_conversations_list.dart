import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/models/conversation.dart';
import '../../chat/providers/conversation_provider.dart';
import '../../chat/repositories/chat_repository.dart';
import '../../chat/screens/chat_screen.dart';
import '../../agents/providers/agent_provider.dart';

class SpaceConversationsList extends ConsumerStatefulWidget {
  final int spaceId;

  const SpaceConversationsList({super.key, required this.spaceId});

  @override
  ConsumerState<SpaceConversationsList> createState() => _SpaceConversationsListState();
}

class _SpaceConversationsListState extends ConsumerState<SpaceConversationsList> {
  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(spaceConversationsProvider(widget.spaceId));

    return conversationsAsync.when(
      data: (conversations) {
        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Brak konwersacji',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showNewConversationDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Rozpocznij czat'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.chat),
                title: Text(conversation.title),
                subtitle: Text(
                  'Ostatnia wiadomość: ${_formatDate(conversation.lastMessageAt)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(conversationId: conversation.id),
                    ),
                  );
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Teraz';
        }
        return '${difference.inMinutes} min temu';
      }
      return '${difference.inHours} h temu';
    } else if (difference.inDays == 1) {
      return 'Wczoraj';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dni temu';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  void _showNewConversationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final agentsAsync = ref.read(spaceAgentsProvider(widget.spaceId).future);

    showDialog(
      context: context,
      builder: (context) => FutureBuilder(
        future: agentsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
            return AlertDialog(
              title: const Text('Brak agentów'),
              content: const Text(
                'Najpierw dodaj agenta w sekcji "Agenci".',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          }

          final agents = snapshot.data!;
          int? selectedAgentId;

          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Text('Nowa konwersacja'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tytuł',
                      hintText: 'Nazwa konwersacji',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Agent',
                    ),
                    items: agents.map((agent) {
                      return DropdownMenuItem<int>(
                        value: agent.id,
                        child: Text(agent.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAgentId = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Anuluj'),
                ),
                ElevatedButton(
                  onPressed: selectedAgentId == null
                      ? null
                      : () async {
                          if (titleController.text.trim().isNotEmpty) {
                            final repository = ref.read(chatRepositoryProvider);
                            await repository.createConversation(
                              spaceId: widget.spaceId,
                              agentId: selectedAgentId!,
                              title: titleController.text.trim(),
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ref.invalidate(spaceConversationsProvider(widget.spaceId));
                            }
                          }
                        },
                  child: const Text('Utwórz'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

