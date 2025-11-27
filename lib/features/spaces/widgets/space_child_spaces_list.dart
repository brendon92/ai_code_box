import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/space.dart';
import '../providers/space_provider.dart';
import '../repositories/space_repository.dart';
import '../screens/space_detail_screen.dart';

class SpaceChildSpacesList extends ConsumerStatefulWidget {
  final int spaceId;

  const SpaceChildSpacesList({super.key, required this.spaceId});

  @override
  ConsumerState<SpaceChildSpacesList> createState() => _SpaceChildSpacesListState();
}

class _SpaceChildSpacesListState extends ConsumerState<SpaceChildSpacesList> {
  @override
  Widget build(BuildContext context) {
    final childSpacesAsync = ref.watch(childSpacesProvider(widget.spaceId));

    return childSpacesAsync.when(
      data: (childSpaces) {
        if (childSpaces.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Brak pod-przestrzeni',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreateChildSpaceDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Utwórz pod-przestrzeń'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: childSpaces.length,
          itemBuilder: (context, index) {
            final space = childSpaces[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: space.iconEmoji != null
                    ? Text(
                        space.iconEmoji!,
                        style: const TextStyle(fontSize: 32),
                      )
                    : const Icon(Icons.folder),
                title: Text(space.name),
                subtitle: space.description != null
                    ? Text(space.description!)
                    : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpaceDetailScreen(spaceId: space.id),
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

  void _showCreateChildSpaceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final iconController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nowa pod-przestrzeń'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nazwa',
                hintText: 'Nazwa pod-przestrzeni',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Opis (opcjonalnie)',
                hintText: 'Krótki opis pod-przestrzeni',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: 'Emoji (opcjonalnie)',
                hintText: '📁',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final repository = ref.read(spaceRepositoryProvider);
                await repository.createSpace(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  iconEmoji: iconController.text.trim().isEmpty
                      ? null
                      : iconController.text.trim(),
                  parentId: widget.spaceId, // Ustaw parentId na aktualną przestrzeń
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(childSpacesProvider(widget.spaceId));
                  ref.invalidate(spacesProvider);
                }
              }
            },
            child: const Text('Utwórz'),
          ),
        ],
      ),
    );
  }
}

